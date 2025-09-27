import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'theme.dart';
import '../presentation/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Show a loading indicator while theme preferences are loading
        if (!themeProvider.isInitialized) {
          return MaterialApp(
            title: 'Music Player',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home:
              const SplashScreen(), // Direct home instead of routing initially
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: (settings) {
            debugPrint('Unknown route: ${settings.name}');
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Unknown route: ${settings.name}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                          (route) => false,
                        ),
                        child: const Text('Go Home'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          builder: (context, child) {
            // Add error handling for child widget
            if (child == null) {
              debugPrint('MaterialApp child is null!');
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Navigation error occurred'),
                    ],
                  ),
                ),
              );
            }
            return child;
          },
        );
      },
    );
  }
}
