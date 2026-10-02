import 'package:flutter/material.dart';
import 'models/eq_profile.dart';
import 'services/audio_service.dart';

void main() {
  runApp(const IEMAApp());
}

class IEMAApp extends StatelessWidget {
  const IEMAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IEMA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const IEMAMainScreen(),
    );
  }
}

class IEMAMainScreen extends StatefulWidget {
  const IEMAMainScreen({super.key});

  @override
  State<IEMAMainScreen> createState() => _IEMAMainScreenState();
}

class _IEMAMainScreenState extends State<IEMAMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    DevicesPage(),
    EqualizerPage(),
    LibraryPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF10131A),
        indicatorColor: const Color(0xFF2A2148),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.equalizer_outlined),
            selectedIcon: Icon(Icons.equalizer),
            label: 'EQ',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double volume = 65;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 28),

            const Text(
              'Your audio setup',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 10),

            _deviceCard(),

            const SizedBox(height: 20),

            _volumeCard(),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _quickCard(
                    icon: Icons.equalizer,
                    title: 'Equalizer',
                    subtitle: 'Studio',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _quickCard(
                    icon: Icons.tune,
                    title: 'Controls',
                    subtitle: 'Open',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ControlCenterPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Playback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _playbackCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'IEMA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Intelligent Ear Monitor Assistant',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFF191C25),
          child: Icon(
            Icons.person_outline,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1C1730),
            Color(0xFF141821),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2148),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.headphones,
              size: 32,
              color: Color(0xFF9D82FF),
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IEMA IEM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 9,
                      color: Colors.greenAccent,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _volumeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Volume',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${volume.round()}%',
                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),
            ],
          ),

          Slider(
            value: volume,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                volume = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF11141B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF9D82FF),
              size: 28,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playbackCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.skip_previous),
            iconSize: 30,
          ),
          const SizedBox(width: 10),
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF7C5CFC),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.skip_next),
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEVICES
// ============================================================

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Devices',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your IEMs and audio devices.',
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 28),

            _device(
              context,
              'IEMA IEM',
              'Connected',
              Icons.headphones,
              true,
            ),

            const SizedBox(height: 12),

            _device(
              context,
              'USB DAC',
              'Not connected',
              Icons.usb,
              false,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Device'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _device(
    BuildContext context,
    String name,
    String status,
    IconData icon,
    bool connected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: connected
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceDetailsPage(),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF11141B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F29),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: connected
                          ? Colors.greenAccent
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EQUALIZER
// ============================================================

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  final List<String> frequencies = [
    '32',
    '64',
    '125',
    '250',
    '500',
    '1K',
    '2K',
    '4K',
    '8K',
    '16K',
  ];

  final List<double> values = List.filled(10, 0);

  String preset = 'Flat';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equalizer',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Tune your sound profile.',
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: preset,
              decoration: InputDecoration(
                labelText: 'Preset',
                filled: true,
                fillColor: const Color(0xFF11141B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Flat',
                  child: Text('Flat'),
                ),
                DropdownMenuItem(
                  value: 'Bass',
                  child: Text('Bass Boost'),
                ),
                DropdownMenuItem(
                  value: 'Vocal',
                  child: Text('Vocal'),
                ),
                DropdownMenuItem(
                  value: 'Gaming',
                  child: Text('Gaming'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  preset = value ?? 'Flat';
                });
              },
            ),

            const SizedBox(height: 28),

            Container(
              height: 430,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF11141B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  frequencies.length,
                  (index) {
                    return Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: values[index],
                                min: -12,
                                max: 12,
                                onChanged: (value) {
                                  setState(() {
                                    values[index] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            frequencies[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < values.length; i++) {
                          values[i] = 0;
                        }
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LIBRARY
// ============================================================

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My IEM Library',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Keep track of your IEM collection.',
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF11141B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.headphones,
                    size: 42,
                    color: Color(0xFF9D82FF),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IEMA IEM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Dynamic Driver',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add IEM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MORE
// ============================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'More',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _item(
              Icons.graphic_eq,
              'Audio Test Center',
              'Test left/right channels and frequency response',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AudioTestPage(),
                  ),
                );
              },
            ),

            _item(
              Icons.system_update,
              'Firmware',
              'Manage firmware for supported IEMA hardware',
              () {},
            ),

            _item(
              Icons.settings,
              'Settings',
              'App preferences and audio settings',
              () {},
            ),

            _item(
              Icons.info_outline,
              'About IEMA',
              'Version, documentation and licenses',
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF181B23),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0x73FFFFFF),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white30,
      ),
      onTap: onTap,
    );
  }
}

// ============================================================
// CONTROL CENTER
// ============================================================

class ControlCenterPage extends StatefulWidget {
  const ControlCenterPage({super.key});

  @override
  State<ControlCenterPage> createState() => _ControlCenterPageState();
}

class _ControlCenterPageState extends State<ControlCenterPage> {
  double balance = 0;
  bool stereo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Audio Controls',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          _controlCard(
            Icons.swap_horiz,
            'Channel Balance',
            'L   •   R',
            Slider(
              value: balance,
              min: -1,
              max: 1,
              onChanged: (value) {
                setState(() {
                  balance = value;
                });
              },
            ),
          ),

          _controlCard(
            Icons.volume_up,
            'Output Mode',
            stereo ? 'Stereo' : 'Mono',
            Switch(
              value: stereo,
              onChanged: (value) {
                setState(() {
                  stereo = value;
                });
              },
            ),
          ),

          _controlCard(
            Icons.tune,
            'Hardware Gain',
            'Not supported by current device',
            const Icon(
              Icons.lock_outline,
              color: Colors.white30,
            ),
          ),

          _controlCard(
            Icons.mic,
            'Microphone',
            'Not supported by current device',
            const Icon(
              Icons.lock_outline,
              color: Colors.white30,
            ),
          ),

          _controlCard(
            Icons.noise_aware,
            'ANC / Transparency',
            'Not supported by current device',
            const Icon(
              Icons.lock_outline,
              color: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlCard(
    IconData icon,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF9D82FF),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ============================================================
// DEVICE DETAILS
// ============================================================

class DeviceDetailsPage extends StatelessWidget {
  const DeviceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IEMA IEM'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF211A3A),
                  Color(0xFF12151C),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: Icon(
                Icons.headphones,
                size: 80,
                color: Color(0xFF9D82FF),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'IEMA IEM',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Connected • Wired',
            style: TextStyle(
              color: Colors.greenAccent,
            ),
          ),

          const SizedBox(height: 25),

          _info('Connection', 'Connected'),
          _info('Driver', 'Dynamic Driver'),
          _info('Channels', 'Stereo'),
          _info('Battery', 'Not available'),
          _info('Firmware', 'Not available'),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ControlCenterPage(),
                ),
              );
            },
            icon: const Icon(Icons.tune),
            label: const Text('Open Control Center'),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AUDIO TEST
// ============================================================

class AudioTestPage extends StatelessWidget {
  const AudioTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Test Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Audio Tests',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Use a comfortable listening level before running tests.',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),

          const SizedBox(height: 25),

          _test(
            Icons.arrow_back,
            'Left / Right Test',
            'Check channel orientation.',
          ),

          _test(
            Icons.graphic_eq,
            'Frequency Sweep',
            'Play a frequency sweep.',
          ),

          _test(
            Icons.compare_arrows,
            'Channel Balance',
            'Compare left and right output.',
          ),

          _test(
            Icons.mic,
            'Microphone Test',
            'Check microphone input.',
          ),
        ],
      ),
    );
  }

  Widget _test(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: const Color(0xFF9D82FF),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_circle_outline,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}




