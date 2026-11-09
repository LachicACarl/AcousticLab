# Audio DSP pipeline

## Implemented

- `audio_stream_player: ^1.1.0` provides raw PCM playback through native Android AudioTrack and iOS AVAudioEngine output.
- `DspAudioPipeline` generates stereo 48 kHz ambient PCM (white noise, filtered rain-like noise, and soft-focus noise), processes each chunk through the custom five-band peaking biquad chain, converts it to signed 16-bit little-endian PCM, and feeds the native stream player.
- Dashboard soundscape chips start/stop generated audio; pause/resume and in-app ambient gain are connected.
- EQ preset selection and slider movement update the running DSP processor. A 100 ms parallel crossfade reduces abrupt changes, but cannot guarantee click-free behavior on every device or under underrun/load conditions.

## Important scope

This processes only audio generated and played by IEMA. It does not EQ other apps, change phone system volume, or control headphone DSP/ANC. "Rain" and "Soft focus" are synthesized noise textures, not recorded rain or music. Device route detection, audio focus policy, interruption recovery, and background media session are not wired yet.

## Validation still required

- Run `flutter pub get`, `flutter analyze`, and `flutter test`.
- Verify package native builds on Android and iOS (iOS requires macOS/Xcode or a cloud macOS builder).
- Test physical devices and Bluetooth output: repeated start/stop, pause/resume, live slider changes, interruptions, route changes, and long-running memory/buffer behavior.
- Measure frequency response with known test tones or loopback recording. Simulator output is not a substitute for physical-device verification.

The existing PCM math tests remain in `test/five_band_pcm_equalizer_test.dart`.
