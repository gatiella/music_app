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
        body: SafeArea(
          child: Column(
            children: [
              // Enhanced Header with Search
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Search',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: IconButton(
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
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Enhanced Search Input
                    Theme(
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
                  ],
                ),
              ),
              // Body Content
              Expanded(child: _buildBody()),
            ],
          ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Browse by Genre'),
              const SizedBox(height: 16),
              _buildGenreGrid(libraryProvider),
              const SizedBox(height: 32),
              _buildSectionTitle('Popular Genres'),
              const SizedBox(height: 16),
              _buildQuickSearchOptions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
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
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.music_note_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No genres available',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genres.length > 6 ? 6 : genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        final colors = _getGenreGradient(index);
        
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
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        genre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGenreGradient(int index) {
    final gradients = [
      [Colors.purple.withValues(alpha: 0.3), Colors.purple.withValues(alpha: 0.1)],
      [Colors.blue.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.1)],
      [Colors.pink.withValues(alpha: 0.3), Colors.pink.withValues(alpha: 0.1)],
      [Colors.teal.withValues(alpha: 0.3), Colors.teal.withValues(alpha: 0.1)],
      [Colors.orange.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.1)],
      [Colors.indigo.withValues(alpha: 0.3), Colors.indigo.withValues(alpha: 0.1)],
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildQuickSearchOptions() {
    final quickSearches = [
      {'name': 'Rock', 'icon': Icons.music_note},
      {'name': 'Pop', 'icon': Icons.star},
      {'name': 'Hip Hop', 'icon': Icons.album},
      {'name': 'Jazz', 'icon': Icons.piano},
      {'name': 'Classical', 'icon': Icons.library_music},
      {'name': 'Electronic', 'icon': Icons.electrical_services},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: quickSearches.map((item) {
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _searchController.text = item['name'] as String;
                _onSearchChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No results found',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching for "$_searchQuery"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'with different keywords',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
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
            // Enhanced Search results header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_searchResults.length} ${_searchResults.length == 1 ? 'song' : 'songs'} found',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'for "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_searchResults.isNotEmpty) ...[
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await audioProvider.playPlaylist(_searchResults);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NowPlayingScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.shuffle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Search results list with enhanced styling
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  final isCurrentSong = audioProvider.currentSong?.id == song.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: isCurrentSong
                                  ? LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0.1),
                                      ],
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Album Art
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: song.albumArt != null
                                        ? Image.network(
                                            song.albumArt!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                child: const Icon(
                                                  Icons.music_note,
                                                  color: Colors.white70,
                                                  size: 28,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            child: const Icon(
                                              Icons.music_note,
                                              color: Colors.white70,
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Song Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isCurrentSong
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${song.artist} • ${song.album}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Playing indicator or more options
                                if (isCurrentSong && audioProvider.isPlaying)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.3),
                                          Colors.white.withValues(alpha: 0.1),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.equalizer,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () => _showSongOptions(context, song),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.1),
                                      ),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Colors.white.withValues(alpha: 0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song Info Header with enhanced styling
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: song.albumArt != null
                          ? Image.network(
                              song.albumArt!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white70,
                                    size: 32,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.white.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white70,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
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

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),

            // Action Items with icons
            ...[
              {
                'icon': Icons.play_circle_filled,
                'title': 'Play Now',
                'action': () {
                  Navigator.pop(context);
                  context.read<AudioPlayerProvider>().playSong(song);
                },
              },
              {
                'icon': Icons.queue_music,
                'title': 'Add to Queue',
                'action': () {
                  Navigator.pop(context);
                  context.read<AudioPlayerProvider>().addToQueue(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to queue'),
                      backgroundColor: Colors.black.withValues(alpha: 0.9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                'icon': Icons.album_outlined,
                'title': 'View Album',
                'action': () {
                  Navigator.pop(context);
                  _searchController.text = song.album;
                  _onSearchChanged();
                },
              },
              {
                'icon': Icons.person_outline,
                'title': 'View Artist',
                'action': () {
                  Navigator.pop(context);
                  _searchController.text = song.artist;
                  _onSearchChanged();
                },
              },
            ].map(
              (item) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item['action'] as VoidCallback,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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