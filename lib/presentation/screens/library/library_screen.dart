import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:music_app/core/services/permission_service.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import 'songs_tab.dart';
import 'artists_tab.dart';
import 'albums_tab.dart';
import 'playlists_tab.dart';
import 'ytmusic_favorites_tab.dart';
import 'ytmusic_playlists_tab.dart';
import '../../../app/theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Check permissions and load music automatically on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLibrary();
    });
  }

  Future<void> _initializeLibrary() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    final hasPermission = await PermissionService.checkStoragePermission();
    
    if (!hasPermission && mounted) {
      // Request permissions silently
      final granted = await PermissionService.requestPermissions();
      
      if (granted && mounted) {
        // Load music after permission is granted
        context.read<MusicLibraryProvider>().loadMusic();
      } else if (mounted) {
        // Show dialog only if permission was denied
        _showPermissionDeniedDialog();
      }
    } else if (mounted) {
      // Permission already granted, load music
      context.read<MusicLibraryProvider>().loadMusic();
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Storage permission is required to access your music files. '
          'Please enable it in app settings.\n\n'
          'Go to: Settings > Apps > Music App > Permissions > Files and media',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          // ElevatedButton(
          //   onPressed: () async {
          //     Navigator.pop(context);
          //     await PermissionService.openAppSettings();
          //     // Reset flag so it can check again when user returns
          //     _permissionsRequested = false;
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     foregroundColor: Colors.white,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          //   child: const Text('Open Settings'),
          // ),
        ],
      ),
    );
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
                onPressed: () async {
                  final hasPermission = await PermissionService.checkStoragePermission();
                  if (hasPermission && mounted) {
                    // Use forceRefresh instead of loadMusic
                    await context.read<MusicLibraryProvider>().forceRefresh();
                    _showRefreshSnackbar();
                  } else if (mounted) {
                    _showPermissionDeniedDialog();
                  }
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
        body: Column(
          children: [
            _buildGlassTabBar(),
            Expanded(
              child: Consumer<MusicLibraryProvider>(
                builder: (context, libraryProvider, child) {
                  if (libraryProvider.isLoading) {
                    return _buildLoadingView();
                  }

                  if (libraryProvider.songs.isEmpty) {
                    return _buildEmptyView();
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: const [
                      SongsTab(),
                      ArtistsTab(),
                      AlbumsTab(),
                      PlaylistsTab(),
                      YTMusicFavoritesTab(),
                      YTMusicPlaylistsTab(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 12),
            Text('Refreshing music library...'),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLoadingView() {
    final theme = Theme.of(context);
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
                gradient: theme.customColors.gradient1,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your music...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scanning device for audio files',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
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
              'No audio files were found on your device.\n'
              'Make sure you have music files in your Music folder.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          GlassButton(
                onPressed: () async {
                  final hasPermission = await PermissionService.checkStoragePermission();
                  if (hasPermission && mounted) {
                    await context.read<MusicLibraryProvider>().forceRefresh();
                    _showRefreshSnackbar();
                  } else if (mounted) {
                    _showPermissionDeniedDialog();
                  }
                },
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
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
                    'Scan Again',
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
          Tab(text: 'YT Music'),
          Tab(text: 'YT Playlists'),
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
            ...[
              {
                'icon': Icons.title,
                'title': 'Title',
                'action': () {
                  Navigator.pop(context);
                },
              },
              {
                'icon': Icons.person,
                'title': 'Artist',
                'action': () {
                  Navigator.pop(context);
                },
              },
              {
                'icon': Icons.album,
                'title': 'Album',
                'action': () {
                  Navigator.pop(context);
                },
              },
              {
                'icon': Icons.access_time,
                'title': 'Duration',
                'action': () {
                  Navigator.pop(context);
                },
              },
              {
                'icon': Icons.date_range,
                'title': 'Date Added',
                'action': () {
                  Navigator.pop(context);
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
                  if (index < 4)
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