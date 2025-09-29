import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/core/widgets/mini_player.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/music_library_provider.dart';
import '../library/library_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../now_playing/now_playing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  final List<Widget> _pages = [
    const LibraryScreen(),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Load music library on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicLibraryProvider>().loadMusic();
    });

    // Initialize gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );

    _gradientController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed extendBodyBehindAppBar to fix layout assertion error
      extendBody: true,
      appBar: AppBar(
        title: const Text('Music App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.music_video),
            tooltip: 'YouTube Music',
            onPressed: () {
              Navigator.pushNamed(context, '/ytmusic');
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    MusicAppTheme.primaryGradient[0],
                    MusicAppTheme.primaryGradient[1],
                    math.sin(_gradientAnimation.value) * 0.5 + 0.5,
                  )!,
                  Color.lerp(
                    MusicAppTheme.secondaryGradient[0],
                    MusicAppTheme.secondaryGradient[1],
                    math.cos(_gradientAnimation.value * 0.8) * 0.5 + 0.5,
                  )!,
                  Color.lerp(
                    MusicAppTheme.primaryGradient[1],
                    MusicAppTheme.accentPink,
                    math.sin(_gradientAnimation.value * 1.2) * 0.5 + 0.5,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                ...List.generate(6, (index) => _buildFloatingOrb(index)),

                // Main content
                Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        children: _pages.map((page) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: page,
                          );
                        }).toList(),
                      ),
                    ),

                    // Glassmorphism Mini Player
                    Consumer<AudioPlayerProvider>(
                      builder: (context, audioProvider, child) {
                        if (audioProvider.currentSong != null) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NowPlayingScreen(),
                                ),
                              );
                            },
                            child: MiniPlayer(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NowPlayingScreen(),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      // Glassmorphism Bottom Navigation
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          GlassBottomNavItem(
            icon: Icons.library_music_outlined,
            activeIcon: Icons.library_music,
            label: 'Library',
          ),
          GlassBottomNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
          ),
          GlassBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(int index) {
    final size = MediaQuery.of(context).size;
    final random = math.Random(index);
    final orbSize = 20 + random.nextDouble() * 40;

    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        final offsetX =
            size.width * 0.1 +
            math.sin(_gradientAnimation.value + index) * size.width * 0.8;
        final offsetY =
            size.height * 0.1 +
            math.cos(_gradientAnimation.value * 0.7 + index) *
                size.height *
                0.8;

        return Positioned(
          left: offsetX,
          top: offsetY,
          child: Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Theme.of(context).colorScheme.onPrimary.withAlpha((0.2 * 255).toInt()), Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gradientController.dispose();
    super.dispose();
  }
}
