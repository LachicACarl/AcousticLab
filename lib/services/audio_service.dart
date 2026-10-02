import '../models/eq_profile.dart';

class AudioService {
  EqProfile _currentProfile = EqProfile.flat();

  EqProfile get currentProfile => _currentProfile;

  void loadProfile(EqProfile profile) {
    _currentProfile = profile;
  }

  void setPreamp(double value) {
    _currentProfile = EqProfile(
      name: _currentProfile.name,
      bands: _currentProfile.bands,
      preamp: value,
    );
  }

  void setBandGain(int index, double gain) {
    if (index < 0 || index >= _currentProfile.bands.length) {
      return;
    }

    final updatedBands = List<EqBand>.from(_currentProfile.bands);

    updatedBands[index] = updatedBands[index].copyWith(
      gain: gain,
    );

    _currentProfile = EqProfile(
      name: _currentProfile.name,
      bands: updatedBands,
      preamp: _currentProfile.preamp,
    );
  }

  void resetEq() {
    _currentProfile = EqProfile.flat();
  }
}
