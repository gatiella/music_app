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
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        color: widget.isCurrentSong
            ? MusicAppTheme.primaryPurple.withAlpha((0.1 * 255).toInt())
            : null,
        border: widget.isCurrentSong
            ? Border.all(color: Colors.white.withAlpha((0.4 * 255).toInt()), width: 1.5)
            : null,
        boxShadow: widget.isCurrentSong
            ? [
                BoxShadow(
                  color: MusicAppTheme.primaryPurple.withAlpha(((0.3 * _glowAnimation.value) * 255).toInt()),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ]
            : null,
        child: Row(
          children: [
            _buildGlassAlbumArt(theme),
            const SizedBox(width: 16),
            Expanded(child: _buildSongInfo(theme)),
            const SizedBox(width: 12),
            _buildGlassTrailingActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularTile(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isCurrentSong
            ? theme.primaryColor.withAlpha((0.08 * 255).toInt())
            : (_isPressed
                  ? (isDark
                        ? Colors.white.withAlpha((0.05 * 255).toInt())
                        : Colors.black.withAlpha((0.03 * 255).toInt()))
                  : Colors.transparent),
        borderRadius: BorderRadius.circular(16),
        border: widget.isCurrentSong
            ? Border.all(color: theme.primaryColor.withAlpha((0.2 * 255).toInt()), width: 1)
            : null,
      ),
      child: Row(
        children: [
          _buildRegularAlbumArt(theme),
          const SizedBox(width: 12),
          Expanded(child: _buildSongInfo(theme)),
          const SizedBox(width: 8),
          _buildRegularTrailingActions(theme),
        ],
      ),
    );
  }

  Widget _buildGlassAlbumArt(ThemeData theme) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // Base album art container
          GlassContainer(
            width: 60,
            height: 60,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            color: widget.song.albumArt == null
                ? Colors.white.withAlpha((0.1 * 255).toInt())
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.song.albumArt != null
                  ? Image.network(
                      widget.song.albumArt!,
                      width: 60,
                      height: 60,
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MusicAppTheme.primaryPurple.withAlpha((0.8 * 255).toInt()),
                        MusicAppTheme.accentPink.withAlpha((0.8 * 255).toInt()),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated waves for playing state
                      if (widget.isPlaying)
                        ...List.generate(3, (index) {
                          return Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withAlpha(((0.3 * math.sin(_waveAnimation.value + index * 0.5).abs()) * 255).toInt()),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }),

                      // Play/Pause icon
                      Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha((0.9 * 255).toInt()),
                          ),
                          child: Icon(
                            widget.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: MusicAppTheme.primaryPurple,
                            size: 20,
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: widget.song.albumArt == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withAlpha((0.1 * 255).toInt()),
                  theme.primaryColor.withAlpha((0.05 * 255).toInt()),
                ],
              )
            : null,
        boxShadow: widget.isCurrentSong
            ? [
                BoxShadow(
                  color: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).toInt()),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (widget.song.albumArt != null)
              Image.network(
                widget.song.albumArt!,
                width: 56,
                height: 56,
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
                  color: theme.primaryColor.withAlpha((0.85 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey(widget.isPlaying),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultGlassArtwork() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha((0.2 * 255).toInt()),
            Colors.white.withAlpha((0.1 * 255).toInt()),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
  color: Colors.white.withAlpha((0.8 * 255).toInt()),
        size: 28,
      ),
    );
  }

  Widget _buildDefaultArtwork(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withAlpha((0.2 * 255).toInt()),
            theme.primaryColor.withAlpha((0.1 * 255).toInt()),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
  color: theme.primaryColor.withAlpha((0.6 * 255).toInt()),
        size: 24,
      ),
    );
  }

  Widget _buildSongInfo(ThemeData theme) {
    final textColor = widget.useGlass
        ? Colors.white
        : theme.colorScheme.onSurface;
    final secondaryColor = widget.useGlass
  ? Colors.white.withAlpha((0.8 * 255).toInt())
  : theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          widget.song.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: widget.isCurrentSong
                ? FontWeight.w600
                : FontWeight.w500,
            color: widget.isCurrentSong && widget.useGlass
                ? Colors.white
                : (widget.isCurrentSong
                      ? MusicAppTheme.primaryPurple
                      : textColor),
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // Artist and metadata row
        Row(
          children: [
            Expanded(
              child: Text(
                widget.song.artist,
                style: TextStyle(
                  color: widget.isCurrentSong && widget.useGlass
                      ? Colors.white.withAlpha((0.9 * 255).toInt())
                      : (widget.isCurrentSong
                            ? MusicAppTheme.primaryPurple.withAlpha((0.8 * 255).toInt())
                            : secondaryColor),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildMetadataRow(theme),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isGlass
                  ? Colors.red.withAlpha((0.2 * 255).toInt())
                  : Colors.red.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
              border: isGlass
                  ? Border.all(color: Colors.red.withAlpha((0.3 * 255).toInt()), width: 1)
                  : null,
            ),
            child: Icon(
              Icons.favorite,
              size: 12,
              color: isGlass ? Colors.red[300] : Colors.red[600],
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Duration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isGlass
                ? Colors.white.withAlpha((0.15 * 255).toInt())
                : theme.colorScheme.onSurface.withAlpha((0.08 * 255).toInt()),
            borderRadius: BorderRadius.circular(10),
            border: isGlass
                ? Border.all(color: Colors.white.withAlpha((0.2 * 255).toInt()), width: 1)
                : null,
          ),
          child: Text(
            widget.song.durationString,
            style: TextStyle(
              color: isGlass
                  ? Colors.white.withAlpha((0.9 * 255).toInt())
                  : theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),

        if (widget.song.playCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isGlass
                  ? MusicAppTheme.primaryPurple.withAlpha((0.2 * 255).toInt())
                  : theme.primaryColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
              border: isGlass
                  ? Border.all(
                      color: MusicAppTheme.primaryPurple.withAlpha((0.3 * 255).toInt()),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 10,
                  color: isGlass
                      ? Colors.white.withAlpha((0.9 * 255).toInt())
                      : theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.song.playCount.toString(),
                  style: TextStyle(
                    color: isGlass
                        ? Colors.white.withAlpha((0.9 * 255).toInt())
                        : theme.primaryColor,
                    fontSize: 10,
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
        width: 44,
        height: 44,
        child: Stack(
          children: [
            GlassContainer(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withAlpha((0.1 * 255).toInt()),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
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

    return GlassButton(
      onPressed: widget.onMorePressed,
      width: 44,
      height: 44,
      borderRadius: BorderRadius.circular(22),
  color: Colors.white.withAlpha((0.1 * 255).toInt()),
      child: Icon(
        Icons.more_vert_rounded,
        size: 20,
  color: Colors.white.withAlpha((0.8 * 255).toInt()),
      ),
    );
  }

  Widget _buildRegularTrailingActions(ThemeData theme) {
    if (widget.isCurrentSong && widget.isPlaying) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withAlpha((0.1 * 255).toInt()),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onMorePressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
      ),
    );
  }
}
