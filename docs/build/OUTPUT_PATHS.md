# Configured Executable Names and Output Paths

This page records the currently configured on-disk application names and the release output locations used by 2048 Nova. It complements the command-oriented platform guides.

## Android

Application ID:

```text
com.sanskarin.nova_2048
```

Release APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Profile APK:

```text
build/app/outputs/flutter-apk/app-profile.apk
```

Release Android App Bundle:

```text
build/app/outputs/bundle/release/app-release.aab
```

ABI-split APKs, when built with `--split-per-abi`, are written under:

```text
build/app/outputs/flutter-apk/
```

The exact split filenames/ABI set should be read from the generated directory.

## Windows

`windows/CMakeLists.txt` currently defines:

```cmake
set(BINARY_NAME "nova_2048")
```

Therefore the main release executable is expected to be:

```text
build/windows/x64/runner/Release/nova_2048.exe
```

It must remain with the rest of the generated `Release/` files. Do not distribute the EXE alone.

Repository qualification archive:

```text
nova-2048-windows-x64.zip
nova-2048-windows-x64.zip.sha256
```

## Linux

`linux/CMakeLists.txt` currently defines:

```cmake
set(BINARY_NAME "nova_2048")
set(APPLICATION_ID "com.sanskarin.nova2048")
```

The runnable copy produced by the install/bundle step is expected at:

```text
build/linux/x64/release/bundle/nova_2048
```

It must remain with the generated `lib/`, `data/`, and other bundle contents.

Repository qualification archive:

```text
nova-2048-linux-x64.tar.gz
nova-2048-linux-x64.tar.gz.sha256
```

## macOS

`macos/Runner/Configs/AppInfo.xcconfig` currently defines:

```text
PRODUCT_NAME = 2048 Nova
PRODUCT_BUNDLE_IDENTIFIER = com.sanskarin.nova2048
```

Release application bundle:

```text
build/macos/Build/Products/Release/2048 Nova.app
```

Repository qualification archive:

```text
nova-2048-macos-release.zip
nova-2048-macos-release.zip.sha256
```

Preserve the `.app` bundle structure.

## iOS

The iOS display/bundle name is configured as **2048 Nova** in `ios/Runner/Info.plist`. Hosted qualification builds use:

```bash
flutter build ios --release --no-codesign
```

and currently expect the generated application bundle under:

```text
build/ios/iphoneos/Runner.app
```

Repository qualification archive:

```text
nova-2048-ios-unsigned-release.zip
nova-2048-ios-unsigned-release.zip.sha256
```

A signed IPA created through `flutter build ipa --release` is written under:

```text
build/ios/ipa/
```

Exact IPA filename can depend on Xcode/export settings. The repository does not currently publish a signed IPA qualification artifact.

## Web / PWA

Web release output:

```text
build/web/
```

There is no single traditional executable file. The entire generated directory is the deployable artifact.

If archived manually, use an unambiguous name such as:

```text
nova-2048-web-release.zip
```

or:

```text
nova-2048-web-release.tar.gz
```

The permanent quality CI builds Web but does not currently upload a long-lived Web qualification archive.

## Source-of-truth rule

If an output name in this document conflicts with current runner/build configuration, the build configuration wins. Update this document in the same change whenever intentionally renaming:

- Android application/package identity;
- Windows `BINARY_NAME`;
- Linux `BINARY_NAME` or `APPLICATION_ID`;
- macOS `PRODUCT_NAME` or bundle identifier;
- iOS product/display/bundle configuration;
- CI qualification archive names/paths.

After any such change, rebuild the affected target and refresh release qualification evidence rather than treating a rename as documentation-only.