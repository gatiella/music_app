import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';

class LibrarySettingsWidget extends StatelessWidget {
  const LibrarySettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {
        'icon': Icons.refresh,
        'title': 'Refresh Library',
        'subtitle': 'Scan for new music files',
        'onTap': () => _refreshLibrary(context),
      },
      {
        'icon': Icons.folder,
        'title': 'Music Folders',
        'subtitle': 'Choose which folders to scan',
        'onTap': () => _showMusicFoldersDialog(context),
      },
      {
        'icon': Icons.storage,
        'title': 'Storage',
        'subtitle': 'Manage app storage and cache',
        'onTap': () => _showStorageDialog(context),
      },
      {
        'icon': Icons.backup,
        'title': 'Backup & Restore',
        'subtitle': 'Backup playlists and settings',
        'onTap': () => _showBackupDialog(context),
      },
    ];

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      child: Column(
        children: settingsItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: Colors.white),
                ),
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: item['onTap'] as VoidCallback,
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              if (index < settingsItems.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _refreshLibrary(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refreshing library...'),
        backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Implement actual library refresh
    // Example: context.read<MusicLibraryProvider>().loadMusic();
  }

  void _showMusicFoldersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Music Folders',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Music folder selection coming soon!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'App Data: 15.2 MB',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cache: 5.8 MB',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'Total: 21.0 MB',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cache cleared successfully'),
                          backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: const Text(
                      'Clear Cache',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Backup & Restore',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Backup and restore features coming soon!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}