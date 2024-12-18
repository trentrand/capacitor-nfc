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
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near an NFC tag"
        session?.begin()
        
        call.resolve()
    }
    
    @objc func stopScan(_ call: CAPPluginCall) {
        session?.invalidate()
        session = nil
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
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Handle session invalidation
        notifyListeners("nfcError", data: ["message": error.localizedDescription])
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
            
            notifyListeners("nfcTagRead", data: [
                "message": ["records": records]
            ])
        }
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            if let pendingWrite = self.pendingWrite {
                // Write mode
                tag.queryNDEFStatus { status, capacity, error in
                    guard error == nil else {
                        session.invalidate(errorMessage: error!.localizedDescription)
                        return
                    }
                    
                    guard status == .readWrite else {
                        session.invalidate(errorMessage: "Tag is not writable")
                        return
                    }
                    
                    tag.writeNDEF(pendingWrite) { error in
                        if let error = error {
                            session.invalidate(errorMessage: error.localizedDescription)
                        } else {
                            session.alertMessage = "Write successful!"
                            session.invalidate()
                        }
                    }
                }
            } else {
                // Read mode
                tag.readNDEF { message, error in
                    if let error = error {
                        session.invalidate(errorMessage: error.localizedDescription)
                        return
                    }
                    
                    if let message = message {
                        self.readerSession(session, didDetectNDEFs: [message])
                    }
                    
                    session.alertMessage = "Read successful!"
                    session.invalidate()
                }
            }
        }
    }
}
