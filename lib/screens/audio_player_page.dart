import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/audio_service.dart';

class AudioPlayerPage extends StatefulWidget {
  final AudioService audioService;

  const AudioPlayerPage({
    super.key,
    required this.audioService,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  static const String _testAudioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  AudioService get _audioService => widget.audioService;

  Future<void> _loadAudio() async {
    try {
      await _audioService.loadAudio(_testAudioUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test audio loaded'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load audio: $error'),
        ),
      );
    }
  }

  Future<void> _play() async {
    try {
      await _audioService.play();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play audio: $error'),
        ),
      );
    }
  }

  Future<void> _pause() async {
    await _audioService.pause();
  }

  Future<void> _stop() async {
    await _audioService.stop();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IEMA Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.headphones,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'IEMA Audio Player',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Shared audio service',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadAudio,
                icon: const Icon(Icons.download),
                label: const Text('Load Test Audio'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<PlayerState>(
              stream: _audioService.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final isPlaying = playerState?.playing ?? false;

                final isLoading =
                    processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering;

                final isCompleted =
                    processingState == ProcessingState.completed;

                return Column(
                  children: [
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

                            final maximum =
                                duration.inMilliseconds > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1.0;

                            final current =
                                position.inMilliseconds
                                    .clamp(0, maximum.toInt())
                                    .toDouble();

                            return Column(
                              children: [
                                Slider(
                                  min: 0,
                                  max: maximum,
                                  value: current,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _stop,
                          icon: const Icon(Icons.stop),
                          iconSize: 36,
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF7C5CFC),
                          ),
                          child: IconButton(
                            onPressed: isLoading
                                ? null
                                : isCompleted
                                    ? _loadAudio
                                    : isPlaying
                                        ? _pause
                                        : _play,
                            icon: Icon(
                              isLoading
                                  ? Icons.hourglass_top
                                  : isCompleted
                                      ? Icons.replay
                                      : isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                            ),
                            color: Colors.white,
                            iconSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: StreamBuilder<double>(
                    stream: _audioService.volumeStream,
                    initialData: _audioService.volume,
                    builder: (context, snapshot) {
                      final volume = snapshot.data ?? 1.0;

                      return Slider(
                        min: 0,
                        max: 1,
                        value: volume.clamp(0.0, 1.0),
                        onChanged: _audioService.setVolume,
                      );
                    },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
