enum AudioConnectionType {
  wired,
  bluetooth,
  usb,
}

class AudioDevice {
  final String id;
  final String name;
  final AudioConnectionType connectionType;
  final bool connected;
  final bool supportsBattery;
  final bool supportsHardwareVolume;
  final bool supportsGain;
  final bool supportsAnc;
  final bool supportsTransparency;

  const AudioDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    this.connected = false,
    this.supportsBattery = false,
    this.supportsHardwareVolume = false,
    this.supportsGain = false,
    this.supportsAnc = false,
    this.supportsTransparency = false,
  });
}
