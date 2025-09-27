import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import 'songs_tab.dart';
import 'artists_tab.dart';
import 'albums_tab.dart';
import 'playlists_tab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<MusicLibraryProvider>().loadMusic();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              // Show sort options
              _showSortOptions(context);
            },
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: Consumer<MusicLibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your music...'),
                ],
              ),
            );
          }

          if (libraryProvider.songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No music found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure you have music files on your device',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      libraryProvider.loadMusic();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              SongsTab(),
              ArtistsTab(),
              AlbumsTab(),
              PlaylistsTab(),
            ],
          );
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Title'),
              onTap: () {
                Navigator.pop(context);
                // Sort by title
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Artist'),
              onTap: () {
                Navigator.pop(context);
                // Sort by artist
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Album'),
              onTap: () {
                Navigator.pop(context);
                // Sort by album
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Duration'),
              onTap: () {
                Navigator.pop(context);
                // Sort by duration
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Added'),
              onTap: () {
                Navigator.pop(context);
                // Sort by date added
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
