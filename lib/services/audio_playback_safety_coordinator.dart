import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'audio_output_route_adapter.dart';
import 'audio_route_safety_service.dart';
import 'audio_service.dart';
import 'dsp_audio_pipeline.dart';

/// Owns one route observer and pauses every IEMA-owned playback engine.
///
/// This does not control audio produced by other apps or the operating system.
class AudioPlaybackSafetyCoordinator with WidgetsBindingObserver {
  AudioPlaybackSafetyCoordinator._();

  static final instance = AudioPlaybackSafetyCoordinator._();

  AudioRouteSafetyService? _routeSafety;
  bool _started = false;
  bool _disposed = false;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await _attachRouteObserver();
  }

  Future<void> _attachRouteObserver() async {
    if (_disposed || _routeSafety != null) return;
    final safety = AudioRouteSafetyService(onUnsafeRoute: pauseAll);
    _routeSafety = safety;
    try {
      await safety.listen(
        routeChanges: AudioOutputRouteAdapter.activeRouteChanges,
      );
    } catch (error, stackTrace) {
      _routeSafety = null;
      await safety.dispose();
      debugPrint('Unable to attach active audio route observer: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Pauses all app-owned players, not just whichever player is visible.
  Future<void> pauseAll() async {
    await Future.wait([
      AudioService.instance.pause(),
      DspAudioPipeline.instance.pause(),
    ]);
  }

  Future<void> _detachRouteObserver() async {
    final safety = _routeSafety;
    _routeSafety = null;
    await safety?.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _attachRouteObserver();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // IEMA does not claim background playback support. Stop app-owned audio
      // before detaching the native event listener while leaving the app.
      pauseAll();
      _detachRouteObserver();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    await pauseAll();
    await _detachRouteObserver();
  }
}
