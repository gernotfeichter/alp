# android

android part of alp - android-linux-pam

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
flutter build appbundle
```
Then upload build/app/outputs/bundle/release/app-release.aab to https://play.google.com/console.