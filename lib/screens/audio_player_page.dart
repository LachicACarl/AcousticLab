import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/audio_service.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({
    super.key,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioService _audioService = AudioService();

  bool _loading = false;
  String _status = 'No audio loaded';

  static const String _testAudioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  Future<void> _loadAudio() async {
    setState(() {
      _loading = true;
      _status = 'Loading audio...';
    });

    try {
      await _audioService.loadAudio(_testAudioUrl);

      if (!mounted) return;

      setState(() {
        _status = 'Audio loaded';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = 'Failed to load audio';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio error: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _play() async {
    try {
      await _audioService.play();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playback error: $error'),
        ),
      );
    }
  }

  Future<void> _pause() async {
    await _audioService.pause();
  }

  Future<void> _stop() async {
    await _audioService.stop();

    if (!mounted) return;

    setState(() {
      _status = 'Stopped';
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IEMA Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.headphones_rounded,
                    size: 72,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'IEMA Audio Test',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _status,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loading ? null : _loadAudio,
              icon: const Icon(Icons.download_rounded),
              label: Text(
                _loading ? 'Loading...' : 'Load Test Audio',
              ),
            ),

            const SizedBox(height: 20),

            StreamBuilder<PlayerState>(
              stream: _audioService.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: playing ? null : _play,
                      icon: const Icon(Icons.play_arrow_rounded),
                      iconSize: 32,
                    ),

                    const SizedBox(width: 16),

                    IconButton.filled(
                      onPressed: playing ? _pause : null,
                      icon: const Icon(Icons.pause_rounded),
                      iconSize: 32,
                    ),

                    const SizedBox(width: 16),

                    IconButton.filled(
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_rounded),
                      iconSize: 32,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            StreamBuilder<Duration>(
              stream: _audioService.positionStream,
              builder: (context, positionSnapshot) {
                final position =
                    positionSnapshot.data ?? Duration.zero;

                return StreamBuilder<Duration?>(
                  stream: _audioService.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration =
                        durationSnapshot.data ?? Duration.zero;

                    final max = duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0;

                    final value = position.inMilliseconds
                        .clamp(0, max.toInt())
                        .toDouble();

                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: max,
                          value: value,
                          onChanged: duration.inMilliseconds > 0
                              ? (value) {
                                  _audioService.seek(
                                    Duration(
                                      milliseconds: value.toInt(),
                                    ),
                                  );
                                }
                              : null,
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.volume_down_rounded),

                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: 1,
                    onChanged: (value) {
                      _audioService.setVolume(value);
                    },
                  ),
                ),

                const Icon(Icons.volume_up_rounded),
              ],
            ),

            const Spacer(),

            Text(
              'IEMA audio playback prototype',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
