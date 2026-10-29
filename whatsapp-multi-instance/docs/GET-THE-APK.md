# Getting the WhatsApp installer

You need to download WhatsApp yourself. This repo doesn't include it.

## Why not `wget`?

`whatsapp.com/android/current/WhatsApp.apk` redirects scripts to an "unsupported browser" web page. You end up with a ~49 KB HTML file, and installing it fails with `INSTALL_PARSE_FAILED_NOT_APK`. Download with a browser instead.

## Steps (APKMirror)

1. Open <https://www.apkmirror.com/apk/whatsapp-inc/whatsapp-messenger/>
   (don't use the search box with filters, it often shows "No results").
2. Choose the newest release **without "beta" in the name** (stable is safer).
3. Scroll to the variants table and pick the row with architecture **universal** (or one listing **x86_64**).
   - `arm64-v8a` only will **not** run on these x86_64 instances.
   - `BUNDLE` is fine. It's a `.apkm` file, which `wam` understands.
4. Click it → **Download APK** → wait for the file to finish.
5. Find it:
   ```bash
   find ~ -iname "*whatsapp*.apk*" 2>/dev/null
   ```
   Browsers sometimes save into a subfolder.

## Install

```bash
wam install /full/path/to/com.whatsapp_....apkm 1 2 3
```

A good download is roughly 60–150 MB. If yours is a few KB, it's a web page: delete it and download again.

## Check the file (optional)

```bash
file yourfile.apkm      # should say "Zip archive"
```

APKMirror verifies signatures, but you can also compare the APK signature with the official one using `apksigner verify --print-certs`.

## Updating WhatsApp later

Download the newer bundle and run the same command again: `wam install newfile.apkm all`. `-r` keeps each account's data.
