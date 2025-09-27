import 'package:flutter/material.dart';
import '../../../../data/models/song.dart';

class SongListTile extends StatefulWidget {
  final Song song;
  final bool isCurrentSong;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;

  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isCurrentSong = false,
    this.isPlaying = false,
    this.onMorePressed,
  });

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isCurrentSong
                    ? theme.primaryColor.withOpacity(0.08)
                    : (_isPressed
                          ? (isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03))
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(16),
                border: widget.isCurrentSong
                    ? Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Album Art with modern styling
                  _buildAlbumArt(theme),
                  const SizedBox(width: 12),

                  // Song Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          widget.song.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: widget.isCurrentSong
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isCurrentSong
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Artist and metadata row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.song.artist,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: widget.isCurrentSong
                                      ? theme.primaryColor.withOpacity(0.8)
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.7,
                                        ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Metadata chips
                            _buildMetadataRow(theme),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Trailing actions
                  _buildTrailingActions(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(ThemeData theme) {
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
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              )
            : null,
        boxShadow: widget.isCurrentSong
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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

            // Play/pause overlay for current song
            if (widget.isCurrentSong)
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.85),
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

  Widget _buildDefaultArtwork(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
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
        size: 24,
      ),
    );
  }

  Widget _buildMetadataRow(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.song.isFavorite) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.favorite, size: 12, color: Colors.red[600]),
          ),
          const SizedBox(width: 6),
        ],

        // Duration
        Text(
          widget.song.durationString,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        if (widget.song.playCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 10,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 3),
                Text(
                  widget.song.playCount.toString(),
                  style: TextStyle(
                    color: theme.primaryColor,
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

  Widget _buildTrailingActions(ThemeData theme) {
    if (widget.isCurrentSong && widget.isPlaying) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withOpacity(0.1),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
