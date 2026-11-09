import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_route_safety_service.dart';

/// iOS active-output observer backed by AVAudioSession.currentRoute.outputs.
///
/// Android deliberately returns no route stream: connected-device enumeration
/// is not authoritative evidence of the active media output.
class AudioOutputRouteAdapter {
  AudioOutputRouteAdapter._();

  static const EventChannel _channel =
      EventChannel('com.example.iema/audio_output_route');

  static Stream<AudioOutputRoute> get activeRouteChanges {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const Stream<AudioOutputRoute>.empty();
    }

    return _channel.receiveBroadcastStream().map((event) {
      if (event is! Map) return AudioOutputRoute.unknown;
      switch (event['route']) {
        case 'bluetooth':
          return AudioOutputRoute.bluetooth;
        case 'builtInSpeaker':
          return AudioOutputRoute.builtInSpeaker;
        case 'other':
          return AudioOutputRoute.other;
        default:
          return AudioOutputRoute.unknown;
      }
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('Active audio route stream unavailable: $error');
    });
  }
}
