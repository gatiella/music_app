import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/audio_player_provider.dart';
import 'package:music_app/app/theme.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback? onTap;
  final bool showWhenNoSong;
  final EdgeInsetsGeometry? margin;

  const MiniPlayer({
    super.key,
    this.onTap,
    this.showWhenNoSong = false,
    this.margin,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPlayer() {
    _animationController.forward();
  }

  void _hidePlayer() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;

        // Show/hide animation based on song availability
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentSong != null) {
            _showPlayer();
          } else if (!widget.showWhenNoSong) {
            _hidePlayer();
          }
        });

        if (currentSong == null && !widget.showWhenNoSong) {
          return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: const SizedBox.shrink(),
                ),
              );
            },
          );
        }

        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildMiniPlayer(context, audioProvider, currentSong),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniPlayer(
    BuildContext context,
    AudioPlayerProvider audioProvider,
    dynamic currentSong,
  ) {
    if (currentSong == null) {
      return _buildPlaceholderPlayer(context);
    }

    return GestureDetector(
      onTap: widget.onTap ?? () => _navigateToFullPlayer(context),
      child: GlassBottomPlayer(
        albumArt: currentSong.albumArt,
        title: currentSong.title,
        artist: currentSong.artist,
        isPlaying: audioProvider.isPlaying,
        progress: audioProvider.progress.clamp(0.0, 1.0),
        onPlayPause: () => audioProvider.playPause(),
        onNext: audioProvider.hasNext ? () => audioProvider.seekToNext() : null,
        onPrevious: audioProvider.hasPrevious
            ? () => audioProvider.seekToPrevious()
            : null,
        onTap: widget.onTap ?? () => _navigateToFullPlayer(context),
      ),
    );
  }

  Widget _buildPlaceholderPlayer(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    return GlassContainer(
      height: 90,
      margin: widget.margin ?? const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          // Placeholder progress bar
          Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: customColors.glassBorder,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Placeholder album art
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: customColors.glassContainer,
                ),
                child: Icon(
                  Icons.music_note,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Placeholder song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: customColors.glassBorder,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: customColors.glassContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Placeholder controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: theme.colorScheme.onPrimary.withOpacity(0.5),
                      size: 28,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: customColors.glassBorder,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: theme.colorScheme.onPrimary.withOpacity(0.5),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToFullPlayer(BuildContext context) {
    // Navigate to full player screen
    Navigator.pushNamed(context, '/player');
  }
}

// Alternative version with more customization options
class CustomMiniPlayer extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showControls;
  final bool showProgress;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableSwipeGestures;

  const CustomMiniPlayer({
    super.key,
    this.onTap,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.showControls = true,
    this.showProgress = true,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.enableSwipeGestures = true,
  });

  @override
  State<CustomMiniPlayer> createState() => _CustomMiniPlayerState();
}

class _CustomMiniPlayerState extends State<CustomMiniPlayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        Widget player = GlassContainer(
          height: widget.height ?? 90,
          margin: widget.margin ?? const EdgeInsets.all(16),
          padding: widget.padding ?? const EdgeInsets.all(12),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
          child: InkWell(
            onTap: widget.onTap ?? () => _navigateToFullPlayer(context),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
            child: Column(
              children: [
                // Progress bar
                if (widget.showProgress)
                  LinearProgressIndicator(
                    value: audioProvider.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MusicAppTheme.primaryPurple,
                    ),
                    minHeight: 2,
                  ),
                if (widget.showProgress) const SizedBox(height: 12),

                Expanded(
                  child: Row(
                    children: [
                      // Album Art
                      _buildAlbumArt(currentSong),
                      const SizedBox(width: 16),

                      // Song Info
                      Expanded(child: _buildSongInfo(context, currentSong)),

                      // Controls
                      if (widget.showControls) _buildControls(audioProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (widget.enableSwipeGestures) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe right - previous
                if (audioProvider.hasPrevious) {
                  audioProvider.seekToPrevious();
                }
              } else if (details.primaryVelocity! < 0) {
                // Swipe left - next
                if (audioProvider.hasNext) {
                  audioProvider.seekToNext();
                }
              }
            },
            child: player,
          );
        }

        return player;
      },
    );
  }

  Widget _buildAlbumArt(dynamic currentSong) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.3),
        image: currentSong.albumArt != null
            ? DecorationImage(
                image: NetworkImage(currentSong.albumArt!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: currentSong.albumArt == null
          ? const Icon(Icons.music_note, color: Colors.white, size: 24)
          : null,
    );
  }

  Widget _buildSongInfo(BuildContext context, dynamic currentSong) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentSong.title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          currentSong.artist,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: audioProvider.hasPrevious
              ? widget.onPrevious ?? () => audioProvider.seekToPrevious()
              : null,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: audioProvider.hasPrevious
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            size: 28,
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [MusicAppTheme.primaryPurple, MusicAppTheme.accentPink],
            ),
          ),
          child: IconButton(
            onPressed: widget.onPlayPause ?? () => audioProvider.playPause(),
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        IconButton(
          onPressed: audioProvider.hasNext
              ? widget.onNext ?? () => audioProvider.seekToNext()
              : null,
          icon: Icon(
            Icons.skip_next_rounded,
            color: audioProvider.hasNext
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            size: 28,
          ),
        ),
      ],
    );
  }

  void _navigateToFullPlayer(BuildContext context) {
    Navigator.pushNamed(context, '/player');
  }
}
