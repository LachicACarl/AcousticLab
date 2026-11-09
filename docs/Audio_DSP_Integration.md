# Audio DSP milestone: integration gate

The app now includes `lib/services/five_band_pcm_equalizer.dart`, a
stateful five-band peaking-biquad processor for decoded, interleaved float PCM.

**This is a DSP implementation, not an active playback graph.** Existing
`just_audio` playback does not automatically pass decoded PCM through this
processor. The dashboard's ambient choices and volume remain UI-only until
the playback integration below is completed. No system-wide audio effects
or Bluetooth hardware DSP are implied.

## Required next integration

1. Choose and verify a Flutter-compatible output engine that accepts custom
   processed PCM or exposes a verified native DSP/filter hook on both iOS
   and Android. Do not assume an arbitrary Flutter audio package can insert
   Dart callbacks into its real-time audio thread.
2. Decode or generate soundscape PCM and run it through the EQ **before**
   submitting it to the output device. Keep state per channel and per stream.
3. Avoid doing per-sample Dart allocation on a real-time audio callback:
   prefer native DSP, preallocated buffers, or worker-produced buffered audio.
4. Send active preset changes to the engine with coefficient smoothing or
   crossfades to avoid clicks. The current `updateGains` resets filter
   history, so it is **not** click-free live automation.
5. Connect the dashboard controls to actual play/pause, in-app gain, and
   playback state. Audio output route detection requires separate platform
   implementations and permissions/capability checks.
6. Test on physical iOS and Android hardware with Bluetooth headphones,
   interruptions, audio focus, background mode, and different sample rates.
   Verify spectrum response with recorded output or a loopback measurement.

## Existing DSP test coverage

`test/five_band_pcm_equalizer_test.dart` checks flat passthrough, measurable
60 Hz boost, and invalid input handling. These tests have been added but
**not executed** in this GitHub-only session.

Note: `16 kHz` is skipped for sample rates where it reaches/exceeds
Nyquist. For production, define precise band behavior at each sample rate.
