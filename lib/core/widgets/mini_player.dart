import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/audio_player_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final currentSong = audioProvider.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: audioProvider.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 2,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Album art
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: currentSong.albumArt != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  currentSong.albumArt!,
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.music_note,
                                      color: Colors.grey[600],
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.music_note,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Song info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Previous button
                      IconButton(
                        onPressed: audioProvider.hasPrevious
                            ? () => audioProvider.seekToPrevious()
                            : null,
                        icon: Icon(
                          Icons.skip_previous,
                          color: audioProvider.hasPrevious
                              ? Theme.of(context).iconTheme.color
                              : Colors.grey[400],
                        ),
                        iconSize: 24,
                      ),

                      // Play/pause button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: IconButton(
                          onPressed: () => audioProvider.playPause(),
                          icon: Icon(
                            audioProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                        ),
                      ),

                      // Next button
                      IconButton(
                        onPressed: audioProvider.hasNext
                            ? () => audioProvider.seekToNext()
                            : null,
                        icon: Icon(
                          Icons.skip_next,
                          color: audioProvider.hasNext
                              ? Theme.of(context).iconTheme.color
                              : Colors.grey[400],
                        ),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
