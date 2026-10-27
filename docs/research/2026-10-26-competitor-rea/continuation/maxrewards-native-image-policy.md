# MaxRewards Live Activity native image-filename policy

The selected native path accepts an optional image string through `URL(string:)`, derives a SHA-256 based PNG filename, and resolves it under the App Group's **`LiveActivityCardImagesV3`** directory. A file-existence hit returns the filename immediately. A miss uses `URLSession.shared`, requests a thumbnail with maximum pixel size **240**, converts it to PNG, writes it, and returns the filename only on success. Missing/invalid input, unavailable shared directory, download error, failed image conversion, or write error return nil. This finite path contains no app-level file-age/TTL check, cache eviction, or explicit HTTP status/MIME gate.

This is shipped-code static analysis of the acquired **iPhoneOS MaxRewardsLiveActivity 4.8.35 / build 1792099341** extension, bundle `com.max.MaxRewards.MaxRewardsLiveActivity`, SHA-256 **`6801204ee710b2b4bbfd50cf8b57b0816601c6b9a734be445d149ef55aa640e3`**. Addresses are unslid virtual addresses in that carrier. The completed `native-row-preparation` outputs and all prior manifests remain unchanged. No image URL, file cache, App Group directory, network request, device, or target code was executed or accessed. No Ghidra import or whole-app producer was repeated.

**MRNI-01 — URL input and deterministic filename derivation.** The already-retained child entry `0x100046f04` takes the optional `cardImage` string and switches to already-retained body `0x100047034`. A missing optional string branches at `0x10004706c` to its nil result. For a present string, `0x1000470b0` calls the import bound to `Foundation.URL.init(string:)`. The optional-URL tag test at `0x1000470d8–0x1000470e0` rejects a failed constructor result. The selected function adds no separate scheme, host, extension, or empty-string predicate; acceptance beyond the optional/constructor test follows Foundation behavior and is not inferred by executing sample URLs.

The valid-input path passes the original string words to new filename helper **`0x100050de4`** at `0x1000471b0`. That helper obtains the string's UTF-8 view (`0x100050e8c`), constructs Data from that sequence (`0x100050eb4`), and calls the import bound to `CryptoKit.HashFunction.hash(data:)` at **`0x100050ef0`**, with exact `SHA256` / `SHA256Digest` metadata obtained at `0x100050e1c` and `0x100050e7c`.

It supplies byte-to-string callback **`0x1000527ec`** to generic collection helper `0x10004f024` at `0x100050f34`. The callback loads one UInt8 and calls `String(format:_:)` with the exact clear literal **`%02x`** (`0x100052810–0x10005288c`). Helper `0x100052934` returns an empty string on both of its branches, and `0x100050f84` calls `joined(separator:)` with that separator. The caller appends clear suffix **`.png`** at `0x1000471fc–0x100047244`.

Observation: the SHA-256 input, hex-format byte callback, empty separator, and PNG suffix are concrete. **ABI/data-flow inference:** the resulting filename is `lowercaseHex(SHA256(UTF8(original cardImage string))) + ".png"`. Hashing uses the supplied string, rather than a read of `URL.absoluteString`; no URL normalization step is observed before the hash. The large generic collection helper's internals were not expanded in this pass; the digest/callback/join connection is reported as an inference, rather than claiming recovery of that generic implementation.

**MRNI-02 — App Group directory, cache hit, and expiry boundary.** Path helper **`0x100050fd8`** receives the generated filename. At `0x100051148`, it uses the existing group getter `0x100042cbc`, already bound to **`group.com.MaxRewards`** in the previous native dossier. The helper sends `containerURLForSecurityApplicationGroupIdentifier:` at `0x10005118c`. A missing container URL is represented as Optional<URL>.none and returns nil; this path does not substitute another directory.

The successful path calls tiny directory-name getter `0x100042d84` at `0x100051290`; its initializer **`0x100042d44`** stores clear literal **`LiveActivityCardImagesV3`** (`0x10005e320`). It appends this as a directory via `URL.appendingPathComponent(_:isDirectory:)` at `0x1000512d4` with the directory flag true. At `0x10005138c`, it sends:

```text
createDirectoryAtURL:withIntermediateDirectories:attributes:error:
```

The intermediate-directories flag is true, attributes are nil, and an error out pointer is provided. A false result follows `0x1000513fc → 0x1000514bc`, handles the error and returns nil. On success it appends the supplied filename at `0x100051414` and returns that URL. The concrete path derivation is therefore App Group container / `LiveActivityCardImagesV3` / generated filename. These are shipped instructions; no directory was created by the investigation.

Back in reused `0x100047034`, the final URL's `path` is passed to `fileExistsAtPath:` at **`0x100047310`**. The Bool test at `0x100047350` sends a miss to the download path. A hit at `0x100047358–0x1000473b8` returns the generated filename through the common optional-string result. This hit path does not decode the existing file, check its size/content, inspect modification dates, or contact the server.

The selected path has no app-level date/age/TTL comparison, expired-file branch, count/size eviction, directory enumeration, or file removal. `V3` is an observed namespace literal; it is not a measured expiry interval. `URLSession.shared` may apply system cache behavior outside this function; this report does not claim those framework defaults have been recovered, or that other app paths never clean this directory.

**MRNI-03 — Download, response handling, image conversion, and write result.** On a cache miss, reused body `0x100047034` obtains `URLSession.shared` (`0x1000473d0`) and calls the import bound to `URLSession.data(from:delegate:) async throws` at **`0x100047448`**, with delegate nil. No custom request, explicit timeout, cache policy, headers, or retry loop is constructed in the selected app code.

The installed continuation **`0x100047550`** stores the result and tests the async Swift error register at **`0x1000475b4`**. With an error it switches to new **`0x100047f24`**, which releases the error and returns optional-string nil at `0x100048050–0x100048064`. With no error it switches to new **`0x100047618`**. ABI-grounded interpretation of the returned tuple identifies the two Data words and response object: the response saved at frame `+0x120` is released immediately at `0x100047638–0x10004766c`. The selected success body does not cast to HTTPURLResponse, inspect `statusCode`, or read MIME/content headers before using the Data.

The success body bridges Data to NSData and calls **`CGImageSourceCreateWithData`** at `0x100047690`, with options nil. A nil source branches to a nil filename result. It then builds the exact thumbnail options:

| Imported key | Supplied value |
| --- | --- |
| `kCGImageSourceCreateThumbnailFromImageIfAbsent` | true |
| `kCGImageSourceCreateThumbnailWithTransform` | true |
| `kCGImageSourceShouldCacheImmediately` | true |
| `kCGImageSourceThumbnailMaxPixelSize` | NSNumber(integer: **240**) |

The value 240 is materialized at `0x10004780c`; tiny helpers `0x1000515d0 → 0x10005624c` bind it to selector `initWithInteger:`. The dictionary is bridged and passed to **`CGImageSourceCreateThumbnailAtIndex`** at `0x1000478b4`, with index zero. A nil thumbnail leads to nil. Tiny helpers `0x10005170c → 0x100056270` wrap the thumbnail with **`UIImage.initWithCGImage:`**, then **`UIImagePNGRepresentation`** is called at `0x100047940`. A nil PNG result also leads to nil; the original downloaded Data is not used as a fallback image-file write.

For PNG Data, **`Data.write(to:options:)`** is called at **`0x100047b00`**, using the resolved file URL and raw options value **1** (`0x100047af8–0x100047afc`). The interpretation of Foundation's raw value 1 as atomic writing is an ABI inference. The Swift write-error check is retained at **`0x100047b08`**: error branches to `0x100047dec`, handles/releases the error and returns nil; success returns the generated filename at `0x100047bec–0x100047bf8`. No local retry is present in these completed paths.

**MRNI-04 — Displayed-image implications and limits.** This closes the three previously named reachable bodies and their necessary tiny constants/format/bridge/async continuations. Image decode, requested maximum thumbnail pixel size, and PNG encoding are now concrete. It does not establish a successful download, actual cache contents, or an OS render event. The reused row-preparation pass already shows that a provided `cardImageFileName` bypasses this image helper, while a nil result from this helper still retains the row. Consequently this helper's success/failure governs the supplied filename, rather than row ranking or row cardinality.

Every newly interpreted function body and selected static literal/selector/import-binding span is outside the declared encrypted file interval **`[0x5a000,0x5b000)`**. Imported stub bodies inside that interval remain excluded. API names are corroborated through clear indirect-symbol/nlist/string metadata; Core Graphics option keys are bound through clear chained import pointers. No encrypted instructions, decryption or FairPlay bypass is used.

`evidence.json` retains the new source spans, instruction anchors and hashes, the exact reused row-preparation regions, field/selector/import bindings, and observations/inferences/limits. `validation.json` rechecks the completed row-preparation and earlier manifests without rewriting them. The generic map helper remains the expressly identified implementation-level limit; framework URL parsing/network-cache behavior and unrelated cleanup/render callers remain outside this finite image-policy pass.
