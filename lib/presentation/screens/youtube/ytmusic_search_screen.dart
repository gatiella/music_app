// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_app/core/utils/connectivity_helper.dart';
import 'package:music_app/data/models/ytmusic_favorite.dart';
import 'package:music_app/data/sources/ytmusic_source.dart';
import 'package:music_app/presentation/screens/youtube/ytmusic_video_screen.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/presentation/providers/audio_player_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_favorites_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_playlists_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_auth_provider.dart';
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
  // Genre-based music with caching
  final Map<String, List<Video>> _genreMusic = {};
  final Map<String, DateTime> _genreCacheTime = {};
  final Duration _cacheExpiration = const Duration(hours: 1);
  
  // Track user preferences
  final Map<String, int> _genrePlayCount = {};
  
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  final _controller = TextEditingController();
  final _ytSource = YTMusicSource();

  List<Video> _results = [];
  bool _loading = false;
  String? _error;
  Timer? _searchDebounce;

  // Enhanced genre categories with better icons and queries
  final List<Map<String, dynamic>> _genres = [
    {'name': 'Trending', 'query': 'music hits', 'icon': Icons.trending_up, 'color': const Color(0xFFFF6B6B)},
    {'name': 'Pop', 'query': 'pop music', 'icon': Icons.star, 'color': const Color(0xFF4ECDC4)},
    {'name': 'Hip Hop', 'query': 'hip hop music', 'icon': Icons.album, 'color': const Color(0xFFFFE66D)},
    {'name': 'Rock', 'query': 'rock music', 'icon': Icons.graphic_eq, 'color': const Color(0xFFFF6B9D)},
    {'name': 'Afrobeats', 'query': 'afrobeats music', 'icon': Icons.music_note, 'color': const Color(0xFFFFA07A)},
    {'name': 'Gospel', 'query': 'gospel music', 'icon': Icons.church, 'color': const Color(0xFF95E1D3)},
    {'name': 'R&B', 'query': 'r&b music', 'icon': Icons.favorite, 'color': const Color(0xFFDDA15E)},
    {'name': 'EDM', 'query': 'electronic music', 'icon': Icons.headphones, 'color': const Color(0xFFBC6C25)},
  ];

  int _selectedGenreIndex = 0;
  bool _isLoadingGenre = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );
    _gradientController.repeat();

    // Load only first genre
    _loadGenreMusic(_genres[0]['name'] as String, _genres[0]['query'] as String);
  }

Future<void> _loadGenreMusic(String genreName, String query) async {
  if (!mounted) return;

  // Check cache first
  final cacheTime = _genreCacheTime[genreName];
  if (cacheTime != null && 
      DateTime.now().difference(cacheTime) < _cacheExpiration &&
      (_genreMusic[genreName]?.isNotEmpty ?? false)) {
    return;
  }
  
  setState(() {
    _isLoadingGenre = true;
  });
  
  try {
    // Remove connectivity check - let the API call fail naturally
    final results = await _ytSource.search(query).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out. Please check your internet connection.');
      },
    );
    
    if (mounted) {
      setState(() {
        _genreMusic[genreName] = results.take(12).toList();
        _genreCacheTime[genreName] = DateTime.now();
        _isLoadingGenre = false;
      });
    }
  } catch (e) {
    debugPrint('Error loading $genreName: $e');
    if (mounted) {
      setState(() {
        _isLoadingGenre = false;
        if (_genreMusic[genreName]?.isEmpty ?? true) {
          _genreMusic[genreName] = [];
        }
      });
      
      // Determine error message
      String errorMessage;
      if (e.toString().contains('timed out') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('ClientException')) {
        errorMessage = 'Failed to connect to YouTube';
      } else {
        errorMessage = 'Failed to load $genreName music';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _loadGenreMusic(genreName, query),
          ),
        ),
      );
    }
  }
}

void _onGenreSelected(int index) {
  if (_selectedGenreIndex == index) return;
  
  setState(() {
    _selectedGenreIndex = index;
  });
  
  final genre = _genres[index];
  // Only load if not already cached
  final cachedData = _genreMusic[genre['name']];
  if (cachedData == null || cachedData.isEmpty) {
    _loadGenreMusic(
      genre['name'] as String,
      genre['query'] as String,
    );
  }
}

Future<void> _search() async {
  final query = _controller.text.trim();
  if (query.isEmpty) return;
  
  if (!mounted) return;
  
  setState(() {
    _loading = true;
    _error = null;
  });
  
  try {
    final results = await _ytSource.search(query);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  } catch (e) {
    debugPrint('Search error: $e');
    if (mounted) {
      setState(() {
        _error = 'Search failed. Please check your connection and try again.';
        _loading = false;
      });
    }
  }
}

// 5. Update _play method with better error handling
Future<void> _play(Video video) async {
  if (!mounted) return;
  
  // Track which genre this song is from
  _trackGenrePlay();
  
  setState(() {
    _loading = true;
    _error = null;
  });
  
  try {
    final url = await _ytSource.getAudioStreamUrl(video.id.value);
    if (url != null && mounted) {
      await Provider.of<AudioPlayerProvider>(context, listen: false)
          .playCustomUrl(
        url,
        title: video.title,
        artist: video.author,
        artUri: 'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.play_circle_filled, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Playing: ${video.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _error = 'Could not get stream URL for this track.';
        });
      }
    }
  } catch (e) {
    debugPrint('Playback error: $e');
    if (mounted) {
      setState(() {
        _error = 'Playback error: ${e.toString()}';
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
  void _trackGenrePlay() {
    final currentGenre = _genres[_selectedGenreIndex]['name'] as String;
    _genrePlayCount[currentGenre] = (_genrePlayCount[currentGenre] ?? 0) + 1;
  }

  void _onSearchTextChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _results.clear();
        _error = null;
      });
      return;
    }
    
    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      _search();
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results.clear();
      _error = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _gradientController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<MusicAppColorExtension>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.music_note, size: 24),
            SizedBox(width: 8),
            Text('YouTube Music'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Sign In/Out Button
          Consumer<YTMusicAuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.isSigningIn) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                );
              }
              
              return PopupMenuButton<String>(
                icon: Icon(
                  authProvider.isSignedIn 
                      ? Icons.account_circle 
                      : Icons.account_circle_outlined,
                ),
                tooltip: 'Account',
                onSelected: (value) async {
                  if (value == 'signin') {
                    await authProvider.signIn();
                    if (mounted && authProvider.isSignedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed in successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else if (value == 'signout') {
                    await authProvider.signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else if (value == 'refresh') {
                    _genreCacheTime.clear(); // Clear cache
                    final currentGenre = _genres[_selectedGenreIndex];
                    _loadGenreMusic(currentGenre['name'] as String, currentGenre['query'] as String);
                  }
                },
                itemBuilder: (context) {
                  if (authProvider.isSignedIn) {
                    return [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.userName ?? 'User',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authProvider.userEmail ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 12),
                            Text('Refresh Music'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'signout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 12),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ];
                  } else {
                    return [
                      const PopupMenuItem(
                        value: 'signin',
                        child: Row(
                          children: [
                            Icon(Icons.login, size: 20),
                            SizedBox(width: 12),
                            Text('Sign In'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 12),
                            Text('Refresh Music'),
                          ],
                        ),
                      ),
                    ];
                  }
                },
              );
            },
          ),
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearSearch,
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
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: customColors?.glassContainer ??
                            Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Search for songs, artists...',
                                  border: InputBorder.none,
                                ),
                                style: theme.textTheme.bodyLarge,
                                onChanged: _onSearchTextChanged,
                                onSubmitted: (_) => _search(),
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearSearch,
                                tooltip: 'Clear',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Loading indicator
                  if (_loading) 
                    LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  
                  // Error message
                  if (_error != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, 
                                color: Colors.red[300], size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red[100],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 20, color: Colors.red[300]),
                              onPressed: () {
                                setState(() {
                                  _error = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Content
                  Expanded(
                    child: _results.isNotEmpty
                        ? _buildSearchResults(theme, customColors)
                        : _buildGenreContent(theme, customColors),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenreContent(ThemeData theme, MusicAppColorExtension? customColors) {
    return Column(
      children: [
        // Genre tabs
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final isSelected = _selectedGenreIndex == index;
              final playCount = _genrePlayCount[genre['name']] ?? 0;
              final isPopular = playCount > 3;
              
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onGenreSelected(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.95)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                genre['icon'] as IconData,
                                size: 20,
                                color: isSelected 
                                    ? genre['color'] as Color 
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                genre['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.black87 : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Favorite indicator
                    if (isPopular)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Music grid for selected genre
        Expanded(
          child: _buildGenreGrid(
            _genres[_selectedGenreIndex]['name'] as String,
            theme,
            customColors,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreGrid(
    String genreName,
    ThemeData theme,
    MusicAppColorExtension? customColors,
  ) {
    final videos = _genreMusic[genreName];
    
    // Show loading for genre that hasn't been loaded yet
    if (videos == null || (videos.isEmpty && _isLoadingGenre)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading $genreName...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Getting the best tracks for you',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load music',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final genre = _genres.firstWhere(
                  (g) => g['name'] == genreName,
                  orElse: () => _genres[0],
                );
                _loadGenreMusic(genreName, genre['query'] as String);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show play count if user has listened to this genre
        if (_genrePlayCount[genreName] != null && _genrePlayCount[genreName]! > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'You\'ve played ${_genrePlayCount[genreName]} ${_genrePlayCount[genreName]! == 1 ? 'song' : 'songs'} from this genre',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildVideoCard(video, theme, customColors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(
      Video video, ThemeData theme, MusicAppColorExtension? customColors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _play(video),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: customColors?.glassContainer ?? Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[300]!, Colors.blue[300]!],
                              ),
                            ),
                            child: const Icon(Icons.music_note, size: 48, color: Colors.white),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildSearchResults(
      ThemeData theme, MusicAppColorExtension? customColors) {
    return Consumer2<YTMusicFavoritesProvider, MusicLibraryProvider>(
      builder: (context, favProvider, musicProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      '${_results.length} result${_results.length == 1 ? '' : 's'} found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final video = _results[index];
                  final isFav = favProvider.isFavorite(video.id.value);
                  return _buildResultItem(
                    video, 
                    isFav, 
                    favProvider, 
                    theme, 
                    customColors,
                  );
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
    return Container(
      decoration: BoxDecoration(
        color: customColors?.glassContainer ?? Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _play(video),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.network(
                        'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[300]!, Colors.blue[300]!],
                              ),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white),
                          );
                        },
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              video.author,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.ondemand_video, size: 20),
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
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: isFav 
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                            ),
                            color: isFav ? Colors.red : Colors.grey[700],
                            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                            onPressed: () async {
                              if (isFav) {
                                await favProvider.removeFavorite(video.id.value);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from favorites'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
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
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to favorites'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          tooltip: 'More options',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'playlist') {
                              _showAddToPlaylistDialog(context, video);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'playlist',
                              child: Row(
                                children: [
                                  Icon(Icons.playlist_add, size: 20),
                                  SizedBox(width: 12),
                                  Text('Add to Playlist'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        DownloadButton(
                          videoId: video.id.value,
                          title: video.title,
                          author: video.author,
                          thumbnailUrl: 
                              'https://img.youtube.com/vi/${video.id.value}/mqdefault.jpg',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddToPlaylistDialog(
      BuildContext context, Video video) async {
    final playlistsProvider =
        Provider.of<YTMusicPlaylistsProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        final playlists = playlistsProvider.playlists;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.playlist_add, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Add to Playlist'),
            ],
          ),
          content: playlists.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.queue_music,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No playlists available',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create one first from the playlists tab.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: playlist.coverImageUrl != null
                                ? Image.network(
                                    playlist.coverImageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.queue_music),
                                        ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple[300]!,
                                          Colors.blue[300]!,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.queue_music,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () async {
                                try {
                                  await playlistsProvider.addItems(
                                    playlist.id,
                                    [video.id.value],
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added to ${playlist.name}'),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}