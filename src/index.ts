import { registerPlugin } from '@capacitor/core';
import type { NfcPlugin, NFCReadEvent, PluginListenerHandle } from './definitions';

const OriginalNfc = registerPlugin<NfcPlugin>('Nfc', {
  web: () => import('./web').then((m) => new m.NfcWeb()),
});

class NfcWrapper implements NfcPlugin {
  // The wrapped NfcPlugin instance
  private plugin: NfcPlugin;

  constructor(plugin: NfcPlugin) {
    this.plugin = plugin;
  }

  async startScan(options?: any): Promise<void> {
    return this.plugin.startScan(options);
  }

  async stopScan(): Promise<void> {
    return this.plugin.stopScan();
  }

  async write(options: any): Promise<void> {
    return this.plugin.write(options);
  }

  async isEnabled(): Promise<{ enabled: boolean }> {
    return this.plugin.isEnabled();
  }

  addListener(
    eventName: 'nfcTagRead',
    listenerFunc: (event: NFCReadEvent) => void
  ): Promise<PluginListenerHandle> & PluginListenerHandle {
    // Wrap the listener function to process the event data
    const wrappedListener = (event: NFCReadEvent) => {
      // Process the event data here
      if (event && event.message && event.message.records) {
        for (const record of event.message.records) {
          if (Array.isArray(record.data)) {
            // Convert Array<number> to DataView
            const dataArray = new Uint8Array(record.data);
            record.data = new DataView(dataArray.buffer);
          }
        }
      }
      // Pass the processed event to the original listener
      listenerFunc(event);
    };

    // Call the original addListener with the wrapped listener function
    const handle = this.plugin.addListener(eventName, wrappedListener);

    // Return the handle as is
    return handle;
  }

  async removeAllListeners(): Promise<void> {
    return this.plugin.removeAllListeners();
  }
}

const Nfc = new NfcWrapper(OriginalNfc);

export * from './definitions';
export { Nfc };