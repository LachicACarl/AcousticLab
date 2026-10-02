class IemProfile {
  final String id;
  final String brand;
  final String model;
  final String driverType;
  final int driverCount;
  final String impedance;
  final String sensitivity;
  final String frequencyResponse;
  final String notes;

  const IemProfile({
    required this.id,
    required this.brand,
    required this.model,
    required this.driverType,
    required this.driverCount,
    required this.impedance,
    required this.sensitivity,
    required this.frequencyResponse,
    this.notes = '',
  });

  String get displayName => '$brand $model';
}
