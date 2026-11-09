# Audio session and interruption handling

## Implemented in this milestone

- `audio_session: ^0.2.4` configures the shared app audio session with
  `AudioSessionConfiguration.music()` before IEMA's PCM player starts.
- IEMA explicitly requests audio focus before starting native PCM playback.
- Interruption events of type `pause` or `unknown` pause the generator.
  Playback resumes only when it had actually been playing before the
  interruption; a user-paused stream is not automatically restarted.
- Duck interruptions reduce IEMA's PCM output gain to 25%, then restore the
  user's configured in-app gain when the interruption ends.
- `becomingNoisyEventStream` pauses playback and releases audio focus so a
  headphone unplug/disconnect does not intentionally continue through the
  built-in speaker.
- Stopping the PCM pipeline releases the audio focus request.

## Not yet implemented

- Background/lock-screen playback and media controls. iOS background audio
  mode alone is not sufficient; Android requires a correctly configured
  foreground media service. Integrate `audio_service` with a media handler
  that owns this PCM pipeline before claiming background playback support.
- A persistent Bluetooth route UI or battery/ANC metadata. The noisy event
  is a safety signal, not a full device inventory or a guarantee that every
  Bluetooth route change will emit the same event on every OS/device.
- Device-specific verification of focus, ducking, interruption resume,
  Bluetooth disconnect, and native player lifecycle.

## Validation checklist

Run on a development machine with Flutter installed:

```sh
flutter pub get
flutter analyze
flutter test
```

Then test physical Android and iOS devices with calls, Siri/assistant,
alarms, navigation prompts, Bluetooth disconnect/reconnect, wired headset
removal, manual pause during an interruption, and rapid start/stop.

No Flutter command or physical-device test has been run from this GitHub
connector session. Treat this as implementation committed for validation,
not as verified runtime behavior.
