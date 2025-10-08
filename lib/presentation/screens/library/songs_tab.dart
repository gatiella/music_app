import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/home/widgets/song_list_tile.dart';
import 'package:music_app/presentation/screens/now_playing/now_playing_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';

class SongsTab extends StatefulWidget {
  const SongsTab({super.key});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, AudioPlayerProvider>(
      builder: (context, libraryProvider, audioProvider, child) {
        final songs = libraryProvider.songs;

        return Stack(
          children: [
            Column(
              children: [
                // Songs count
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${songs.length} songs',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Songs list with smooth scrolling - REMOVED ShaderMask
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 100, top: 4),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isCurrentSong = audioProvider.currentSong?.id == song.id;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 200 + (index * 50).clamp(0, 400)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: SongListTile(
                          song: song,
                          isCurrentSong: isCurrentSong,
                          isPlaying: isCurrentSong && audioProvider.isPlaying,
                          onTap: () {
                            audioProvider.playPlaylist(songs, startIndex: index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NowPlayingScreen(),
                              ),
                            );
                          },
                          onMorePressed: () {
                            _showSongOptions(context, song);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Scroll to top button
            if (_showScrollToTop)
              Positioned(
                right: 16,
                bottom: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: _scrollToTop,
                        iconSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                ),
                child: song.albumArt != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          song.albumArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
              title: Text(
                song.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(song.artist),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                context.read<AudioPlayerProvider>().playSong(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Add to Queue'),
              onTap: () {
                Navigator.pop(context);
                context.read<AudioPlayerProvider>().addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to queue')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                song.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: song.isFavorite ? Theme.of(context).colorScheme.error : null,
              ),
              title: Text(
                song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Song Info'),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSongInfo(BuildContext context, song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Song Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title:', song.title),
            _buildInfoRow('Artist:', song.artist),
            _buildInfoRow('Album:', song.album),
            _buildInfoRow('Duration:', song.durationString),
            _buildInfoRow('Size:', song.sizeString),
            if (song.genre != null) _buildInfoRow('Genre:', song.genre!),
            if (song.year != null) _buildInfoRow('Year:', song.year.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}