import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/presentation/screens/ytmusic_video_screen.dart';
import '../../data/sources/ytmusic_source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YTMusicSearchScreen extends StatefulWidget {
  const YTMusicSearchScreen({super.key});

  @override
  State<YTMusicSearchScreen> createState() => _YTMusicSearchScreenState();
}

class _YTMusicSearchScreenState extends State<YTMusicSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );
    _gradientController.repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _controller.dispose();
    _ytSource.close();
    _audioPlayer.dispose();
    super.dispose();
  }
  final _controller = TextEditingController();
  final _ytSource = YTMusicSource();
  final _audioPlayer = AudioPlayer();
  List<Video> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _ytSource.search(_controller.text);
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _play(Video video) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await _ytSource.getAudioStreamUrl(video.id.value);
      if (url != null) {
        await _audioPlayer.setUrl(url);
        _audioPlayer.play();
      } else {
        setState(() {
          _error = 'No audio stream found.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<MusicAppColorExtension>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('YouTube Music'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    MusicAppTheme.primaryGradient[0],
                    MusicAppTheme.primaryGradient[1],
                    (math.sin(_gradientAnimation.value) * 0.5 + 0.5),
                  )!,
                  Color.lerp(
                    MusicAppTheme.secondaryGradient[0],
                    MusicAppTheme.secondaryGradient[1],
                    (math.cos(_gradientAnimation.value * 0.8) * 0.5 + 0.5),
                  )!,
                  Color.lerp(
                    MusicAppTheme.primaryGradient[1],
                    MusicAppTheme.accentPink,
                    (math.sin(_gradientAnimation.value * 1.2) * 0.5 + 0.5),
                  )!,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      color: customColors?.glassContainer ?? Colors.white.withOpacity(0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Search YouTube Music...',
                                  border: InputBorder.none,
                                ),
                                style: theme.textTheme.bodyLarge,
                                onSubmitted: (_) => _search(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              color: theme.colorScheme.primary,
                              onPressed: _search,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_loading) const LinearProgressIndicator(),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child: _results.isEmpty && !_loading
                          ? Center(
                              child: Text(
                                'No results yet. Try searching for a song or artist.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: _results.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final video = _results[index];
                                return Card(
                                  color: customColors?.glassContainer ?? Colors.white.withOpacity(0.7),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        'https://img.youtube.com/vi/${video.id.value}/default.jpg',
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      video.title,
                                      style: theme.textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      video.author,
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.play_arrow),
                                          tooltip: 'Play Audio',
                                          color: theme.colorScheme.primary,
                                          onPressed: () => _play(video),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.ondemand_video),
                                          tooltip: 'Play Video',
                                          color: theme.colorScheme.secondary,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => YTMusicVideoScreen(
                                                  videoId: video.id.value,
                                                  title: video.title,
                                                  author: video.author,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
