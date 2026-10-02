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

  static const frequencies = [
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

  factory EqProfile.fromGains(
    String name,
    List<double> gains, {
    double preamp = 0,
  }) {
    return EqProfile(
      name: name,
      preamp: preamp,
      bands: [
        for (int i = 0; i < frequencies.length; i++)
          EqBand(
            frequency: frequencies[i],
            gain: gains[i],
          ),
      ],
    );
  }

  factory EqProfile.flat() {
    return EqProfile.fromGains(
      'Flat',
      List.filled(10, 0),
    );
  }

  factory EqProfile.bass() {
    return EqProfile.fromGains(
      'Bass',
      const [6, 5, 4, 2, 0, -1, -2, -2, -1, 0],
    );
  }

  factory EqProfile.vocal() {
    return EqProfile.fromGains(
      'Vocal',
      const [-2, -2, -1, 0, 2, 3, 4, 3, 1, 0],
    );
  }

  factory EqProfile.gaming() {
    return EqProfile.fromGains(
      'Gaming',
      const [2, 2, 1, 0, -1, 1, 3, 4, 3, 2],
    );
  }

  factory EqProfile.movie() {
    return EqProfile.fromGains(
      'Movie',
      const [3, 3, 2, 1, 0, 1, 2, 3, 2, 1],
    );
  }
}
