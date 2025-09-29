import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../../data/models/song.dart';
import '../../providers/audio_player_provider.dart';

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, AudioPlayerProvider>(
      builder: (context, libraryProvider, audioProvider, child) {
        final artists = libraryProvider.artists;

        if (artists.isEmpty) {
          return const Center(child: Text('No artists found'));
        }

        return ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return FutureBuilder<List<Song>>(
              future: libraryProvider.getSongsByArtist(artist),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final artistSongs = snapshot.data ?? [];
                final albumCount = artistSongs.map((song) => song.album).toSet().length;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        artist.isNotEmpty ? artist[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      artist,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${artistSongs.length} song${artistSongs.length == 1 ? '' : 's'} • $albumCount album${albumCount == 1 ? '' : 's'}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        switch (value) {
                          case 'play':
                            audioProvider.playPlaylist(artistSongs);
                            break;
                          case 'shuffle':
                            final shuffled = List<Song>.from(artistSongs);
                            shuffled.shuffle();
                            audioProvider.playPlaylist(shuffled);
                            break;
                          case 'add_to_queue':
                            for (final song in artistSongs) {
                              audioProvider.addToQueue(song);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added ${artistSongs.length} songs to queue',
                                ),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'play',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 12),
                              Text('Play'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'shuffle',
                          child: Row(
                            children: [
                              Icon(Icons.shuffle),
                              SizedBox(width: 12),
                              Text('Shuffle'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'add_to_queue',
                          child: Row(
                            children: [
                              Icon(Icons.queue),
                              SizedBox(width: 12),
                              Text('Add to Queue'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showArtistSongs(context, artist, artistSongs),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showArtistSongs(
    BuildContext context,
    String artist,
    List<dynamic> songs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          artist.isNotEmpty ? artist[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${songs.length} songs',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<AudioPlayerProvider>(
                        builder: (context, audioProvider, child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final shuffled = List.from(songs);
                                  shuffled.shuffle();
                                  audioProvider.playPlaylist(shuffled.cast());
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.shuffle),
                              ),
                              IconButton(
                                onPressed: () {
                                  audioProvider.playPlaylist(songs.cast());
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 32,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Songs list
                Expanded(
                  child: Consumer<AudioPlayerProvider>(
                    builder: (context, audioProvider, child) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final isCurrentSong =
                              audioProvider.currentSong?.id == song.id;

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Theme.of(context).cardColor,
                              ),
                              child: song.albumArt != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        File(song.albumArt!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.music_note,
                                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                                size: 20,
                                              );
                                            },
                                      ),
                                    )
                                  : Icon(
                                      Icons.music_note,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                      size: 20,
                                    ),
                            ),
                            title: Text(
                              song.title,
                style: TextStyle(
                fontWeight: isCurrentSong
                  ? FontWeight.bold
                  : FontWeight.normal,
                color: isCurrentSong
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                            ),
                            subtitle: Text(
                              '${song.album} • ${song.durationString}',
                              style: TextStyle(
                                color: isCurrentSong
                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.7)
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                            trailing: isCurrentSong && audioProvider.isPlaying
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              audioProvider.playPlaylist(
                                songs.cast(),
                                startIndex: index,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
