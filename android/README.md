# android

android part of alp - android-linux-pam

## local network permission

The app targets Android 17 (API 37) and therefore declares and requests
`android.permission.ACCESS_LOCAL_NETWORK` (shown to users as part of the
**Nearby devices** permission group). It is required because the Linux client
connects to the REST server that runs on the phone, so a system device picker
cannot provide the same core functionality.

If the permission is denied, the server still starts, but Android blocks its
local network traffic. The permission can be granted again from the app's
settings screen or from *Settings > Apps > alp > Permissions > Nearby devices*.

When publishing to Google Play, submit the local network permission declaration
in Play Console and explain that this is a LAN-only client/server
authentication app whose core functionality depends on incoming connections
from the user's own Linux machine.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## re-creation command
The basic structure of this project was generated with the following command
```
flutter create --platforms android --platforms web --template app --org io.github.gernotfeichter.alp .
```

## release

1. bump the version in [pubspec.yaml](pubspec.yaml)
    ```
    flutter build appbundle --release
    ```
2. Test install
    ```
    rm build/app/outputs/bundle/release/app-release.apks || true
    bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=build/app/outputs/bundle/release/app-release.apks
    adb uninstall io.github.gernotfeichter.alp
    bundletool install-apks --apks=build/app/outputs/bundle/release/app-release.apks
    ```

3. Upload build/app/outputs/bundle/release/app-release.aab to https://play.google.com/console
4. `g commit -a -m "chore(android): release <version>"`
5. `g push`
