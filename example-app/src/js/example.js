import { Nfc } from '@trentrand/capacitor-nfc';

// UI Elements
const checkEnabledBtn = document.getElementById('checkEnabled');
const startScanBtn = document.getElementById('startScan');
const stopScanBtn = document.getElementById('stopScan');
const writeTagBtn = document.getElementById('writeTag');
const writeTextInput = document.getElementById('writeText');
const logElement = document.getElementById('log');

// Logging function
function log(message) {
  const timestamp = new Date().toLocaleTimeString();
  logElement.innerHTML += `[${timestamp}] ${message}\n`;
  logElement.scrollTop = logElement.scrollHeight;
}

// Clear log after 100 entries
function clearOldLogs() {
  const lines = logElement.innerHTML.split('\n');
  if (lines.length > 100) {
    logElement.innerHTML = lines.slice(-100).join('\n');
  }
}

// Check if NFC is enabled
checkEnabledBtn.addEventListener('click', async () => {
  try {
    const { enabled } = await Nfc.isEnabled();
    log(`NFC ${enabled ? 'is' : 'is not'} enabled`);
  } catch (error) {
    log(`Error checking NFC status: ${error.message}`);
  }
});

// Start NFC scan
startScanBtn.addEventListener('click', async () => {
  try {
    await Nfc.startScan();
    log('Started NFC scan');
    startScanBtn.disabled = true;
    stopScanBtn.disabled = false;
  } catch (error) {
    log(`Error starting NFC scan: ${error.message}`);
  }
});

// Stop NFC scan
stopScanBtn.addEventListener('click', async () => {
  try {
    await Nfc.stopScan();
    log('Stopped NFC scan');
    startScanBtn.disabled = false;
    stopScanBtn.disabled = true;
  } catch (error) {
    log(`Error stopping NFC scan: ${error.message}`);
  }
});

// Write to NFC tag
writeTagBtn.addEventListener('click', async () => {
  const text = writeTextInput.value;
  if (!text) {
    log('Please enter text to write');
    return;
  }

  try {
    const textEncoder = new TextEncoder();
    await Nfc.write({
      records: [{
        recordType: 'text/plain',
        data: textEncoder.encode(text)
      }]
    });
    log('Successfully wrote to NFC tag');
  } catch (error) {
    log(`Error writing to NFC tag: ${error.message}`);
  }
});

// Listen for NFC tag reads
let listenerHandle;
async function setupNfcListener() {
  try {
    listenerHandle = await Nfc.addListener('nfcTagRead', (event) => {
      const textDecoder = new TextDecoder();
      event.message.records.forEach((record, index) => {
        const text = textDecoder.decode(record.data);
        log(`Read NFC tag (Record ${index + 1}):`);
        log(`Type: ${record.recordType}`);
        log(`Data: ${text}`);
      });
    });
  } catch (error) {
    log(`Error setting up NFC listener: ${error.message}`);
  }
}

// Initialize
async function initialize() {
  try {
    const { enabled } = await Nfc.isEnabled();
    log(`NFC is ${enabled ? 'enabled' : 'disabled'}`);
    if (enabled) {
      await setupNfcListener();
    }
    stopScanBtn.disabled = true;
  } catch (error) {
    log(`Initialization error: ${error.message}`);
  }
}

// Cleanup
window.addEventListener('beforeunload', async () => {
  if (listenerHandle) {
    await listenerHandle.remove();
  }
  await Nfc.removeAllListeners();
});

// Start the app
initialize();
