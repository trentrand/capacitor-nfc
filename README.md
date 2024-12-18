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

| Prop             | Type                                          |
| ---------------- | --------------------------------------------- |
| **`recordType`** | <code>string</code>                           |
| **`mediaType`**  | <code>string</code>                           |
| **`data`**       | <code><a href="#dataview">DataView</a></code> |


#### DataView

| Prop             | Type                                                |
| ---------------- | --------------------------------------------------- |
| **`buffer`**     | <code><a href="#arraybuffer">ArrayBuffer</a></code> |
| **`byteLength`** | <code>number</code>                                 |
| **`byteOffset`** | <code>number</code>                                 |

| Method         | Signature                                                                           | Description                                                                                                                                                         |
| -------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **getFloat32** | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Float32 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset. |
| **getFloat64** | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Float64 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset. |
| **getInt8**    | (byteOffset: number) =&gt; number                                                   | Gets the Int8 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.    |
| **getInt16**   | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Int16 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.   |
| **getInt32**   | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Int32 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.   |
| **getUint8**   | (byteOffset: number) =&gt; number                                                   | Gets the Uint8 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.   |
| **getUint16**  | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Uint16 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.  |
| **getUint32**  | (byteOffset: number, littleEndian?: boolean \| undefined) =&gt; number              | Gets the Uint32 value at the specified byte offset from the start of the view. There is no alignment constraint; multi-byte values may be fetched from any offset.  |
| **setFloat32** | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Float32 value at the specified byte offset from the start of the view.                                                                                    |
| **setFloat64** | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Float64 value at the specified byte offset from the start of the view.                                                                                    |
| **setInt8**    | (byteOffset: number, value: number) =&gt; void                                      | Stores an Int8 value at the specified byte offset from the start of the view.                                                                                       |
| **setInt16**   | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Int16 value at the specified byte offset from the start of the view.                                                                                      |
| **setInt32**   | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Int32 value at the specified byte offset from the start of the view.                                                                                      |
| **setUint8**   | (byteOffset: number, value: number) =&gt; void                                      | Stores an Uint8 value at the specified byte offset from the start of the view.                                                                                      |
| **setUint16**  | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Uint16 value at the specified byte offset from the start of the view.                                                                                     |
| **setUint32**  | (byteOffset: number, value: number, littleEndian?: boolean \| undefined) =&gt; void | Stores an Uint32 value at the specified byte offset from the start of the view.                                                                                     |


#### ArrayBuffer

Represents a raw buffer of binary data, which is used to store data for the
different typed arrays. ArrayBuffers cannot be read from or written to directly,
but can be passed to a typed array or <a href="#dataview">DataView</a> Object to interpret the raw
buffer as needed.

| Prop             | Type                | Description                                                                     |
| ---------------- | ------------------- | ------------------------------------------------------------------------------- |
| **`byteLength`** | <code>number</code> | Read-only. The length of the <a href="#arraybuffer">ArrayBuffer</a> (in bytes). |

| Method    | Signature                                                                               | Description                                                     |
| --------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **slice** | (begin: number, end?: number \| undefined) =&gt; <a href="#arraybuffer">ArrayBuffer</a> | Returns a section of an <a href="#arraybuffer">ArrayBuffer</a>. |


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
