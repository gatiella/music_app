// ignore_for_file: deprecated_member_use

import 'dart:async';

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
    if (!mounted) return;
    
    setState(() {
      _quickPicksLoading = true;
    });
    
    try {
      final picks = await _ytSource.fetchQuickPicks();
      if (mounted) {
        setState(() {
          _quickPicks = picks;
        });
      }
    } catch (e) {
      // ignore for now
    } finally {
      if (mounted) {
        setState(() {
          _quickPicksLoading = false;
        });
      }
    }
  }

  Future<void> _search() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final results = await _ytSource.search(_controller.text);
      if (mounted) {
        setState(() {
          _results = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _play(Video video) async {
    if (!mounted) return;
    
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
        if (mounted) {
          setState(() {
            _error = 'No audio stream found.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Add debounced search to prevent multiple rapid API calls
  Timer? _searchDebounce;
  
  void _onSearchTextChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _search();
      } else {
        setState(() {
          _results.clear();
          _error = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _results.clear();
                  _error = null;
                });
              },
              tooltip: 'Clear results',
            ),
        ],
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
                                  icon: Icon(Icons.search),
                                ),
                                style: theme.textTheme.bodyLarge,
                                onChanged: _onSearchTextChanged,
                                onSubmitted: (_) => _search(),
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {
                                    _results.clear();
                                    _error = null;
                                  });
                                },
                                tooltip: 'Clear search',
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Loading and error indicators
                    if (_loading) 
                      const LinearProgressIndicator(),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              iconSize: 16,
                              onPressed: () {
                                setState(() {
                                  _error = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // 🎶 Results or Quick Picks
                    Expanded(
                      child: _buildContent(theme, customColors),
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

  Widget _buildContent(ThemeData theme, MusicAppColorExtension? customColors) {
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_results.isNotEmpty) {
      return _buildSearchResults(theme, customColors);
    }
    
    if (_quickPicksLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_quickPicks.isNotEmpty) {
      return _buildQuickPicks(theme, customColors);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for songs or artists',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Quick Picks widget
  Widget _buildQuickPicks(
      ThemeData theme, MusicAppColorExtension? customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Picks', 
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _quickPicks.length,
            itemBuilder: (context, index) {
              final video = _quickPicks[index];
              return _buildVideoCard(video, theme, customColors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(
      Video video, ThemeData theme, MusicAppColorExtension? customColors) {
    return GestureDetector(
      onTap: () => _play(video),
      child: Card(
        color: customColors?.glassContainer ?? Colors.white.withOpacity(0.7),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Search Results widget
  Widget _buildSearchResults(
      ThemeData theme, MusicAppColorExtension? customColors) {
    return Consumer2<YTMusicFavoritesProvider, MusicLibraryProvider>(
      builder: (context, favProvider, musicProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${_results.length} results found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final video = _results[index];
                  final isFav = favProvider.isFavorite(video.id.value);
                  return _buildResultItem(video, isFav, favProvider, theme, customColors);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(
    Video video,
    bool isFav,
    YTMusicFavoritesProvider favProvider,
    ThemeData theme,
    MusicAppColorExtension? customColors,
  ) {
    return Card(
      color: customColors?.glassContainer ?? Colors.white.withOpacity(0.7),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note),
              );
            },
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
              tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
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
                          'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
                      savedAt: DateTime.now(),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: 'Add to Playlist',
              onPressed: () => _showAddToPlaylistDialog(context, video),
            ),
            DownloadButton(
              videoId: video.id.value,
              title: video.title,
              author: video.author,
              thumbnailUrl: 'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Add To Playlist Dialog
  Future<void> _showAddToPlaylistDialog(BuildContext context, Video video) async {
    final playlistsProvider =
        Provider.of<YTMusicPlaylistsProvider>(context, listen: false);

    await showDialog(
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
                            try {
                              await playlistsProvider.addItems(
                                playlist.id,
                                [video.id.value],
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to ${playlist.name}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                            if (mounted) {
                              Navigator.pop(context);
                            }
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