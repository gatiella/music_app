import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/audio_player_provider.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Album rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Slide animation for UI elements
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Pulse animation for play button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _rotationController.repeat();
    _backgroundController.repeat();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          final currentSong = audioProvider.currentSong;

          if (currentSong == null) {
            return GradientBackground(
              child: Center(
                child: LoadingWidget(
                  message: 'No song playing',
                  useGlass: true,
                  color: Colors.white,
                ),
              ),
            );
          }

          // Control rotation based on play state
          if (audioProvider.isPlaying) {
            if (!_rotationController.isAnimating) {
              _rotationController.repeat();
            }
            if (!_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
            }
          } else {
            _rotationController.stop();
            _pulseController.stop();
          }

          return AnimatedBuilder(
            animation: _backgroundAnimation,
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
                        math.sin(_backgroundAnimation.value) * 0.3 + 0.7,
                      )!,
                      Color.lerp(
                        MusicAppTheme.secondaryGradient[0],
                        MusicAppTheme.accentPink,
                        math.cos(_backgroundAnimation.value * 0.8) * 0.3 + 0.7,
                      )!,
                      Color.lerp(
                        MusicAppTheme.primaryBlue,
                        MusicAppTheme.accentPink,
                        math.sin(_backgroundAnimation.value * 1.2) * 0.3 + 0.7,
                      )!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating background elements
                    ...List.generate(
                      5,
                      (index) => _buildFloatingElement(index),
                    ),

                    // Main content
                    SafeArea(
                      child: Column(
                        children: [
                          // Glass App Bar
                          _buildGlassAppBar(context, currentSong),

                          // Album art section
                          Expanded(
                            flex: 3,
                            child: _buildAlbumArtSection(
                              audioProvider,
                              currentSong,
                            ),
                          ),

                          // Song info section
                          _buildSongInfoSection(currentSong),

                          const SizedBox(height: 20),

                          // Progress section
                          _buildProgressSection(audioProvider),

                          const SizedBox(height: 30),

                          // Control buttons
                          _buildControlSection(audioProvider),

                          const SizedBox(height: 20),

                          // Bottom actions
                          _buildBottomActions(currentSong),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final size = MediaQuery.of(context).size;
    final random = math.Random(index);
    final elementSize = 30 + random.nextDouble() * 60;

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final offsetX =
            size.width * 0.1 +
            math.sin(_backgroundAnimation.value + index * 2) * size.width * 0.8;
        final offsetY =
            size.height * 0.1 +
            math.cos(_backgroundAnimation.value * 0.7 + index * 2) *
                size.height *
                0.8;

        return Positioned(
          left: offsetX,
          top: offsetY,
          child: Container(
            width: elementSize,
            height: elementSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1), Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassAppBar(BuildContext context, dynamic currentSong) {
    return GlassContainer(
      height: 80,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 32,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From ${currentSong.album ?? 'Unknown Album'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(context),
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArtSection(
    AudioPlayerProvider audioProvider,
    dynamic currentSong,
  ) {
    return Container(
      margin: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: audioProvider.isPlaying
                  ? _rotationController.value * 2 * math.pi
                  : 0,
              child: GlassContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(200),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: MusicAppTheme.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: currentSong.albumArt != null
                        ? Image.network(
                            currentSong.albumArt!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const PulsingLoadingWidget(
                                useGlass: false,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAlbumArt();
                            },
                          )
                        : _buildDefaultAlbumArt(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAlbumArt() {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: Theme.of(context).customColors.gradient1,
        ),
        child: Icon(Icons.music_note, size: 80, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildSongInfoSection(dynamic currentSong) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            currentSong.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            currentSong.artist,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AudioPlayerProvider audioProvider) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: audioProvider.progress.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {});
              },
              onChangeEnd: (value) {
                final position = Duration(
                  milliseconds: (value * audioProvider.duration.inMilliseconds)
                      .round(),
                );
                audioProvider.seek(position);
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audioProvider.positionText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                audioProvider.durationText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(AudioPlayerProvider audioProvider) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GlassButton(
            onPressed: () => audioProvider.toggleShuffleMode(),
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(25),
      color: audioProvider.shuffleMode
        ? MusicAppTheme.primaryPurple
  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            child: Icon(Icons.shuffle, color: Colors.white, size: 24),
          ),
          GlassButton(
            onPressed: audioProvider.hasPrevious
                ? () => audioProvider.seekToPrevious()
                : null,
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(30),
            child: Icon(
              Icons.skip_previous,
              color: audioProvider.hasPrevious
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
              size: 32,
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: audioProvider.isPlaying ? _pulseAnimation.value : 1.0,
                child: GlassButton(
                  onPressed: () => audioProvider.playPause(),
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      MusicAppTheme.primaryPurple,
                      MusicAppTheme.accentPink,
                    ],
                  ),
                  child: Icon(
                    audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          GlassButton(
            onPressed: audioProvider.hasNext
                ? () => audioProvider.seekToNext()
                : null,
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(30),
            child: Icon(
              Icons.skip_next,
              color: audioProvider.hasNext
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
              size: 32,
            ),
          ),
          GlassButton(
            onPressed: () => audioProvider.toggleLoopMode(),
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(25),
      color: audioProvider.loopMode != LoopMode.off
        ? MusicAppTheme.primaryPurple
  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            child: Icon(
              audioProvider.loopModeIcon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(dynamic currentSong) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GlassButton(
            onPressed: () {
              // Show queue
              _showQueue(context);
            },
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(25),
            child: Icon(Icons.queue_music, color: Theme.of(context).colorScheme.onPrimary, size: 24),
          ),
          GlassButton(
            onPressed: () {
              // Toggle favorite
              _toggleFavorite(currentSong);
            },
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(25),
            color: currentSong.isFavorite
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            child: Icon(
              currentSong.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: currentSong.isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          GlassButton(
            onPressed: () {
              // Share song
              _shareSong(currentSong);
            },
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(25),
            child: Icon(Icons.share, color: Theme.of(context).colorScheme.onPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
            ),
            _buildOptionTile(Icons.playlist_add, 'Add to Playlist', () {
              Navigator.pop(context);
              // Add to playlist logic
            }),
            _buildOptionTile(Icons.album, 'Go to Album', () {
              Navigator.pop(context);
              // Go to album logic
            }),
            _buildOptionTile(Icons.person, 'Go to Artist', () {
              Navigator.pop(context);
              // Go to artist logic
            }),
            _buildOptionTile(Icons.equalizer, 'Equalizer', () {
              Navigator.pop(context);
              // Show equalizer
            }),
            _buildOptionTile(Icons.timer, 'Sleep Timer', () {
              Navigator.pop(context);
              // Show sleep timer
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQueue(BuildContext context) {
    // Implement queue display
  }

  void _toggleFavorite(dynamic currentSong) {
    // Implement favorite toggle
  }

  void _shareSong(dynamic currentSong) {
    // Implement song sharing
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
