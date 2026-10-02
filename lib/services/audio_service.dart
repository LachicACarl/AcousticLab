import 'package:just_audio/just_audio.dart';

import '../models/eq_profile.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  EqProfile _currentProfile = EqProfile.flat();

  EqProfile get currentProfile => _currentProfile;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  bool get isPlaying => _player.playing;

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  Future<void> loadAudio(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  void loadProfile(EqProfile profile) {
    _currentProfile = profile;
  }

  void applyPreset(String preset) {
    switch (preset) {
      case 'Bass':
        _currentProfile = EqProfile.bass();
        break;

      case 'Vocal':
        _currentProfile = EqProfile.vocal();
        break;

      case 'Gaming':
        _currentProfile = EqProfile.gaming();
        break;

      case 'Movie':
        _currentProfile = EqProfile.movie();
        break;

      case 'Flat':
      default:
        _currentProfile = EqProfile.flat();
        break;
    }
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
      name: 'Custom',
      bands: updatedBands,
      preamp: _currentProfile.preamp,
    );
  }

  void resetEq() {
    _currentProfile = EqProfile.flat();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
