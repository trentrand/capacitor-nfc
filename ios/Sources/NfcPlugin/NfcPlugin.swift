import Foundation
import Capacitor
import CoreNFC

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(NfcPlugin)
public class NfcPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NfcPlugin"
    public let jsName = "Nfc"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "startScan", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopScan", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "write", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isEnabled", returnType: CAPPluginReturnPromise)
    ]

    private var session: NFCNDEFReaderSession?
    private var pendingWrite: NFCNDEFMessage?
    private var isScanning = false
    private var sessionStartCallback: (() -> Void)?

    @objc func isEnabled(_ call: CAPPluginCall) {
        call.resolve([
            "enabled": NFCNDEFReaderSession.readingAvailable
        ])
    }

    @objc func startScan(_ call: CAPPluginCall) {
        guard NFCNDEFReaderSession.readingAvailable else {
            call.reject("NFC is not available on this device")
            return
        }

        if isScanning {
            call.reject("Scan already in progress")
            return
        }

        sessionStartCallback = {
            call.resolve()
        }

        do {
            let newSession = try createSession()
            session = newSession
            isScanning = true

            DispatchQueue.main.async {
                newSession.begin()
            }
        } catch {
            sessionStartCallback = nil
            call.reject("Failed to create NFC session: \(error.localizedDescription)")
        }
    }

    private func createSession() throws -> NFCNDEFReaderSession {
        let session = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
        session.alertMessage = "Hold your iPhone near an NFC tag"
        return session
    }

    @objc func stopScan(_ call: CAPPluginCall) {
        session?.invalidate()
        session = nil
        isScanning = false
        call.resolve()
    }

    @objc func write(_ call: CAPPluginCall) {
        guard NFCNDEFReaderSession.readingAvailable else {
            call.reject("NFC is not available on this device")
            return
        }

        guard let records = call.getArray("records") as? [[String: Any]] else {
            call.reject("Invalid records format")
            return
        }

        do {
            let ndefRecords = try records.map { recordDict -> NFCNDEFPayload in
                guard let recordType = recordDict["recordType"] as? String,
                      let data = recordDict["data"] as? [UInt8] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid record format"])
                }

                return NFCNDEFPayload(
                    format: .media,
                    type: recordType.data(using: .utf8)!,
                    identifier: Data(),
                    payload: Data(data)
                )
            }

            pendingWrite = NFCNDEFMessage(records: ndefRecords)
            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session?.alertMessage = "Hold your iPhone near an NFC tag to write"
            session?.begin()

            call.resolve()
        } catch {
            call.reject("Failed to create NDEF message: \(error.localizedDescription)")
        }
    }
}

extension NfcPlugin: NFCNDEFReaderSessionDelegate {
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        sessionStartCallback?()
        sessionStartCallback = nil
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        sessionStartCallback = nil
        let readerError = error as? NFCReaderError
        if (readerError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
            && (readerError?.code != .readerSessionInvalidationErrorUserCanceled) {
            DispatchQueue.main.async {
                self.notifyListeners("nfcError", data: [
                    "message": error.localizedDescription,
                    "code": readerError?.code.rawValue ?? -1
                ])
            }
        }
        self.session = nil
        self.isScanning = false
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            let records = message.records.map { record -> [String: Any] in
                return [
                    "recordType": String(data: record.type, encoding: .utf8) ?? "",
                    "mediaType": record.typeNameFormat.rawValue,
                    "data": Array(record.payload)
                ]
            }

            DispatchQueue.main.async {
                self.notifyListeners("nfcTagRead", data: [
                    "message": ["records": records]
                ])
            }
        }
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                session.restartPolling()
            }
            return
        }

        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                return
            }

            tag.queryNDEFStatus { status, capacity, error in
                guard error == nil else {
                    session.invalidate(errorMessage: "Failed to query tag status")
                    return
                }

                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "Tag is not NDEF compliant")
                case .readOnly:
                    if self.pendingWrite != nil {
                        session.invalidate(errorMessage: "Tag is read-only")
                    } else {
                        self.readTag(tag, session: session)
                    }
                case .readWrite:
                    if let pendingWrite = self.pendingWrite {
                        self.writeTag(tag, message: pendingWrite, session: session)
                    } else {
                        self.readTag(tag, session: session)
                    }
                @unknown default:
                    session.invalidate(errorMessage: "Unknown tag status")
                }
            }
        }
    }

    private func readTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { message, error in
            if let error = error {
                session.invalidate(errorMessage: "Read error: \(error.localizedDescription)")
                return
            }

            if let message = message {
                self.readerSession(session, didDetectNDEFs: [message])
                session.alertMessage = "Tag read successfully!"
                session.invalidate()
            }
        }
    }

    private func writeTag(_ tag: NFCNDEFTag, message: NFCNDEFMessage, session: NFCNDEFReaderSession) {
        tag.writeNDEF(message) { error in
            if let error = error {
                session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
            } else {
                session.alertMessage = "Tag written successfully!"
                session.invalidate()
            }
            self.pendingWrite = nil
        }
    }
}
