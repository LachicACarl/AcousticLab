import 'package:flutter/material.dart';
import '../services/eq_profile_store.dart';
import '../services/dsp_audio_pipeline.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});
  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  static const bands = ['60 Hz', '250 Hz', '1 kHz', '4 kHz', '16 kHz'];
  final store = EqProfileStore.instance;
  List<EqProfileData> profiles = [];
  List<double> gains = List<double>.filled(5, 0);
  String selected = 'Flat';
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final loaded = await store.loadProfiles();
    final active = await store.loadActiveName();
    final matches = loaded.where((p) => p.name == active);
    if (!mounted) return;
    setState(() {
      profiles = loaded;
      selected = matches.isEmpty ? 'Flat' : active;
      gains = List.of(matches.isEmpty ? loaded.first.gains : matches.first.gains);
      loading = false;
      DspAudioPipeline.instance.updateGains(gains);
    });
  }

  Future<void> _select(String name) async {
    final profile = profiles.firstWhere((p) => p.name == name);
    setState(() { selected = name; gains = List.of(profile.gains); });
    await store.saveActiveName(name);
    DspAudioPipeline.instance.updateGains(gains);
  }

  Future<void> _save() async {
    final controller = TextEditingController(text: selected == 'Custom' ? '' : selected);
    final name = await showDialog<String>(context: context, builder: (context) =>
      AlertDialog(
        title: const Text('Save EQ profile'),
        content: TextField(controller: controller, autofocus: true, maxLength: 24,
          decoration: const InputDecoration(labelText: 'Profile name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save')),
        ],
      ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final updated = [...profiles.where((p) => p.name != name),
      EqProfileData(name: name, gains: List.of(gains))];
    await store.saveProfiles(updated);
    await store.saveActiveName(name);
    if (!mounted) return;
    setState(() { profiles = updated; selected = name; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved "$name" on this device')));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
    return SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Equalizer', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Five-band EQ profiles for audio played inside IEMA.',
        style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 22),
      DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: const InputDecoration(labelText: 'Preset', filled: true,
          border: OutlineInputBorder()),
        items: profiles.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
        onChanged: (value) { if (value != null) _select(value); },
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF11141B),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Column(children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            SizedBox(width: 58, child: Text(bands[i], style: const TextStyle(color: Colors.white70))),
            Expanded(child: Slider(min: -12, max: 12, divisions: 48, value: gains[i],
              label: '${gains[i].toStringAsFixed(1)} dB',
              onChanged: (v) {
                setState(() { gains[i] = v; selected = 'Custom'; });
                DspAudioPipeline.instance.updateGains(gains);
              })),
            SizedBox(width: 48, child: Text(
              '${gains[i] >= 0 ? '+' : ''}${gains[i].toStringAsFixed(1)}',
              textAlign: TextAlign.end)),
          ]),
        ))),
      ),
      const SizedBox(height: 12),
      const Text('Gain values update live and can be saved locally. Actual DSP processing is not yet wired into the playback engine; this does not alter audio from other apps.',
        style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => _select('Flat'), child: const Text('Reset'))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton.icon(onPressed: _save,
          icon: const Icon(Icons.save_outlined), label: const Text('Save profile'))),
      ]),
    ]));
  }
}