import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/audio_player_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(title: 'Settings'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            _buildThemeSettings(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Audio'),
            _buildAudioSettings(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Library'),
            _buildLibrarySettings(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildAboutSettings(context),
            const SizedBox(height: 100), // Extra space for bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.palette, color: Colors.white),
                ),
                title: 'Theme',
                subtitle: _getThemeText(themeProvider.themeMode),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showThemeDialog(context),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.1),
              ),
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.color_lens, color: Colors.white),
                ),
                title: 'Accent Color',
                subtitle: 'Purple',
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                onTap: () => _showColorPicker(context),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioSettings(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final theme = Theme.of(context);

        return GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              GlassContainer(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Volume',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: audioProvider.volume,
                        onChanged: (value) => audioProvider.setVolume(value),
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.1),
              ),
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.speed, color: Colors.white),
                ),
                title: 'Playback Speed',
                subtitle: '${audioProvider.speed.toStringAsFixed(1)}x',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showSpeedDialog(context),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.1),
              ),
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.equalizer, color: Colors.white),
                ),
                title: 'Equalizer',
                subtitle: 'Customize audio settings',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showEqualizerDialog(context),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.1),
              ),
              GlassContainer(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.headset, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-pause on headphone disconnect',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically pause when headphones are removed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle headphone disconnect setting
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.3),
                      inactiveThumbColor: Colors.white.withOpacity(0.5),
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLibrarySettings(BuildContext context) {
    final settingsItems = [
      {
        'icon': Icons.refresh,
        'title': 'Refresh Library',
        'subtitle': 'Scan for new music files',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Refreshing library...'),
              backgroundColor: Colors.black.withOpacity(0.8),
            ),
          );
        },
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
                    color: Colors.white.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    final aboutItems = [
      {
        'icon': Icons.info,
        'title': 'About',
        'subtitle': 'Version 1.0.0',
        'onTap': () => _showAboutDialog(context),
      },
      {
        'icon': Icons.privacy_tip,
        'title': 'Privacy Policy',
        'subtitle': null,
        'onTap': () {
          // Show privacy policy
        },
      },
      {
        'icon': Icons.description,
        'title': 'Terms of Service',
        'subtitle': null,
        'onTap': () {
          // Show terms of service
        },
      },
      {
        'icon': Icons.star,
        'title': 'Rate App',
        'subtitle': null,
        'onTap': () {
          // Open app store for rating
        },
      },
    ];

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      child: Column(
        children: aboutItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: Colors.white),
                ),
                title: item['title'] as String,
                subtitle: item['subtitle'] as String?,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: item['onTap'] as VoidCallback,
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              if (index < aboutItems.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose Theme',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...ThemeMode.values.map((mode) {
                    return GlassContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.zero,
                      child: RadioListTile<ThemeMode>(
                        title: Text(
                          _getThemeText(mode),
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: mode,
                        groupValue: themeProvider.themeMode,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          themeProvider.setThemeMode(value!);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
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
                'Choose Accent Color',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BlockPicker(
                pickerColor: Theme.of(context).primaryColor,
                onColorChanged: (color) {
                  // Handle color change
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: const Text(
                      'Cancel',
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
                      'Apply',
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

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Playback Speed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${audioProvider.speed.toStringAsFixed(1)}x',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: audioProvider.speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      onChanged: (value) => audioProvider.setSpeed(value),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.5x', style: TextStyle(color: Colors.white70)),
                      Text('2.0x', style: TextStyle(color: Colors.white70)),
                    ],
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
          );
        },
      ),
    );
  }

  void _showEqualizerDialog(BuildContext context) {
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
                'Equalizer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Equalizer feature coming soon!',
                style: TextStyle(color: Colors.white70),
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
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    onPressed: () {
                      // Clear cache
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Music Player',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: const Icon(Icons.music_note, size: 32, color: Colors.white),
      ),
      children: const [
        Text('A beautiful and feature-rich music player built with Flutter.'),
      ],
    );
  }
}

// Updated BlockPicker with glassmorphism
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    return SizedBox(
      width: 280,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = pickerColor == color;

          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
