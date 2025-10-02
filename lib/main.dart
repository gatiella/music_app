import 'package:flutter/material.dart';
import 'package:music_app/core/services/ytmusic_sync_service.dart';
import 'package:music_app/presentation/providers/offline_library_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'app/app.dart';
import 'core/services/audio_service.dart';
import 'core/services/permission_service.dart';
import 'presentation/providers/audio_player_provider.dart';
import 'presentation/providers/music_library_provider.dart';
import 'presentation/providers/playlist_provider.dart';
import 'data/repositories/music_repository.dart';
import 'data/repositories/playlist_repository.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/ytmusic_favorites_provider.dart';
import 'presentation/providers/ytmusic_playlists_provider.dart';
import 'presentation/providers/ytmusic_auth_provider.dart'; 
import 'presentation/providers/ytmusic_sync_provider.dart';
import 'presentation/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerService(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.gatiella.music_app',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
    ),
  );

  // Request permissions
  final hasPermission = await PermissionService.requestPermissions();
  debugPrint('Permissions granted: $hasPermission');
  
  // Print detailed permission info
  final debugInfo = await PermissionService.getPermissionDebugInfo();
  debugPrint(debugInfo);

  runApp(MusicPlayerApp(
    audioHandler: audioHandler,
    hasPermission: hasPermission,
  ));
}

class MusicPlayerApp extends StatelessWidget {
  final AudioHandler audioHandler;
  final bool hasPermission;

  const MusicPlayerApp({
    super.key,
    required this.audioHandler,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    // Instantiate repositories once
    final musicRepository = MusicRepository();
    final playlistRepository = PlaylistRepository();
    
    // Create SettingsModel instance
    final settingsModel = SettingsModel();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerProvider(
            audioHandler as AudioPlayerService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MusicLibraryProvider(musicRepository: musicRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(playlistRepository: playlistRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => YTMusicFavoritesProvider(musicRepository: musicRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => YTMusicPlaylistsProvider(musicRepository: musicRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => OfflineLibraryProvider(),
        ),
        // Add these missing providers
        ChangeNotifierProvider(
          create: (_) => YTMusicAuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => YTMusicSyncProvider(
            syncService: YTMusicSyncService(),
          ),
        ),
        
      ],
      child: MusicAppInitializer(
        hasPermission: hasPermission,
        child: SettingsProvider(
          notifier: settingsModel,
          child: const MyApp(),
        ),
      ),
    );
  }
}

/// Widget to handle initial music loading after app starts
class MusicAppInitializer extends StatefulWidget {
  final Widget child;
  final bool hasPermission;

  const MusicAppInitializer({
    super.key,
    required this.child,
    required this.hasPermission,
  });

  @override
  State<MusicAppInitializer> createState() => _MusicAppInitializerState();
}

class _MusicAppInitializerState extends State<MusicAppInitializer> {
  @override
  void initState() {
    super.initState();
    // Load music after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMusicIfPermitted();
    });
  }

  Future<void> _loadMusicIfPermitted() async {
    if (widget.hasPermission && mounted) {
      debugPrint('Starting to load music...');
      try {
        await context.read<MusicLibraryProvider>().loadMusic();
        debugPrint('Music loading completed');
      } catch (e) {
        debugPrint('Error loading music: $e');
      }
    } else {
      debugPrint('Skipping music load - no permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}