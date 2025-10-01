import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../../data/models/song.dart';
import '../now_playing/now_playing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });

    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _performSearch(String query) {
    final libraryProvider = context.read<MusicLibraryProvider>();
    final allSongs = libraryProvider.songs;

    final results = allSongs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.artist.toLowerCase().contains(query.toLowerCase()) ||
          song.album.toLowerCase().contains(query.toLowerCase()) ||
          (song.genre?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(
          title: null,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear, color: Colors.white),
              ),
          ],
        ),
        body: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: const TextStyle(color: Colors.white),
                  ),
                ),
                child: GlassTextField(
                  controller: _searchController,
                  hintText: 'Search songs, artists, albums...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            // Body Content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isSearching) {
      return _buildInitialView();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsView();
    }

    return _buildSearchResults();
  }

  Widget _buildInitialView() {
    return Consumer<MusicLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Recent Searches'),
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text(
                    'No recent searches',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Browse by Genre'),
              const SizedBox(height: 16),
              _buildGenreGrid(libraryProvider),
              const SizedBox(height: 32),
              _buildSectionTitle('Quick Search'),
              const SizedBox(height: 16),
              _buildQuickSearchOptions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGenreGrid(MusicLibraryProvider libraryProvider) {
    final genres = libraryProvider.songs
        .where((song) => song.genre != null && song.genre!.isNotEmpty)
        .map((song) => song.genre!)
        .toSet()
        .toList();

    if (genres.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No genres available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return GlassContainer(
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _searchController.text = genre;
                _onSearchChanged();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    genre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSearchOptions() {
    final quickSearches = [
      'Rock',
      'Pop',
      'Hip Hop',
      'Jazz',
      'Classical',
      'Electronic',
      'Country',
      'R&B',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: quickSearches.map((search) {
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(25),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                _searchController.text = search;
                _onSearchChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Text(
                  search,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                 color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found for "$_searchQuery"',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Column(
          children: [
            // Search results header
            GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Spacer(),
                  if (_searchResults.isNotEmpty) ...[
                    GlassButton(
                      onPressed: () async {
                        await audioProvider.playPlaylist(_searchResults);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NowPlayingScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_arrow, size: 18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Play All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassButton(
                      onPressed: () async {
                        final shuffled = List<Song>.from(_searchResults);
                        shuffled.shuffle();
                        await audioProvider.playPlaylist(shuffled);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NowPlayingScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shuffle, size: 18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Shuffle',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Search results list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  final isCurrentSong =
                      audioProvider.currentSong?.id == song.id;

                  return GlassMusicCard(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withAlpha((0.1 * 255).toInt()),
                      ),
                      child: song.albumArt != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                song.albumArt!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.music_note,
                                    color: Colors.white70,
                                    size: 24,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            ),
                    ),
                    title: song.title,
                    subtitle: '${song.artist} • ${song.album}',
                    trailing: GestureDetector(
                      onTap: () => _showSongOptions(context, song),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                           color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await audioProvider.playPlaylist(
                        _searchResults,
                        startIndex: index,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NowPlayingScreen(),
                        ),
                      );
                    },
                    isPlaying: isCurrentSong && audioProvider.isPlaying,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song Info Header
            GlassMusicCard(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                ),
                child: song.albumArt != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.albumArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white70,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: Colors.white70,
                        size: 24,
                      ),
              ),
              title: song.title,
              subtitle: '${song.artist} • ${song.album}',
              height: 70,
              padding: const EdgeInsets.all(16),
            ),

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white.withAlpha((0.1 * 255).toInt()),
            ),

            // Action Items
            ...[
                  {
                    'icon': Icons.play_arrow,
                    'title': 'Play',
                    'action': () {
                      Navigator.pop(context);
                      context.read<AudioPlayerProvider>().playSong(song);
                    },
                  },
                  {
                    'icon': Icons.queue,
                    'title': 'Add to Queue',
                    'action': () {
                      Navigator.pop(context);
                      context.read<AudioPlayerProvider>().addToQueue(song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added to queue'),
                          backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
                        ),
                      );
                    },
                  },
                  {
                    'icon': Icons.playlist_add,
                    'title': 'Add to Playlist',
                    'action': () {
                      Navigator.pop(context);
                      // Show playlist selection
                    },
                  },
                  {
                    'icon': Icons.album,
                    'title': 'Go to Album',
                    'action': () {
                      Navigator.pop(context);
                      _searchController.text = song.album;
                      _onSearchChanged();
                    },
                  },
                  {
                    'icon': Icons.person,
                    'title': 'Go to Artist',
                    'action': () {
                      Navigator.pop(context);
                      _searchController.text = song.artist;
                      _onSearchChanged();
                    },
                  },
                ]
                .map(
                  (item) => GlassMusicCard(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    title: item['title'] as String,
                    onTap: item['action'] as VoidCallback,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                  ),
                )
                ,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
