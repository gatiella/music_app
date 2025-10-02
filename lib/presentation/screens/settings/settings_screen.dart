import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'widgets/appearance_settings_widget.dart';
import 'widgets/audio_settings_widget.dart';
import 'widgets/library_settings_widget.dart';
import 'widgets/about_settings_widget.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/ytmusic_auth_provider.dart';
import '../../providers/ytmusic_sync_provider.dart';

// --- Settings Model and Provider ---
class SettingsModel extends ChangeNotifier {
  bool liveLyrics = false;
  bool sync = false;
  bool skipSilence = false;
  bool audioNormalization = false;
  bool ytLoggedIn = false;

  void setLiveLyrics(bool val) {
    liveLyrics = val;
    notifyListeners();
  }

  void setSync(bool val) {
    sync = val;
    notifyListeners();
  }

  void setSkipSilence(bool val) {
    skipSilence = val;
    notifyListeners();
  }

  void setAudioNormalization(bool val) {
    audioNormalization = val;
    notifyListeners();
  }

  void setYtLoggedIn(bool val) {
    ytLoggedIn = val;
    notifyListeners();
  }
}

class SettingsProvider extends InheritedNotifier<SettingsModel> {
  const SettingsProvider({
    super.key,
    required SettingsModel notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static SettingsModel of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
    assert(provider != null, 'No SettingsProvider found in context');
    return provider!.notifier!;
  }
}
// --- End Model and Provider ---

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _lyrics;
  bool _loadingLyrics = false;

  bool _syncing = false;
  String? _syncResult;

  bool _skipSilenceProcessing = false;
  String? _skipSilenceResult;

  Future<void> _fetchLyrics(String artist, String title) async {
    setState(() {
      _loadingLyrics = true;
    });

    try {
      final url =
          Uri.parse('https://api.lyrics.ovh/v1/$artist/$title'); // demo API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _lyrics = data['lyrics'] ?? "No lyrics found.";
        });
      } else {
        setState(() {
          _lyrics = "Failed to load lyrics.";
        });
      }
    } catch (e) {
      setState(() {
        _lyrics = "Error: $e";
      });
    } finally {
      setState(() {
        _loadingLyrics = false;
      });
    }
  }

  Future<void> _mockSync() async {
    setState(() {
      _syncing = true;
      _syncResult = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _syncing = false;
      _syncResult = "Library synced successfully!";
    });
  }

  Future<void> _mockSkipSilence(bool enabled) async {
    setState(() {
      _skipSilenceProcessing = true;
      _skipSilenceResult = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _skipSilenceProcessing = false;
      _skipSilenceResult = enabled
          ? "Silence skipping enabled!"
          : "Silence skipping disabled.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(title: 'Settings'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            const AppearanceSettingsWidget(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Audio'),
            const AudioSettingsWidget(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Live Lyrics'),
            SwitchListTile(
              title: const Text('Enable Live Lyrics'),
              value: settings.liveLyrics,
              onChanged: (val) {
                settings.setLiveLyrics(val);
                if (val) {
                  _fetchLyrics('Coldplay', 'Yellow');
                }
              },
            ),
            if (settings.liveLyrics)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _loadingLyrics
                    ? const Center(child: CircularProgressIndicator())
                    : _lyrics != null
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _lyrics!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : const Text(
                            'Lyrics will appear here when a song is playing.',
                            style: TextStyle(color: Colors.white70),
                          ),
              ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'YouTube Music Account'),
            Consumer<YTMusicAuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isSignedIn) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(authProvider.user?.photoUrl ?? ''),
                    ),
                    title:
                        Text(authProvider.user?.displayName ?? 'YouTube Music User'),
                    subtitle: Text(authProvider.user?.email ?? ''),
                    trailing: TextButton(
                      onPressed: () => authProvider.signOut(),
                      child: const Text('Sign out'),
                    ),
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('YouTube Music'),
                    subtitle: const Text('Sign in to sync your YT Music library'),
                    trailing: authProvider.isSigningIn
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: () => authProvider.signIn(),
                            child: const Text('Sign in'),),
                          );
                }
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Sync'),
            SwitchListTile(
              title: const Text('Sync Songs, Artists, Albums, Playlists'),
              value: settings.sync,
              onChanged: _syncing
                  ? null
                  : (val) async {
                      settings.setSync(val);
                      if (val) {
                        await _mockSync();
                        settings.setSync(false);
                      }
                    },
              secondary: _syncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            if (_syncResult != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  _syncResult!,
                  style:
                      const TextStyle(color: Colors.greenAccent, fontSize: 13),
                ),
              ),
            Consumer2<YTMusicAuthProvider, YTMusicSyncProvider>(
              builder: (context, authProvider, syncProvider, _) {
                return ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sync YT Music Library'),
                  subtitle: syncProvider.isSyncing
                      ? const Text('Syncing...')
                      : syncProvider.error != null
                          ? Text(syncProvider.error!,
                              style: const TextStyle(color: Colors.red))
                          : const Text(
                              'Sync your YouTube Music library to local database'),
                  trailing: syncProvider.isSyncing
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: syncProvider.isSyncing
                              ? null
                              : () => syncProvider.syncLibrary(authProvider),
                          child: const Text('Sync'),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Audio Processing'),
            SwitchListTile(
              title: const Text('Skip Silence'),
              value: settings.skipSilence,
              onChanged: _skipSilenceProcessing
                  ? null
                  : (val) async {
                      settings.setSkipSilence(val);
                      await _mockSkipSilence(val);
                    },
              secondary: _skipSilenceProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            if (_skipSilenceResult != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  _skipSilenceResult!,
                  style:
                      const TextStyle(color: Colors.greenAccent, fontSize: 13),
                ),
              ),
            SwitchListTile(
              title: const Text('Audio Normalization'),
              value: settings.audioNormalization,
              onChanged: settings.setAudioNormalization,
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Import'),
            ListTile(
              title: const Text('Import Playlists'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implement import logic
                },
                child: const Text('Import'),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Library'),
            const LibrarySettingsWidget(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'About'),
            const AboutSettingsWidget(),
            const SizedBox(height: 100),
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
}
