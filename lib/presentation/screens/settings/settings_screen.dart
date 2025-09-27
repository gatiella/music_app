import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/audio_player_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSettings(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Audio'),
          _buildAudioSettings(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Library'),
          _buildLibrarySettings(context),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildAboutSettings(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(_getThemeText(themeProvider.themeMode)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Accent Color'),
                subtitle: const Text('Blue'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _showColorPicker(context),
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
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Volume'),
                subtitle: Slider(
                  value: audioProvider.volume,
                  onChanged: (value) => audioProvider.setVolume(value),
                  min: 0.0,
                  max: 1.0,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Playback Speed'),
                subtitle: Text('${audioProvider.speed.toStringAsFixed(1)}x'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showSpeedDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.equalizer),
                title: const Text('Equalizer'),
                subtitle: const Text('Customize audio settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showEqualizerDialog(context),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.headset),
                title: const Text('Auto-pause on headphone disconnect'),
                subtitle: const Text(
                  'Automatically pause when headphones are removed',
                ),
                value: true, // You can make this a setting
                onChanged: (value) {
                  // Handle headphone disconnect setting
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLibrarySettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Library'),
            subtitle: const Text('Scan for new music files'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Refresh library
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing library...')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Music Folders'),
            subtitle: const Text('Choose which folders to scan'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showMusicFoldersDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage'),
            subtitle: const Text('Manage app storage and cache'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showStorageDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Backup playlists and settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showBackupDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show privacy policy
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show terms of service
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Open app store for rating
            },
          ),
        ],
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
        title: const Text('Choose Theme'),
        content: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Accent Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: Theme.of(context).primaryColor,
            onColorChanged: (color) {
              // Handle color change
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          return AlertDialog(
            title: const Text('Playback Speed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${audioProvider.speed.toStringAsFixed(1)}x'),
                Slider(
                  value: audioProvider.speed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (value) => audioProvider.setSpeed(value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('0.5x'), Text('2.0x')],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEqualizerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equalizer'),
        content: const Text('Equalizer feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMusicFoldersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Music Folders'),
        content: const Text('Music folder selection coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('App Data: 15.2 MB'),
            SizedBox(height: 8),
            Text('Cache: 5.8 MB'),
            SizedBox(height: 8),
            Text('Total: 21.0 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear cache
            },
            child: const Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Backup and restore features coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
          color: Theme.of(context).primaryColor,
        ),
        child: const Icon(Icons.music_note, size: 32, color: Colors.white),
      ),
      children: const [
        Text('A beautiful and feature-rich music player built with Flutter.'),
      ],
    );
  }
}

// Placeholder for color picker - you can use flutter_colorpicker package
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
      width: 300,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: pickerColor == color
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
