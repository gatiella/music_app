import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerService(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.example.music_player_app.channel.audio',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
    ),
  );

  // Request permissions
  await PermissionService.requestPermissions();

  runApp(MusicPlayerApp(audioHandler: audioHandler));
}

class MusicPlayerApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MusicPlayerApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    // Instantiate repositories once
    final musicRepository = MusicRepository();
    final playlistRepository = PlaylistRepository();

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
      ],
      child: const MyApp(),
    );
  }
}
