# Packages

| File | Unzip to | Note |
|---|---|---|
| `android-cts.zip` | `../android-cts-tools/` | Symlink to `cts-aosp/out/host/linux-x86/cts/android-cts.zip` (CTS with VSDK) |
| `android-vts-LA5.0-R23.zip` | `../android-vts-tools/` | VTS currently in the image |
| `android-vts-LA5.0-R22.zip`, `android-vts-LA5.0.zip`, `android-vts-LA4.0.zip` | — | Older VTS packages, not used |
| `android-cts-media-1.5.zip` | — | CTS media package, not unzipped into the image |

Run from this folder:

```bash
rm -rf ../android-cts-tools/android-cts
unzip -q -d ../android-cts-tools android-cts.zip

rm -rf ../android-vts-tools/android-vts
unzip -q -d ../android-vts-tools android-vts-LA5.0-R23.zip
```

The full release steps are in [cmds/DOCKER_CMDS.md](../../../cmds/DOCKER_CMDS.md).
