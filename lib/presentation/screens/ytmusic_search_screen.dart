import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/presentation/screens/ytmusic_video_screen.dart';
import 'package:music_app/presentation/providers/audio_player_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_favorites_provider.dart';
import '../../data/models/ytmusic_favorite.dart';
import '../../data/sources/ytmusic_source.dart';
import 'package:music_app/presentation/providers/ytmusic_playlists_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:music_app/presentation/widgets/download_button.dart';
import 'package:music_app/presentation/providers/music_library_provider.dart';

class YTMusicSearchScreen extends StatefulWidget {
  const YTMusicSearchScreen({super.key});

  @override
  State<YTMusicSearchScreen> createState() => _YTMusicSearchScreenState();
}

class _YTMusicSearchScreenState extends State<YTMusicSearchScreen>
    with SingleTickerProviderStateMixin {
  List<Video> _quickPicks = [];
  bool _quickPicksLoading = true;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  final _controller = TextEditingController();
  final _ytSource = YTMusicSource();

  List<Video> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );
    _gradientController.repeat();

    _loadQuickPicks();
  }

  Future<void> _loadQuickPicks() async {
    setState(() {
      _quickPicksLoading = true;
    });
    try {
      final picks = await _ytSource.fetchQuickPicks();
      setState(() {
        _quickPicks = picks;
      });
    } catch (e) {
      // ignore for now
    } finally {
      setState(() {
        _quickPicksLoading = false;
      });
    }
  }

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
        await Provider.of<AudioPlayerProvider>(context, listen: false)
            .playCustomUrl(
          url,
          title: video.title,
          artist: video.author,
          artUri: 'https://img.youtube.com/vi/${video.id.value}/default.jpg',
        );
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
  void dispose() {
    _gradientController.dispose();
    _controller.dispose();
    _ytSource.close();
    super.dispose();
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
                    // 🔍 Search bar
                    Card(
                      color: customColors?.glassContainer ??
                          Colors.white.withOpacity(0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                      Text(_error!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 12),

                    // 🎶 Results or Quick Picks
                    Expanded(
                      child: _results.isEmpty && !_loading
                          ? _quickPicksLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _quickPicks.isNotEmpty
                                  ? _buildQuickPicks(theme, customColors)
                                  : Center(
                                      child: Text(
                                        'No results yet. Try searching for a song or artist.',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    )
                          : _buildSearchResults(theme, customColors),
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

  // ✅ Quick Picks widget
  Widget _buildQuickPicks(
      ThemeData theme, MusicAppColorExtension? customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Picks', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickPicks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = _quickPicks[index];
              return SizedBox(
                width: 140,
                child: GestureDetector(
                  onTap: () => _play(video),
                  child: Card(
                    color: customColors?.glassContainer ??
                        Colors.white.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            'https://img.youtube.com/vi/${video.id.value}/default.jpg',
                            width: 140,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            video.title,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            video.author,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

   // ✅ Search Results widget
  Widget _buildSearchResults(
      ThemeData theme, MusicAppColorExtension? customColors) {
    return Consumer2<YTMusicFavoritesProvider, MusicLibraryProvider>(
      builder: (context, favProvider, musicProvider, _) {
        return ListView.separated(
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final video = _results[index];
            final isFav = favProvider.isFavorite(video.id.value);
            return Card(
              color: customColors?.glassContainer ??
                  Colors.white.withOpacity(0.7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: isFav ? Colors.red : theme.iconTheme.color,
                      tooltip: isFav
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: () async {
                        if (isFav) {
                          await favProvider.removeFavorite(video.id.value);
                        } else {
                          await favProvider.addFavorite(
                            YTMusicFavorite(
                              videoId: video.id.value,
                              title: video.title,
                              author: video.author,
                              thumbnailUrl:
                                  'https://img.youtube.com/vi/${video.id.value}/default.jpg',
                              savedAt: DateTime.now(),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.playlist_add),
                      tooltip: 'Add to Playlist',
                      onPressed: () =>
                          _showAddToPlaylistDialog(context, video),
                    ),
                    DownloadButton(
                      videoId: video.id.value,
                      title: video.title,
                      author: video.author,
                      thumbnailUrl: 'https://img.youtube.com/vi/${video.id.value}/default.jpg',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Add To Playlist Dialog
  Future<void> _showAddToPlaylistDialog(BuildContext context, Video video) async {
    final playlistsProvider =
        Provider.of<YTMusicPlaylistsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        final playlists = playlistsProvider.playlists;

        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: playlists.isEmpty
              ? const Text('No playlists available. Create one first.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        title: Text(playlist.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            await playlistsProvider.addItems(
                              playlist.id,
                              [video.id.value],
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}