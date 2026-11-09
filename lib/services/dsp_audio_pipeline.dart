import 'dart:math';
import 'dart:typed_data';

import 'package:audio_stream_player/audio_stream_player.dart';
import 'audio_session_service.dart';

import 'five_band_pcm_equalizer.dart';

/// Generates app-owned ambient PCM, processes it through the five-band DSP,
/// then streams signed 16-bit little-endian PCM to the native output engine.
class DspAudioPipeline {
  DspAudioPipeline._();
  static final instance = DspAudioPipeline._();

  static const double sampleRate = 48000.0;
  static const channels = 2;
  static const framesPerChunk = 960; // 20 ms
  static const _crossfadeFrames = 4800; // 100 ms
  final Random _random = Random();
  AudioStreamPlayer? _player;
  FiveBandPcmEqualizer _eq = FiveBandPcmEqualizer(
    sampleRate: sampleRate, channels: channels, gainsDb: [0.0, 0.0, 0.0, 0.0, 0.0]);
  FiveBandPcmEqualizer? _previousEq;
  int _crossfadeRemaining = 0;
  bool _running = false;
  bool _paused = false;
  String _soundscape = 'Off';
  double _volume = 0.65;
  double _duckMultiplier = 1.0;
  double _rainState = 0;
  double _softState = 0;

  bool get isPlaying => _running && !_paused;
  String get soundscape => _soundscape;
  double get volume => _volume;
  List<double> get gainsDb => _eq.gainsDb;

  Future<void> start(String soundscape) async {
    if (!['White noise', 'Rain', 'Soft focus'].contains(soundscape)) {
      await stop();
      return;
    }
    if (_running) {
      _soundscape = soundscape;
      await AudioSessionService.instance.activate();
      _paused = false;
      await _player?.play();
      return;
    }
    _soundscape = soundscape;
    final audioSession = AudioSessionService.instance;
    await audioSession.initialize(
      pause: _pauseForInterruption,
      resume: _resumeAfterInterruption,
      onDuck: (ducked) { _duckMultiplier = ducked ? 0.25 : 1.0; },
    );
    await audioSession.activate();
    final player = await AudioStreamPlayer.create(
      sampleRate: sampleRate,
      channels: channels,
      format: PcmFormat.s16le,
    );
    _player = player;
    _running = true;
    _paused = false;
    await player.play();
    _pump();
  }

  Future<void> pause() async {
    if (!_running || _paused) return;
    _paused = true;
    await _player?.pause();
  }

  Future<void> resume() async {
    if (!_running || !_paused) return;
    await AudioSessionService.instance.activate();
    _paused = false;
    await _player?.play();
  }

  Future<void> stop() async {
    _running = false;
    _paused = false;
    final player = _player;
    _player = null;
    if (player != null) {
      await player.stop();
      await player.dispose();
    }
    _soundscape = 'Off';
    await AudioSessionService.instance.deactivate();
  }

  Future<bool> _pauseForInterruption() async {
    if (!_running || _paused) return false;
    _paused = true;
    await _player?.pause();
    return true;
  }

  Future<void> _resumeAfterInterruption() async {
    if (!_running || !_paused) return;
    await AudioSessionService.instance.activate();
    _paused = false;
    await _player?.play();
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0).toDouble();
  }

  /// Replaces coefficients using a 100 ms parallel crossfade to avoid a
  /// discontinuity when the UI slider moves during playback.
  void updateGains(List<double> gainsDb) {
    final next = FiveBandPcmEqualizer(
      sampleRate: sampleRate, channels: channels, gainsDb: gainsDb);
    if (_running) {
      _previousEq = _eq;
      _crossfadeRemaining = _crossfadeFrames;
    }
    _eq = next;
  }

  Future<void> _pump() async {
    while (_running) {
      if (_paused) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        continue;
      }
      final bytes = _makeChunk();
      if (!_running) break;
      try {
        await _player?.feed(bytes);
      } catch (_) {
        await stop();
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  Uint8List _makeChunk() {
    final pcm = List<double>.filled(framesPerChunk * channels, 0);
    for (var frame = 0; frame < framesPerChunk; frame++) {
      final sample = _ambientSample();
      pcm[frame * 2] = sample;
      pcm[frame * 2 + 1] = sample;
    }
    final processed = _eq.process(pcm);
    final old = _previousEq;
    final oldProcessed = old?.process(pcm);
    final bytes = ByteData(processed.length * 2);
    for (var i = 0; i < processed.length; i++) {
      var value = processed[i];
      if (oldProcessed != null && _crossfadeRemaining > 0) {
        final progress = 1 - (_crossfadeRemaining / _crossfadeFrames);
        value = oldProcessed[i] * (1 - progress) + value * progress;
        if (i % channels == channels - 1) {
          _crossfadeRemaining--;
          if (_crossfadeRemaining <= 0) _previousEq = null;
        }
      }
      final scaled = (value * _volume * _duckMultiplier).clamp(-1.0, 1.0);
      final sample16 = (scaled * 32767).round();
      bytes.setInt16(i * 2, sample16, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  double _ambientSample() {
    final white = (_random.nextDouble() * 2) - 1;
    switch (_soundscape) {
      case 'Rain':
        // Filtered noise bed with sparse, softened transient droplets.
        _rainState = (_rainState * 0.91) + (white * 0.09);
        final drop = _random.nextDouble() > 0.997
            ? (_random.nextDouble() * 2 - 1) * 0.16 : 0.0;
        return ((_rainState * 0.75) + drop).clamp(-0.8, 0.8);
      case 'Soft focus':
        _softState = (_softState * 0.985) + (white * 0.015);
        return (_softState * 0.65).clamp(-0.6, 0.6);
      default:
        return white * 0.35;
    }
  }
}
