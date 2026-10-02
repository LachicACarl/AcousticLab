import '../models/audio_device.dart';

class DeviceService {
  final List<AudioDevice> _devices = [
    const AudioDevice(
      id: 'iema-demo',
      name: 'IEMA IEM',
      connectionType: AudioConnectionType.wired,
      connected: true,
      supportsHardwareVolume: false,
      supportsGain: false,
      supportsAnc: false,
      supportsTransparency: false,
    ),
    const AudioDevice(
      id: 'usb-dac-demo',
      name: 'USB DAC',
      connectionType: AudioConnectionType.usb,
      connected: false,
      supportsHardwareVolume: true,
      supportsGain: true,
    ),
  ];

  List<AudioDevice> get devices => List.unmodifiable(_devices);

  AudioDevice? get connectedDevice {
    for (final device in _devices) {
      if (device.connected) {
        return device;
      }
    }

    return null;
  }

  void connect(String id) {
    for (var i = 0; i < _devices.length; i++) {
      final device = _devices[i];

      if (device.id == id) {
        _devices[i] = AudioDevice(
          id: device.id,
          name: device.name,
          connectionType: device.connectionType,
          connected: true,
          supportsBattery: device.supportsBattery,
          supportsHardwareVolume: device.supportsHardwareVolume,
          supportsGain: device.supportsGain,
          supportsAnc: device.supportsAnc,
          supportsTransparency: device.supportsTransparency,
        );
      }
    }
  }

  void disconnect(String id) {
    for (var i = 0; i < _devices.length; i++) {
      final device = _devices[i];

      if (device.id == id) {
        _devices[i] = AudioDevice(
          id: device.id,
          name: device.name,
          connectionType: device.connectionType,
          connected: false,
          supportsBattery: device.supportsBattery,
          supportsHardwareVolume: device.supportsHardwareVolume,
          supportsGain: device.supportsGain,
          supportsAnc: device.supportsAnc,
          supportsTransparency: device.supportsTransparency,
        );
      }
    }
  }
}
