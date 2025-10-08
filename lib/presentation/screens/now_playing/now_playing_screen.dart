import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/audio_player_provider.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:music_app/presentation/widgets/lyrics_widget.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with TickerProviderStateMixin {
  void _showLyrics(BuildContext context, String artist, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => GlassContainer(
          borderRadius: BorderRadius.circular(24),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          child: LyricsWidget(artist: artist, title: title),
        ),
      ),
    );
  }

  late AnimationController _rotationController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _backgroundController.repeat();
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
                child: SafeArea(
                  child: Column(
                    children: [
                      // Simple top bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            Text(
                              'Now Playing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showMoreOptions(context),
                              icon: Icon(Icons.more_vert, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Album art - larger and cleaner
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: audioProvider.isPlaying
                                      ? _rotationController.value * 2 * math.pi
                                      : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: MusicAppTheme.primaryPurple.withOpacity(0.4),
                                          blurRadius: 40,
                                          spreadRadius: 10,
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
                                                return const PulsingLoadingWidget(useGlass: false);
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildDefaultAlbumArt();
                                              },
                                            )
                                          : _buildDefaultAlbumArt(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Song info - cleaner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Progress section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.2),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                trackHeight: 3,
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              ),
                              child: Slider(
                                value: audioProvider.progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  setState(() {});
                                },
                                onChangeEnd: (value) {
                                  final position = Duration(
                                    milliseconds: (value * audioProvider.duration.inMilliseconds).round(),
                                  );
                                  audioProvider.seek(position);
                                  setState(() {});
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    audioProvider.positionText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    audioProvider.durationText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Control buttons - simplified
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () => audioProvider.toggleShuffleMode(),
                              icon: Icon(
                                Icons.shuffle,
                                color: audioProvider.shuffleMode
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 26,
                              ),
                            ),
                            IconButton(
                              onPressed: audioProvider.hasPrevious
                                  ? () => audioProvider.seekToPrevious()
                                  : null,
                              icon: Icon(
                                Icons.skip_previous,
                                color: audioProvider.hasPrevious
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                                size: 36,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: audioProvider.isPlaying ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () => audioProvider.playPause(),
                                      icon: Icon(
                                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: MusicAppTheme.primaryPurple,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: audioProvider.hasNext
                                  ? () => audioProvider.seekToNext()
                                  : null,
                              icon: Icon(
                                Icons.skip_next,
                                color: audioProvider.hasNext
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                                size: 36,
                              ),
                            ),
                            IconButton(
                              onPressed: () => audioProvider.toggleLoopMode(),
                              icon: Icon(
                                audioProvider.loopModeIcon,
                                color: audioProvider.loopMode != LoopMode.off
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bottom actions - simplified
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () => _showLyrics(context, currentSong.artist, currentSong.title),
                              icon: Icon(Icons.lyrics_outlined, color: Colors.white.withOpacity(0.8), size: 24),
                            ),
                            IconButton(
                              onPressed: () => _toggleFavorite(currentSong),
                              icon: Icon(
                                currentSong.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: currentSong.isFavorite 
                                    ? Colors.red 
                                    : Colors.white.withOpacity(0.8),
                                size: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showQueue(context),
                              icon: Icon(Icons.queue_music, color: Colors.white.withOpacity(0.8), size: 24),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            MusicAppTheme.primaryPurple,
            MusicAppTheme.accentPink,
          ],
        ),
      ),
      child: Icon(Icons.music_note, size: 100, color: Colors.white),
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
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(Icons.playlist_add, 'Add to Playlist', () {
              Navigator.pop(context);
            }),
            _buildOptionTile(Icons.share, 'Share', () {
              Navigator.pop(context);
            }),
            _buildOptionTile(Icons.info_outline, 'Song Info', () {
              Navigator.pop(context);
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
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
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

  @override
  void dispose() {
    _rotationController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}