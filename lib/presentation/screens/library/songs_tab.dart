import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/home/widgets/song_list_tile.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, AudioPlayerProvider>(
      builder: (context, libraryProvider, audioProvider, child) {
        final songs = libraryProvider.songs;

        return Column(
          children: [
            // Quick actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () {
                              audioProvider.playPlaylist(songs);
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () {
                              final shuffledSongs = List<dynamic>.from(songs);
                              shuffledSongs.shuffle();
                              audioProvider.playPlaylist(shuffledSongs.cast());
                            }
                          : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),

            // Songs count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${songs.length} songs',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Songs list
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final isCurrentSong =
                      audioProvider.currentSong?.id == song.id;

                  return SongListTile(
                    song: song,
                    isCurrentSong: isCurrentSong,
                    isPlaying: isCurrentSong && audioProvider.isPlaying,
                    onTap: () {
                      audioProvider.playPlaylist(songs, startIndex: index);
                    },
                    onMorePressed: () {
                      _showSongOptions(context, song);
                    },
                  );
                },
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to queue')));
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
                // Toggle favorite
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Show playlist selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share song
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
