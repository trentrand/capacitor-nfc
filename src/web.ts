import { WebPlugin } from '@capacitor/core';
import type { NfcPlugin, NFCReadEvent, NFCWriteOptions, NFCScanOptions, PluginListenerHandle } from './definitions';

export class NfcWeb extends WebPlugin implements NfcPlugin {
  private reader: any = null;
  private isScanning: boolean = false;

  async startScan(options?: NFCScanOptions): Promise<void> {
    if (!('NDEFReader' in window)) {
      throw this.unavailable('Web NFC is not supported on this browser');
    }

    if (this.isScanning) {
      return;
    }

    try {
      this.reader = new (window as any).NDEFReader();
      const controller = options?.timeout ? new AbortController() : undefined;
      if (controller && options?.timeout) {
        setTimeout(() => controller.abort(), options.timeout);
      }
      await this.reader.scan({ signal: controller?.signal });
      this.isScanning = true;

      this.reader.addEventListener('reading', (event: any) => {
        const nfcEvent: NFCReadEvent = {
          serialNumber: event.serialNumber,
          message: {
            records: event.message.records.map((record: any) => ({
              recordType: record.recordType,
              mediaType: record.mediaType,
              data: record.data
            }))
          }
        };
        this.notifyListeners('nfcTagRead', nfcEvent);
      });

    } catch (error: any) {
      throw new Error('Failed to start NFC scan: ' + error.message);
    }
  }

  async stopScan(): Promise<void> {
    if (this.reader && this.isScanning) {
      // Currently, the Web NFC API doesn't have a direct method to stop scanning
      // We'll set our flag to false and null out the reader
      this.isScanning = false;
      this.reader = null;
    }
  }

  async write(options: NFCWriteOptions): Promise<void> {
    if (!('NDEFReader' in window)) {
      throw this.unavailable('Web NFC is not supported on this browser');
    }

    try {
      const writer = new (window as any).NDEFReader();
      const controller = options.timeout ? new AbortController() : undefined;
      if (controller && options.timeout) {
        setTimeout(() => controller.abort(), options.timeout);
      }
      await writer.write({
        records: options.records
      }, { signal: controller?.signal });
    } catch (error: any) {
      throw new Error('Failed to write to NFC tag: ' + error.message);
    }
  }

  async isEnabled(): Promise<{ enabled: boolean }> {
    const supported = 'NDEFReader' in window;
    return { enabled: supported };
  }

  addListener(
    eventName: 'nfcTagRead',
    listenerFunc: (event: NFCReadEvent) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle {
    const promise = super.addListener(eventName, listenerFunc);
    const remove = () => promise.then(handle => handle.remove());
    return Object.assign(promise, { remove });
  }

  async removeAllListeners(): Promise<void> {
    await super.removeAllListeners();
  }
}
