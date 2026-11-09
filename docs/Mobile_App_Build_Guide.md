# AcousticLab — Bluetooth Earbud Companion

## Project direction

AcousticLab is already a Flutter application. Continue with Flutter/Dart rather than replacing it with React Native/Expo. One Flutter codebase can target Android and iOS, and this repository already contains the platform folders and an existing IEMA audio UI.

The BLE integration in this phase uses `flutter_blue_plus` as a BLE **Central**. It provides generic BLE discovery, GATT connection, service discovery, characteristic reads, and characteristic writes. It does not automatically implement proprietary earbud features.

> **Important compatibility boundary:** Ordinary Bluetooth audio playback is usually handled by the phone's Bluetooth audio stack (A2DP/HFP), not by a custom BLE GATT connection. An app can only control ANC, EQ, touch gestures, battery reporting, firmware, or similar features when the specific earbud exposes a documented or reverse-engineered BLE GATT protocol and the platform permits access. The generic app cannot promise AirPods/brand-specific controls just because it can connect over BLE.

## Repository architecture

```
AcousticLab/
├── lib/
│   ├── main.dart                  # Existing IEMA application UI
│   ├── screens/                   # Existing app screens
│   ├── services/
│   │   ├── audio_service.dart     # Existing audio playback
│   │   └── bluetooth_service.dart # BLE scan/connect/GATT foundation
│   └── models/
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/
│   └── Runner/Info.plist
├── docs/
│   └── Mobile_App_Build_Guide.md
└── pubspec.yaml
```

## 1. Windows development setup

Install the following on Windows:

1. Flutter stable SDK and add `<flutter-sdk>\\bin` to PATH.
2. Android Studio, Android SDK Platform Tools, and an Android emulator or physical Android device.
3. Visual Studio Code with Flutter and Dart extensions.
4. Git for Windows.

Verify:

```powershell
flutter doctor -v
flutter --version
dart --version
git --version
```

Open the repository:

```powershell
git clone https://github.com/LachicACarl/AcousticLab.git
cd AcousticLab
git switch feat/bluetooth-companion-foundation
flutter pub get
flutter analyze
flutter test
```

For a physical Android phone, enable Developer Options and USB debugging, connect by USB, accept the debugging prompt, and verify with `flutter devices`. You can also use Android wireless debugging on the same network.

## 2. BLE package

This project adds the Flutter package `flutter_blue_plus`. Keep the version pinned in `pubspec.yaml` so plugin updates do not silently change APIs. After checkout run:

```powershell
flutter pub get
```

The service is at `lib/services/bluetooth_service.dart`.

Implemented generic building blocks:
- Bluetooth adapter state check.
- Scan with a timeout and stream scan results.
- Connect/disconnect to a selected BLE peripheral.
- Discover GATT services and characteristic capabilities.
- Read characteristics that advertise read support.
- Write characteristics that advertise write support.

Use only UUIDs and command payloads confirmed for the target earbud. Do not write guessed bytes to undocumented characteristics.

## 3. Android permissions

The manifest includes:
- BLE hardware feature declaration (optional so non-BLE Android devices can still install).
- Android 12+ `BLUETOOTH_SCAN` with `neverForLocation`.
- Android 12+ `BLUETOOTH_CONNECT`.
- Legacy Bluetooth permissions capped at API 30.
- Fine location capped at API 30 for legacy scanning behavior.

Android 12+ requires runtime permission approval for nearby-device access. Test permission denial, revocation in Settings, Bluetooth disabled, and location-off behavior on older Android versions. Do not request location unless the app genuinely uses it.

The BLE plugin supports Android API 21 and later; ensure the effective min SDK is at least 21 if the resolved plugin/toolchain requires it.

## 4. iOS permissions and testing

The iOS Info.plist contains `NSBluetoothAlwaysUsageDescription` with a clear user-facing purpose. iOS will show the Bluetooth permission prompt when the app first accesses CoreBluetooth.

To test on a physical iPhone:
- Install/run the app from a Mac with Xcode, or configure a cloud macOS builder such as Codemagic.
- Use a development build signed for your device.
- Enable Bluetooth and accept the permission prompt.
- Test with the app in foreground first.

**Windows cannot run Xcode or locally compile/sign an iOS app.** You can edit Flutter code on Windows and build iOS in a cloud macOS environment, but a real iPhone installation requires a correctly signed build. Expo Go is not relevant to this Flutter repository.

Do not enable background BLE mode unless the product has a specific background use case. Background Bluetooth has lifecycle, time, and App Store review constraints.

## 5. Cloud iOS builds

Codemagic can build Flutter projects using macOS build machines. A typical unsigned validation sequence is:

```bash
flutter pub get
flutter analyze
flutter test
flutter build ios --debug --no-codesign
```

For a distributable IPA, configure Apple Developer signing credentials in Codemagic and use a release workflow. Never commit certificates, private keys, provisioning profiles, API keys, or passwords into Git.

For Android release builds:

```bash
flutter build appbundle --release
```

Configure an upload keystore securely in CI before publishing to Google Play.

## 6. Earbud protocol discovery checklist

Before implementing ANC/EQ/battery/touch controls, collect:

1. Exact earbud make, model, and hardware revision.
2. Whether it advertises a BLE peripheral independently of the A2DP audio connection.
3. Advertisement name and manufacturer data (avoid sharing personal device identifiers publicly).
4. GATT service UUIDs and characteristic UUIDs.
5. Characteristic properties: read, write, write without response, notify, indicate.
6. Documented command framing, checksums, encryption/authentication, and response format.
7. Whether commands differ for left bud, right bud, and charging case.

A generic GATT browser can reveal exposed services, but discovery alone does not reveal proprietary command semantics. Use manufacturer documentation or protocol authorization; do not bypass pairing, authentication, or encryption protections.

## 7. Recommended build milestones

### Milestone A — BLE foundation
- Permission and adapter-state handling.
- Scan results UI with device name, ID, and RSSI.
- Connect/disconnect and connection status.
- GATT service/characteristic inspector.
- Error and empty states.

### Milestone B — Earbud-specific integration
- Capture a sanitized GATT inventory for the exact device.
- Define a typed protocol adapter per supported model.
- Implement only confirmed operations.
- Add timeouts, retries, disconnect cleanup, and tests using mocked devices.

### Milestone C — Product features
- Battery (only if exposed).
- ANC/transparency modes (only if documented by the device).
- EQ profile persistence and apply (only if the earbud supports it; software EQ may instead process app playback only).
- Touch controls and firmware update (firmware update requires a vendor-grade, safety-reviewed protocol).

### Milestone D — Distribution
- Android internal test track, then production.
- iOS TestFlight, then App Store review.
- Privacy policy describing Bluetooth scanning and any collected telemetry.
- Device compatibility matrix and clear unsupported-feature messaging.

## 8. Test matrix

| Scenario | Expected behavior |
|---|---|
| Bluetooth off | Explain that Bluetooth must be enabled; do not crash |
| Permission denied | Show a permission explanation and recovery path |
| No BLE devices nearby | Empty scan state |
| Device found | Show name (or generic ID) and RSSI |
| Connect timeout | Display error and allow retry |
| Device disconnects | Clear active connection state |
| Service has read-only characteristics | Disable write action |
| Unknown vendor UUID | Display metadata only; do not issue commands |
| iOS and Android | Verify independently on physical hardware |

## 9. Security and privacy

- Never log raw payloads if they contain identifiers or sensitive user data.
- Do not store device MAC addresses as user identity.
- Do not send scans to a server by default.
- Keep BLE command payloads model-specific and validated.
- Do not store signing keys or service credentials in source control.
- Make permission rationale clear and accurate.

## 10. Useful references

- FlutterBluePlus API and setup: https://pub.dev/documentation/flutter_blue_plus/latest/
- Flutter iOS deployment: https://docs.flutter.dev/deployment/ios
- Codemagic Flutter builds: https://docs.codemagic.io/flutter-configuration/flutter-projects/
- Apple Bluetooth usage description: https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSBluetoothAlwaysUsageDescription

## Current phase status

This branch provides the project-specific architecture guide, BLE service foundation, and platform permission declarations. It does **not** yet connect to a known earbud model from the UI or send ANC/EQ commands. That next step requires the exact earbud model and its GATT protocol. Test on real Android/iOS hardware before treating BLE support as production-ready.


## 11. Software companion UI milestone

The app now routes its Home tab to `DashboardScreen` and its EQ tab to `EqualizerScreen`.

- The dashboard explains that the phone's system Bluetooth settings manage pairing and output routing.
- Ambient soundscape choices are UI placeholders until audio assets and playback are added.
- Five-band EQ profiles (60 Hz, 250 Hz, 1 kHz, 4 kHz, 16 kHz) can be selected, adjusted, and saved locally with `shared_preferences`.
- The saved EQ values are currently profile state, not a completed cross-platform audio DSP effect.

### Platform audio limits

Do not describe this app as a system-wide equalizer. iOS does not provide third-party apps a public API to apply an EQ to audio from every other app. Android's platform `Equalizer` effect is associated with an audio session and does not grant unrestricted processing of all device audio. A portable equalizer must process audio that IEMA itself decodes/plays, using a DSP implementation supported on each target platform. The current UI deliberately labels the scope as IEMA in-app audio.

Similarly, standard public mobile APIs do not guarantee that an app can enumerate every connected Bluetooth output device and retrieve all metadata on both platforms. The operating system remains responsible for Bluetooth pairing and routing. IEMA should not promise universal device battery, ANC, transparency, or touch remapping.
