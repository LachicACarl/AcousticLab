import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EqProfileData {
  const EqProfileData({required this.name, required this.gains});
  final String name;
  final List<double> gains;
  Map<String, Object> toJson() => {'name': name, 'gains': gains};
  factory EqProfileData.fromJson(Map<String, dynamic> json) => EqProfileData(
    name: json['name'] as String? ?? 'Custom',
    gains: (json['gains'] as List).map((v) => (v as num).toDouble()).toList(),
  );
}

class EqProfileStore {
  EqProfileStore._();
  static final instance = EqProfileStore._();
  static const _key = 'iema.eq.profiles.v1';
  static const _activeKey = 'iema.eq.active.v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const defaults = <EqProfileData>[
    EqProfileData(name: 'Flat', gains: [0, 0, 0, 0, 0]),
    EqProfileData(name: 'Bass', gains: [5, 4, 0, -1, -1]),
    EqProfileData(name: 'Vocal', gains: [-2, 0, 3, 4, 1]),
    EqProfileData(name: 'Bright', gains: [-1, 0, 1, 3, 5]),
  ];

  Future<List<EqProfileData>> loadProfiles() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return defaults;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final profiles = list.map(EqProfileData.fromJson)
        .where((p) => p.gains.length == 5).toList();
      return profiles.isEmpty ? defaults : profiles;
    } catch (_) {
      return defaults;
    }
  }

  Future<void> saveProfiles(List<EqProfileData> profiles) =>
    _prefs.setString(_key, jsonEncode(profiles.map((p) => p.toJson()).toList()));
  Future<String> loadActiveName() async =>
    await _prefs.getString(_activeKey) ?? 'Flat';
  Future<void> saveActiveName(String name) => _prefs.setString(_activeKey, name);
}