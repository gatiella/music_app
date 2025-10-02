import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../data/models/song.dart';
import 'package:music_app/app/theme.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';

class SongListTile extends StatefulWidget {
  final Song song;
  final bool isCurrentSong;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;
  final bool useGlass;
  final EdgeInsetsGeometry? margin;

  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isCurrentSong = false,
    this.isPlaying = false,
    this.onMorePressed,
    this.useGlass = true,
    this.margin,
  });

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late AnimationController _waveController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _waveAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    if (widget.isCurrentSong) {
      _glowController.repeat(reverse: true);
      if (widget.isPlaying) {
        _waveController.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(SongListTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCurrentSong != oldWidget.isCurrentSong) {
      if (widget.isCurrentSong) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && widget.isCurrentSong) {
        _waveController.repeat();
      } else {
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: widget.useGlass
                ? _buildGlassTile(theme)
                : _buildRegularTile(theme),
          ),
        );
      },
    );
  }

  Widget _buildGlassTile(ThemeData theme) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        color: widget.isCurrentSong
            ? MusicAppTheme.primaryPurple.withOpacity(0.1)
            : null,
        border: widget.isCurrentSong
            ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.0)
            : null,
        boxShadow: widget.isCurrentSong
            ? [
                BoxShadow(
                  color: MusicAppTheme.primaryPurple.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 15 * _glowAnimation.value,
                  spreadRadius: 1 * _glowAnimation.value,
                ),
              ]
            : null,
        child: Row(
          children: [
            _buildGlassAlbumArt(theme),
            const SizedBox(width: 12),
            Expanded(child: _buildSongInfo(theme)),
            const SizedBox(width: 8),
            _buildGlassTrailingActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularTile(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.isCurrentSong
            ? theme.primaryColor.withOpacity(0.08)
            : (_isPressed
                ? (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03))
                : Colors.transparent),
        borderRadius: BorderRadius.circular(14),
        border: widget.isCurrentSong
            ? Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Row(
        children: [
          _buildRegularAlbumArt(theme),
          const SizedBox(width: 10),
          Expanded(child: _buildSongInfo(theme)),
          const SizedBox(width: 6),
          _buildRegularTrailingActions(theme),
        ],
      ),
    );
  }

  Widget _buildGlassAlbumArt(ThemeData theme) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // Base album art container
          GlassContainer(
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(12),
            color: widget.song.albumArt == null
                ? Colors.white.withOpacity(0.1)
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.song.albumArt != null
                  ? Image.network(
                      widget.song.albumArt!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultGlassArtwork();
                      },
                    )
                  : _buildDefaultGlassArtwork(),
            ),
          ),

          // Animated overlay for current song
          if (widget.isCurrentSong)
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MusicAppTheme.primaryPurple.withOpacity(0.8),
                        MusicAppTheme.accentPink.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated waves for playing state
                      if (widget.isPlaying)
                        ...List.generate(2, (index) {
                          return Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3 * math.sin(_waveAnimation.value + index * 0.5).abs()),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        }),

                      // Play/Pause icon
                      Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          child: Icon(
                            widget.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: MusicAppTheme.primaryPurple,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRegularAlbumArt(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: widget.song.albumArt == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              )
            : null,
        boxShadow: widget.isCurrentSong
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if (widget.song.albumArt != null)
              Image.network(
                widget.song.albumArt!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultArtwork(theme);
                },
              )
            else
              _buildDefaultArtwork(theme),

            if (widget.isCurrentSong)
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(widget.isPlaying),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

Widget _buildSongInfo(ThemeData theme) {
  final textColor = widget.useGlass
      ? Colors.white
      : theme.colorScheme.onSurface;
  final secondaryColor = widget.useGlass
      ? Colors.white.withOpacity(0.8)
      : theme.colorScheme.onSurface.withOpacity(0.7);

  return Row(
    children: [
      // Song title & artist on the left
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              widget.song.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.isCurrentSong
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: widget.isCurrentSong && widget.useGlass
                    ? Colors.white
                    : (widget.isCurrentSong
                        ? MusicAppTheme.primaryPurple
                        : textColor),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Artist + metadata (without duration)
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.song.artist,
                    style: TextStyle(
                      color: widget.isCurrentSong && widget.useGlass
                          ? Colors.white.withOpacity(0.9)
                          : (widget.isCurrentSong
                              ? MusicAppTheme.primaryPurple.withOpacity(0.8)
                              : secondaryColor),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildMetadataRow(theme), // now only fav + play count
              ],
            ),
          ],
        ),
      ),

      const SizedBox(width: 8),

      // Duration on the far right
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.useGlass
              ? Colors.white.withOpacity(0.15)
              : theme.colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: widget.useGlass
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 0.8)
              : null,
        ),
        child: Text(
          widget.song.durationString,
          style: TextStyle(
            color: widget.useGlass
                ? Colors.white.withOpacity(0.9)
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ],
  );
}

Widget _buildMetadataRow(ThemeData theme) {
  final isGlass = widget.useGlass;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.song.isFavorite) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isGlass
                ? Colors.red.withOpacity(0.2)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: isGlass
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 0.8)
                : null,
          ),
          child: Icon(
            Icons.favorite,
            size: 10,
            color: isGlass ? Colors.red[300] : Colors.red[600],
          ),
        ),
        const SizedBox(width: 4),
      ],

      if (widget.song.playCount > 0) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isGlass
                ? MusicAppTheme.primaryPurple.withOpacity(0.2)
                : theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: isGlass
                ? Border.all(
                    color: MusicAppTheme.primaryPurple.withOpacity(0.3),
                    width: 0.8,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                size: 10,
                color: isGlass
                    ? Colors.white.withOpacity(0.9)
                    : theme.primaryColor,
              ),
              const SizedBox(width: 2),
              Text(
                widget.song.playCount.toString(),
                style: TextStyle(
                  color: isGlass
                      ? Colors.white.withOpacity(0.9)
                      : theme.primaryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}


  Widget _buildGlassTrailingActions(ThemeData theme) {
    if (widget.isCurrentSong && widget.isPlaying) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          children: [
            GlassContainer(
              width: 36,
              height: 36,
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.1),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(width: 36, height: 36);
  }

  Widget _buildRegularTrailingActions(ThemeData theme) {
    if (widget.isCurrentSong && widget.isPlaying) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withOpacity(0.1),
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
        ),
      );
    }

    return const SizedBox(width: 36, height: 36);
  }

  Widget _buildDefaultGlassArtwork() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withOpacity(0.8),
        size: 20,
      ),
    );
  }

  Widget _buildDefaultArtwork(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.2),
            theme.primaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: theme.primaryColor.withOpacity(0.6),
        size: 18,
      ),
    );
  }
}