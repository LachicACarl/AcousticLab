# AcousticLab / IEMA

A Flutter-based audio companion app targeting Android and iOS. The repository includes an existing IEMA audio interface and a BLE Central foundation for communicating with compatible Bluetooth Low Energy accessories.

## Current technology

- Flutter / Dart
- Existing audio playback via `just_audio`
- BLE GATT discovery and I/O via `flutter_blue_plus`

## Quick start (Windows)

```powershell
flutter doctor -v
git clone https://github.com/LachicACarl/AcousticLab.git
cd AcousticLab
git switch feat/bluetooth-companion-foundation
flutter pub get
flutter analyze
flutter test
flutter run
```

Connect an Android phone with USB debugging enabled, or use an Android emulator. iOS builds require Xcode on macOS or a cloud macOS build service.

## BLE foundation

See [Mobile App Build Guide](docs/Mobile_App_Build_Guide.md) for setup, permissions, architecture, testing, and release steps.

The generic BLE service currently supports scan, connect/disconnect, GATT service discovery, and characteristic reads/writes. Earbud-specific ANC, EQ, battery, gesture, and firmware controls require the exact supported device protocol. Ordinary Bluetooth audio streaming remains managed by the phone's audio stack.

## Important

The repository is intentionally kept on Flutter. The BLE foundation is a first phase and has not yet been validated against a specific earbud model on real iOS and Android hardware.
