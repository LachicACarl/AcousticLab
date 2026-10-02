class EqBand {
  final String frequency;
  final double gain;

  const EqBand({
    required this.frequency,
    this.gain = 0,
  });

  EqBand copyWith({
    String? frequency,
    double? gain,
  }) {
    return EqBand(
      frequency: frequency ?? this.frequency,
      gain: gain ?? this.gain,
    );
  }
}

class EqProfile {
  final String name;
  final List<EqBand> bands;
  final double preamp;

  const EqProfile({
    required this.name,
    required this.bands,
    this.preamp = 0,
  });

  factory EqProfile.flat() {
    const frequencies = [
      '32',
      '64',
      '125',
      '250',
      '500',
      '1K',
      '2K',
      '4K',
      '8K',
      '16K',
    ];

    return EqProfile(
      name: 'Flat',
      bands: [
        for (final frequency in frequencies)
          EqBand(frequency: frequency),
      ],
    );
  }
}
