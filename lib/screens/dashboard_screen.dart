import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String soundscape = 'Off';
  double appVolume = 0.7;
  static const profiles = ['Off', 'White noise', 'Rain', 'Soft focus'];

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(
    padding: const EdgeInsets.all(24), children: [
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IEMA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Your personal audio space', style: TextStyle(color: Colors.white54)),
        ]),
        CircleAvatar(backgroundColor: Color(0xFF1C1730),
          child: Icon(Icons.graphic_eq, color: Color(0xFFB39DFF))),
      ]),
      const SizedBox(height: 28),
      _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Icon(Icons.headphones_rounded, size: 46, color: Color(0xFFB39DFF)),
        SizedBox(height: 18),
        Text('Audio output', style: TextStyle(color: Colors.white60)),
        SizedBox(height: 5),
        Text('Managed by your device', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Pair your headphones in phone Bluetooth settings. IEMA audio uses the currently selected system output.',
          style: TextStyle(color: Colors.white60, height: 1.4)),
      ])),
      const SizedBox(height: 22),
      _section('APP AUDIO'),
      _panel(Column(children: [
        Row(children: [
          const Icon(Icons.volume_up_outlined, color: Color(0xFFB39DFF)),
          const SizedBox(width: 10), const Expanded(child: Text('In-app volume')),
          Text('${(appVolume * 100).round()}%'),
        ]),
        Slider(value: appVolume, onChanged: (v) => setState(() => appVolume = v)),
      ])),
      const SizedBox(height: 22),
      _section('SOUND PROFILES'),
      _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ambient soundscapes', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text('These are optional app-played sounds, not hardware ANC or microphone-based transparency.',
          style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: profiles.map((p) =>
          ChoiceChip(label: Text(p), selected: soundscape == p,
            onSelected: (_) => setState(() => soundscape = p))).toList()),
        if (soundscape != 'Off') const Padding(padding: EdgeInsets.only(top: 12),
          child: Text('Soundscape selection is a UI state for now; audio assets and playback are a separate milestone.',
            style: TextStyle(color: Colors.amberAccent, fontSize: 12))),
      ])),
      const SizedBox(height: 22),
      _section('QUICK ACCESS'),
      Row(children: [
        Expanded(child: _panel(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.equalizer, color: Color(0xFFB39DFF), size: 27),
          SizedBox(height: 14), Text('Equalizer', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4), Text('5-band profiles', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]))),
        const SizedBox(width: 12),
        Expanded(child: _panel(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.bluetooth, color: Color(0xFFB39DFF), size: 27),
          SizedBox(height: 14), Text('Bluetooth', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4), Text('Phone settings', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]))),
      ]),
    ],
  ));

  Widget _section(String text) => Padding(padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11,
      fontWeight: FontWeight.bold, letterSpacing: 1.3)));
  Widget _panel(Widget child) => Container(padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF11141B),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
    child: child);
}