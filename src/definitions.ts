import type { PluginListenerHandle } from '@capacitor/core';

export type { PluginListenerHandle };

export interface NFCRecord {
  recordType: string;
  mediaType?: string;
  data: Uint8Array;
}

export interface NFCMessage {
  records: NFCRecord[];
}

export interface NFCReadEvent {
  message: NFCMessage;
  serialNumber?: string;
}

export interface NFCWriteOptions {
  records: NFCRecord[];
  timeout?: number;
}

export interface NFCScanOptions {
  timeout?: number;
}

export interface NfcPlugin {
  /**
   * Start scanning for NFC tags.
   * @param options Optional scan configuration
   * @returns Promise that resolves when scanning starts
   */
  startScan(options?: NFCScanOptions): Promise<void>;

  /**
   * Stop scanning for NFC tags.
   */
  stopScan(): Promise<void>;

  /**
   * Write data to an NFC tag.
   * @param options Write configuration including the records to write
   */
  write(options: NFCWriteOptions): Promise<void>;

  /**
   * Check if NFC is available and enabled on the device.
   */
  isEnabled(): Promise<{ enabled: boolean }>;

  /**
   * Add a listener for NFC events.
   * @param eventName Name of the event to listen for
   * @param listenerFunc Callback function
   */
  addListener(
    eventName: 'nfcTagRead',
    listenerFunc: (event: NFCReadEvent) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Remove all listeners for NFC events.
   */
  removeAllListeners(): Promise<void>;
}
