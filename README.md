# @trentrand/capacitor-nfc

Capacitor plugin to scan NFC tags

## Install

```bash
npm install @trentrand/capacitor-nfc
npx cap sync
```

## API

<docgen-index>

* [`startScan(...)`](#startscan)
* [`stopScan()`](#stopscan)
* [`write(...)`](#write)
* [`isEnabled()`](#isenabled)
* [`addListener('nfcTagRead', ...)`](#addlistenernfctagread-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startScan(...)

```typescript
startScan(options?: NFCScanOptions | undefined) => Promise<void>
```

Start scanning for NFC tags.

| Param         | Type                                                      | Description                 |
| ------------- | --------------------------------------------------------- | --------------------------- |
| **`options`** | <code><a href="#nfcscanoptions">NFCScanOptions</a></code> | Optional scan configuration |

--------------------


### stopScan()

```typescript
stopScan() => Promise<void>
```

Stop scanning for NFC tags.

--------------------


### write(...)

```typescript
write(options: NFCWriteOptions) => Promise<void>
```

Write data to an NFC tag.

| Param         | Type                                                        | Description                                        |
| ------------- | ----------------------------------------------------------- | -------------------------------------------------- |
| **`options`** | <code><a href="#nfcwriteoptions">NFCWriteOptions</a></code> | Write configuration including the records to write |

--------------------


### isEnabled()

```typescript
isEnabled() => Promise<{ enabled: boolean; }>
```

Check if NFC is available and enabled on the device.

**Returns:** <code>Promise&lt;{ enabled: boolean; }&gt;</code>

--------------------


### addListener('nfcTagRead', ...)

```typescript
addListener(eventName: 'nfcTagRead', listenerFunc: (event: NFCReadEvent) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Add a listener for NFC events.

| Param              | Type                                                                      | Description                     |
| ------------------ | ------------------------------------------------------------------------- | ------------------------------- |
| **`eventName`**    | <code>'nfcTagRead'</code>                                                 | Name of the event to listen for |
| **`listenerFunc`** | <code>(event: <a href="#nfcreadevent">NFCReadEvent</a>) =&gt; void</code> | Callback function               |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

Remove all listeners for NFC events.

--------------------


### Interfaces


#### NFCScanOptions

| Prop          | Type                |
| ------------- | ------------------- |
| **`timeout`** | <code>number</code> |


#### NFCWriteOptions

| Prop          | Type                     |
| ------------- | ------------------------ |
| **`records`** | <code>NFCRecord[]</code> |
| **`timeout`** | <code>number</code>      |


#### NFCRecord

| Prop             | Type                  |
| ---------------- | --------------------- |
| **`recordType`** | <code>string</code>   |
| **`mediaType`**  | <code>string</code>   |
| **`data`**       | <code>number[]</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### NFCReadEvent

| Prop               | Type                                              |
| ------------------ | ------------------------------------------------- |
| **`message`**      | <code><a href="#nfcmessage">NFCMessage</a></code> |
| **`serialNumber`** | <code>string</code>                               |


#### NFCMessage

| Prop          | Type                     |
| ------------- | ------------------------ |
| **`records`** | <code>NFCRecord[]</code> |

</docgen-api>
