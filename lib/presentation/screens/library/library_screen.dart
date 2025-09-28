import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
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
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(
          title: 'Library',
          actions: [
            IconButton(
              onPressed: () {
                context.read<MusicLibraryProvider>().loadMusic();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                _showSortOptions(context);
              },
              icon: const Icon(Icons.sort, color: Colors.white),
            ),
          ],
        ),
        body: Consumer<MusicLibraryProvider>(
          builder: (context, libraryProvider, child) {
            if (libraryProvider.isLoading) {
              return _buildLoadingView();
            }

            if (libraryProvider.songs.isEmpty) {
              return _buildEmptyView(libraryProvider);
            }

            return Column(
              children: [
                // Custom Tab Bar with Glass Effect
                _buildGlassTabBar(),
                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      SongsTab(),
                      ArtistsTab(),
                      AlbumsTab(),
                      PlaylistsTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
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
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your music...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we scan your device',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(MusicLibraryProvider libraryProvider) {
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
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.music_off,
                size: 48,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No music found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Make sure you have music files on your device',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassButton(
              onPressed: () {
                libraryProvider.loadMusic();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.refresh, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTabBar() {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      borderRadius: BorderRadius.circular(25),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.2),
            ],
          ),
        ),
        indicatorPadding: const EdgeInsets.all(2),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Songs'),
          Tab(text: 'Artists'),
          Tab(text: 'Albums'),
          Tab(text: 'Playlists'),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sort by',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Sort Options
            ...[
              {
                'icon': Icons.title,
                'title': 'Title',
                'action': () {
                  Navigator.pop(context);
                  // Sort by title
                },
              },
              {
                'icon': Icons.person,
                'title': 'Artist',
                'action': () {
                  Navigator.pop(context);
                  // Sort by artist
                },
              },
              {
                'icon': Icons.album,
                'title': 'Album',
                'action': () {
                  Navigator.pop(context);
                  // Sort by album
                },
              },
              {
                'icon': Icons.access_time,
                'title': 'Duration',
                'action': () {
                  Navigator.pop(context);
                  // Sort by duration
                },
              },
              {
                'icon': Icons.date_range,
                'title': 'Date Added',
                'action': () {
                  Navigator.pop(context);
                  // Sort by date added
                },
              },
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  GlassMusicCard(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
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
                  if (index < 4) // Don't add divider after last item
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.white.withOpacity(0.1),
                    ),
                ],
              );
            }),
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
