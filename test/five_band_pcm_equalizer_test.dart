import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:iema/services/five_band_pcm_equalizer.dart';

void main() {
  test('flat EQ passes samples without meaningful change', () {
    final eq = FiveBandPcmEqualizer(sampleRate: 48000, channels: 2,
      gainsDb: [0, 0, 0, 0, 0]);
    final input = List.generate(960, (i) => math.sin(i * 0.05));
    final output = eq.process(input);
    for (var i = 0; i < input.length; i++) {
      expect(output[i], closeTo(input[i], 1e-9));
    }
  });

  test('60 Hz boost changes low-frequency PCM energy', () {
    const sampleRate = 48000.0;
    final eq = FiveBandPcmEqualizer(sampleRate: sampleRate, channels: 1,
      gainsDb: [9, 0, 0, 0, 0]);
    final input = List.generate(48000,
      (i) => 0.1 * math.sin(2 * math.pi * 60 * i / sampleRate));
    final output = eq.process(input);
    double rms(List<double> data) {
      final tail = data.skip(24000).toList();
      return math.sqrt(tail.map((v) => v * v).reduce((a, b) => a + b) / tail.length);
    }
    expect(rms(output), greaterThan(rms(input) * 1.5));
  });

  test('rejects invalid gains and frame sizes', () {
    expect(() => FiveBandPcmEqualizer(sampleRate: 48000, channels: 2,
      gainsDb: [1, 2]), throwsArgumentError);
    final eq = FiveBandPcmEqualizer(sampleRate: 48000, channels: 2,
      gainsDb: [0, 0, 0, 0, 0]);
    expect(() => eq.process([0.1]), throwsArgumentError);
  });
}
