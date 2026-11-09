import 'dart:math' as math;

/// Stateful, sample-by-sample peaking EQ. One instance per audio channel.
/// Coefficients follow the RBJ audio EQ cookbook.
class BiquadPeak {
  BiquadPeak({required this.sampleRate, required this.frequencyHz,
    required this.gainDb, this.q = 0.707}) {
    _recalculate();
  }

  final double sampleRate;
  final double frequencyHz;
  final double gainDb;
  final double q;
  double _b0 = 1, _b1 = 0, _b2 = 0, _a1 = 0, _a2 = 0;
  double _z1 = 0, _z2 = 0;

  void _recalculate() {
    if (!sampleRate.isFinite || sampleRate <= 0 ||
        !frequencyHz.isFinite || frequencyHz <= 0 ||
        frequencyHz >= sampleRate / 2 ||
        !gainDb.isFinite || !q.isFinite || q <= 0) {
      throw ArgumentError('Invalid peaking EQ parameters');
    }
    final a = math.pow(10.0, gainDb / 40.0).toDouble();
    final w = 2 * math.pi * frequencyHz / sampleRate;
    final alpha = math.sin(w) / (2 * q);
    final a0 = 1 + alpha / a;
    _b0 = (1 + alpha * a) / a0;
    _b1 = (-2 * math.cos(w)) / a0;
    _b2 = (1 - alpha * a) / a0;
    _a1 = (-2 * math.cos(w)) / a0;
    _a2 = (1 - alpha / a) / a0;
  }

  double process(double input) {
    final output = _b0 * input + _z1;
    _z1 = _b1 * input - _a1 * output + _z2;
    _z2 = _b2 * input - _a2 * output;
    return output;
  }

  void reset() { _z1 = 0; _z2 = 0; }
}

/// PCM processor for interleaved floating-point samples. Integrate this at
/// the decoded-PCM stage of an audio output engine; this class alone does not
/// intercept just_audio or system audio.
class FiveBandPcmEqualizer {
  FiveBandPcmEqualizer({
    required this.sampleRate,
    required this.channels,
    required List<double> gainsDb,
  }) {
    if (channels < 1 || channels > 8) {
      throw ArgumentError.value(channels, 'channels');
    }
    updateGains(gainsDb);
  }

  final double sampleRate;
  final int channels;
  static const frequenciesHz = <double>[60, 250, 1000, 4000, 16000];
  late List<List<BiquadPeak>> _filters;
  List<double> _gainsDb = List.filled(5, 0);

  List<double> get gainsDb => List.unmodifiable(_gainsDb);

  void updateGains(List<double> gainsDb) {
    if (gainsDb.length != 5 ||
        gainsDb.any((v) => !v.isFinite || v < -12 || v > 12)) {
      throw ArgumentError('Expected five finite gains in -12..12 dB');
    }
    _gainsDb = List.of(gainsDb);
    // At 32 kHz or lower, 16 kHz is at/above Nyquist; omit that
    // band instead of generating an unstable or invalid filter.
    _filters = List.generate(channels, (_) => [
      for (var i = 0; i < frequenciesHz.length; i++)
        if (frequenciesHz[i] < sampleRate / 2)
          BiquadPeak(sampleRate: sampleRate,
            frequencyHz: frequenciesHz[i], gainDb: gainsDb[i]),
    ]);
  }

  /// Input/output are interleaved PCM frames; a fresh output buffer is returned.
  List<double> process(List<double> samples) {
    if (samples.length % channels != 0) {
      throw ArgumentError('Sample count must be divisible by channels');
    }
    final result = List<double>.filled(samples.length, 0);
    for (var i = 0; i < samples.length; i++) {
      var value = samples[i];
      for (final filter in _filters[i % channels]) {
        value = filter.process(value);
      }
      result[i] = value;
    }
    return result;
  }

  void reset() {
    for (final channel in _filters) {
      for (final filter in channel) { filter.reset(); }
    }
  }
}
