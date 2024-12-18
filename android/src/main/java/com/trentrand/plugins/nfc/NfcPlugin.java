package com.trentrand.plugins.nfc;

import android.app.Activity;
import android.nfc.FormatException;
import android.nfc.NfcAdapter;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.Tag;
import android.nfc.tech.Ndef;
import android.nfc.tech.NdefFormatable;
import android.os.Bundle;
import android.util.Log;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@CapacitorPlugin(name = "Nfc")
public class NfcPlugin extends Plugin {
    private static final String TAG = "NfcPlugin";
    private NfcAdapter nfcAdapter;
    private PluginCall pendingWriteCall;

    @Override
    public void load() {
        super.load();
        nfcAdapter = NfcAdapter.getDefaultAdapter(getContext());
    }

    @PluginMethod
    public void isEnabled(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("enabled", nfcAdapter != null && nfcAdapter.isEnabled());
        call.resolve(ret);
    }

    @PluginMethod
    public void startScan(PluginCall call) {
        if (nfcAdapter == null || !nfcAdapter.isEnabled()) {
            call.reject("NFC is not available or disabled");
            return;
        }

        Activity activity = getActivity();
        if (activity == null) {
            call.reject("Activity not available");
            return;
        }

        try {
            nfcAdapter.enableReaderMode(activity,
                    tag -> handleTag(tag, null),
                    NfcAdapter.FLAG_READER_NFC_A |
                    NfcAdapter.FLAG_READER_NFC_B |
                    NfcAdapter.FLAG_READER_NFC_F |
                    NfcAdapter.FLAG_READER_NFC_V |
                    NfcAdapter.FLAG_READER_NFC_BARCODE,
                    null);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to start NFC scan: " + e.getMessage());
        }
    }

    @PluginMethod
    public void stopScan(PluginCall call) {
        if (nfcAdapter != null) {
            Activity activity = getActivity();
            if (activity != null) {
                nfcAdapter.disableReaderMode(activity);
            }
        }
        call.resolve();
    }

    @PluginMethod
    public void write(PluginCall call) {
        if (nfcAdapter == null || !nfcAdapter.isEnabled()) {
            call.reject("NFC is not available or disabled");
            return;
        }

        JSArray recordsArray = call.getArray("records");
        if (recordsArray == null) {
            call.reject("No records provided");
            return;
        }

        try {
            pendingWriteCall = call;
            Activity activity = getActivity();
            if (activity == null) {
                call.reject("Activity not available");
                return;
            }

            nfcAdapter.enableReaderMode(activity,
                    tag -> handleTag(tag, recordsArray),
                    NfcAdapter.FLAG_READER_NFC_A |
                    NfcAdapter.FLAG_READER_NFC_B |
                    NfcAdapter.FLAG_READER_NFC_F |
                    NfcAdapter.FLAG_READER_NFC_V,
                    null);
        } catch (Exception e) {
            call.reject("Failed to start NFC write: " + e.getMessage());
        }
    }

    private void handleTag(Tag tag, JSArray writeRecords) {
        try {
            Ndef ndef = Ndef.get(tag);
            if (ndef != null) {
                ndef.connect();

                if (writeRecords != null) {
                    // Write mode
                    writeNdefMessage(ndef, writeRecords);
                } else {
                    // Read mode
                    NdefMessage ndefMessage = ndef.getNdefMessage();
                    if (ndefMessage != null) {
                        notifyTagRead(ndefMessage);
                    }
                }
                ndef.close();
            } else {
                // Try to format tag if NDEF is not supported and we're in write mode
                if (writeRecords != null) {
                    NdefFormatable format = NdefFormatable.get(tag);
                    if (format != null) {
                        try {
                            format.connect();
                            NdefMessage ndefMessage = createNdefMessage(writeRecords);
                            format.format(ndefMessage);
                            format.close();
                            if (pendingWriteCall != null) {
                                pendingWriteCall.resolve();
                            }
                        } catch (IOException e) {
                            if (pendingWriteCall != null) {
                                pendingWriteCall.reject("Failed to format tag: " + e.getMessage());
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error handling NFC tag", e);
            if (pendingWriteCall != null) {
                pendingWriteCall.reject("Error handling NFC tag: " + e.getMessage());
            }
        }
    }

    private void writeNdefMessage(Ndef ndef, JSArray records) throws JSONException, IOException, FormatException {
        if (!ndef.isWritable()) {
            if (pendingWriteCall != null) {
                pendingWriteCall.reject("Tag is not writable");
            }
            return;
        }

        NdefMessage ndefMessage = createNdefMessage(records);
        ndef.writeNdefMessage(ndefMessage);

        if (pendingWriteCall != null) {
            pendingWriteCall.resolve();
        }
    }

    private NdefMessage createNdefMessage(JSArray records) throws JSONException {
        List<NdefRecord> ndefRecords = new ArrayList<>();

        for (int i = 0; i < records.length(); i++) {
            JSObject record = JSObject.fromJSONObject(records.getJSONObject(i));
            if (record != null) {
                String recordType = record.getString("recordType");
                JSArray dataArray = (JSArray) record.get("myArray");
                if (dataArray != null) {
                    byte[] data = new byte[dataArray.length()];

                    for (int j = 0; j < dataArray.length(); j++) {
                        // Handle Integer or Long from get(j)
                        Object value = dataArray.get(j);
                        if (value instanceof Integer) {
                            data[j] = ((Integer) value).byteValue();
                        } else if (value instanceof Long) {
                            data[j] = ((Long) value).byteValue();
                        } else if (value instanceof Double) {
                            data[j] = ((Double) value).byteValue();
                        } else {
                            // Handle other types or set a default value
                            data[j] = 0; // Or throw an error, log, etc.
                        }
                    }

                    NdefRecord ndefRecord;
                    if ("text".equals(recordType)) {
                        ndefRecord = NdefRecord.createTextRecord("en", new String(data));
                    } else {
                        ndefRecord = new NdefRecord(
                                NdefRecord.TNF_MIME_MEDIA,
                                recordType.getBytes(),
                                new byte[0],
                                data);
                    }
                    ndefRecords.add(ndefRecord);
                }
            }
        }

        return new NdefMessage(ndefRecords.toArray(new NdefRecord[0]));
    }

    private void notifyTagRead(NdefMessage ndefMessage) {
        JSObject ret = new JSObject();
        JSArray records = new JSArray();

        for (NdefRecord record : ndefMessage.getRecords()) {
            JSObject recordObj = new JSObject();
            recordObj.put("recordType", new String(record.getType()));
            recordObj.put("mediaType", String.valueOf(record.getTnf()));

            byte[] payload = record.getPayload();
            JSArray data = new JSArray();
            for (byte b : payload) {
                data.put((int) b); // Add each byte as an integer to the JSArray
            }
            recordObj.put("data", data);

            records.put(recordObj);
        }

        JSObject message = new JSObject();
        message.put("records", records);
        ret.put("message", message);

        notifyListeners("nfcTagRead", ret);
    }
}
