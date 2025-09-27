import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/home/widgets/song_list_tile.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../../data/models/song.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          autofocus: true,
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
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _buildBody(),
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
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // You can implement recent searches here
              const Text(
                'No recent searches',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Browse by Genre',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildGenreGrid(libraryProvider),
              const SizedBox(height: 32),
              const Text(
                'Quick Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildQuickSearchOptions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenreGrid(MusicLibraryProvider libraryProvider) {
    final genres = libraryProvider.songs
        .where((song) => song.genre != null && song.genre!.isNotEmpty)
        .map((song) => song.genre!)
        .toSet()
        .toList();

    if (genres.isEmpty) {
      return const Text(
        'No genres available',
        style: TextStyle(color: Colors.grey),
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
        return Card(
          child: InkWell(
            onTap: () {
              _searchController.text = genre;
              _onSearchChanged();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  genre,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
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
      spacing: 8,
      runSpacing: 8,
      children: quickSearches.map((search) {
        return ActionChip(
          label: Text(search),
          onPressed: () {
            _searchController.text = search;
            _onSearchChanged();
          },
        );
      }).toList(),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Column(
          children: [
            // Search results header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  if (_searchResults.isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: () {
                        audioProvider.playPlaylist(_searchResults);
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Play All'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final shuffled = List<Song>.from(_searchResults);
                        shuffled.shuffle();
                        audioProvider.playPlaylist(shuffled);
                      },
                      icon: const Icon(Icons.shuffle, size: 18),
                      label: const Text('Shuffle'),
                    ),
                  ],
                ],
              ),
            ),
            // Search results list
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  final isCurrentSong =
                      audioProvider.currentSong?.id == song.id;

                  return SongListTile(
                    song: song,
                    isCurrentSong: isCurrentSong,
                    isPlaying: isCurrentSong && audioProvider.isPlaying,
                    onTap: () {
                      audioProvider.playPlaylist(
                        _searchResults,
                        startIndex: index,
                      );
                    },
                    onMorePressed: () {
                      _showSongOptions(context, song);
                    },
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: song.albumArt != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          song.albumArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(Icons.music_note, color: Colors.grey[600]),
              ),
              title: Text(
                song.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${song.artist} • ${song.album}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                context.read<AudioPlayerProvider>().playSong(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Add to Queue'),
              onTap: () {
                Navigator.pop(context);
                context.read<AudioPlayerProvider>().addToQueue(song);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to queue')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Show playlist selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Go to Album'),
              onTap: () {
                Navigator.pop(context);
                _searchController.text = song.album;
                _onSearchChanged();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Go to Artist'),
              onTap: () {
                Navigator.pop(context);
                _searchController.text = song.artist;
                _onSearchChanged();
              },
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
