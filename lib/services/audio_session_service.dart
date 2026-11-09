import 'dart:async';

import 'package:audio_session/audio_session.dart';

/// Owns app-wide audio focus and interruption subscriptions for IEMA playback.
/// It intentionally pauses on route removal rather than switching to speaker.
class AudioSessionService {
  AudioSessionService._();
  static final instance = AudioSessionService._();

  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _noisySubscription;
  Future<void>? _initializing;
  Future<bool> Function()? onPause;
  Future<void> Function()? onResume;
  void Function(bool ducked)? onDuckChanged;

  bool _wasPlayingBeforeInterruption = false;
  bool _isDucked = false;
  bool _active = false;

  bool get isDucked => _isDucked;

  Future<void> initialize({
    required Future<void> Function() pause,
    required Future<void> Function() resume,
    required void Function(bool ducked) onDuck,
  }) async {
    onPause = pause;
    onResume = resume;
    onDuckChanged = onDuck;
    if (_session != null) return;
    _initializing ??= _configure();
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _configure() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _session = session;
    _interruptionSubscription =
        session.interruptionEventStream.listen(_handleInterruption);
    _noisySubscription = session.becomingNoisyEventStream.listen((_) async {
      // Headphones were unplugged/disconnected. Never continue through speaker.
      _wasPlayingBeforeInterruption = false;
      await onPause?.call();
      await deactivate();
    });
  }

  Future<void> activate() async {
    final session = _session;
    if (session == null || _active) return;
    final granted = await session.setActive(true);
    if (!granted) {
      throw StateError('The operating system did not grant audio focus.');
    }
    _active = true;
  }

  Future<void> deactivate() async {
    final session = _session;
    if (session == null || !_active) return;
    _active = false;
    await session.setActive(false);
  }

  Future<void> _handleInterruption(AudioInterruptionEvent event) async {
    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _isDucked = true;
          onDuckChanged?.call(true);
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          _wasPlayingBeforeInterruption = await onPause?.call() ?? false;
          break;
      }
      return;
    }

    switch (event.type) {
      case AudioInterruptionType.duck:
        _isDucked = false;
        onDuckChanged?.call(false);
        break;
      case AudioInterruptionType.pause:
        if (_wasPlayingBeforeInterruption) {
          _wasPlayingBeforeInterruption = false;
          await onResume?.call();
        }
        break;
      case AudioInterruptionType.unknown:
        // Unknown interruption end is not permission to restart audio.
        _wasPlayingBeforeInterruption = false;
        break;
    }
  }

  Future<void> dispose() async {
    await _interruptionSubscription?.cancel();
    await _noisySubscription?.cancel();
    _interruptionSubscription = null;
    _noisySubscription = null;
    await deactivate();
    _session = null;
  }
}
