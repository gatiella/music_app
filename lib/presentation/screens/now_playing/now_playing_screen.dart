import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_player_provider.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Start rotation animation
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          final currentSong = audioProvider.currentSong;
          if (currentSong == null) {
            return const Center(child: Text('No song playing'));
          }

          return SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 32,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'From ${currentSong.album}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Show more options
                          _showMoreOptions(context);
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),

                // Album art section
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: audioProvider.isPlaying
                                ? _rotationController.value * 2 * 3.14159
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: currentSong.albumArt != null
                                    ? Image.network(
                                        currentSong.albumArt!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.7),
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.music_note,
                                                  size: 80,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Theme.of(
                                                context,
                                              ).primaryColor.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.music_note,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Song info section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        currentSong.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSong.artist,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Progress section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          trackHeight: 4,
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: audioProvider.progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            setState(() {});
                          },
                          onChangeEnd: (value) {
                            final position = Duration(
                              milliseconds:
                                  (value *
                                          audioProvider.duration.inMilliseconds)
                                      .round(),
                            );
                            audioProvider.seek(position);
                            setState(() {});
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            audioProvider.positionText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            audioProvider.durationText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Control buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => audioProvider.toggleShuffleMode(),
                        icon: Icon(
                          Icons.shuffle,
                          color: audioProvider.shuffleMode
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        iconSize: 28,
                      ),
                      IconButton(
                        onPressed: audioProvider.hasPrevious
                            ? () => audioProvider.seekToPrevious()
                            : null,
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40,
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => audioProvider.playPause(),
                          icon: Icon(
                            audioProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 36,
                        ),
                      ),
                      IconButton(
                        onPressed: audioProvider.hasNext
                            ? () => audioProvider.seekToNext()
                            : null,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () => audioProvider.toggleLoopMode(),
                        icon: Icon(
                          audioProvider.loopModeIcon,
                          color: audioProvider.loopMode != LoopMode.off
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Show queue
                        },
                        icon: const Icon(Icons.queue_music),
                      ),
                      IconButton(
                        onPressed: () {
                          // Toggle favorite
                        },
                        icon: Icon(
                          currentSong.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: currentSong.isFavorite
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Share song
                        },
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Add to playlist logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Go to Album'),
              onTap: () {
                Navigator.pop(context);
                // Go to album logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Go to Artist'),
              onTap: () {
                Navigator.pop(context);
                // Go to artist logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.equalizer),
              title: const Text('Equalizer'),
              onTap: () {
                Navigator.pop(context);
                // Show equalizer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Sleep Timer'),
              onTap: () {
                Navigator.pop(context);
                // Show sleep timer
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
