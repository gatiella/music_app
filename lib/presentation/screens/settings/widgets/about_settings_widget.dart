import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';

class AboutSettingsWidget extends StatelessWidget {
  const AboutSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
        'onTap': () => _showPrivacyPolicy(context),
      },
      {
        'icon': Icons.description,
        'title': 'Terms of Service',
        'subtitle': null,
        'onTap': () => _showTermsOfService(context),
      },
      {
        'icon': Icons.star,
        'title': 'Rate App',
        'subtitle': null,
        'onTap': () => _rateApp(context),
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
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
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
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SoundWave Music Player',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha((0.7 * 255).toInt()),
            ],
          ),
        ),
        child: const Icon(Icons.music_note, size: 32, color: Colors.white),
      ),
      children: const [
        Text('A beautiful and feature-rich music player built with Flutter.'),
        SizedBox(height: 16),
        Text('© 2024 SoundWave. All rights reserved.'),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your privacy is important to us. This music player:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Does not collect personal information\n'
                  '• Stores music preferences locally\n'
                  '• Does not share data with third parties\n'
                  '• Only accesses music files on your device',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GlassButton(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'By using SoundWave Music Player, you agree to:\n\n'
                  '• Use the app for personal, non-commercial purposes\n'
                  '• Play only music you have rights to access\n'
                  '• Not attempt to reverse engineer the app\n'
                  '• Accept the app "as is" without warranty',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GlassButton(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you! Opening app store...'),
        backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Implement actual app store rating
    // Example: launch('https://play.google.com/store/apps/details?id=your.app.id');
  }
}