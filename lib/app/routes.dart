import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/youtube/ytmusic_search_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/now_playing/now_playing_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String nowPlaying = '/now-playing';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String ytMusic = '/ytmusic';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      nowPlaying: (context) => const NowPlayingScreen(),
      search: (context) => const SearchScreen(),
      settings: (context) => const SettingsScreen(),
      ytMusic: (context) => const YTMusicSearchScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
  // Add import for YTMusicSearchScreen at the top if not present
    debugPrint('Generating route for: ${routeSettings.name}');

    try {
      switch (routeSettings.name) {
        case ytMusic:
          return MaterialPageRoute(
            builder: (context) => const YTMusicSearchScreen(),
            settings: routeSettings,
          );
        case splash:
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(),
            settings: routeSettings,
          );
        case home:
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: routeSettings,
          );
        case nowPlaying:
          return MaterialPageRoute(
            builder: (context) => const NowPlayingScreen(),
            settings: routeSettings,
            fullscreenDialog: true,
          );
        case search:
          return MaterialPageRoute(
            builder: (context) => const SearchScreen(),
            settings: routeSettings,
          );
        case settings:
          return MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
            settings: routeSettings,
          );
        default:
          debugPrint('Unknown route: ${routeSettings.name}');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Page not found')),
            ),
            settings: routeSettings,
          );
      }
    } catch (e) {
      debugPrint('Error generating route: $e');
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Route Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, splash),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
        settings: routeSettings,
      );
    }
  }
}
