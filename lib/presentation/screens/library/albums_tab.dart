import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../../data/models/song.dart';
import '../../../app/theme.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicLibraryProvider, AudioPlayerProvider>(
      builder: (context, libraryProvider, audioProvider, child) {
        final albums = libraryProvider.albums;

        if (albums.isEmpty) {
          return const Center(child: Text('No albums found'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return FutureBuilder<List<Song>>(
              future: libraryProvider.getSongsByAlbum(album),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final albumSongs = snapshot.data ?? <Song>[];
                final artist = albumSongs.isNotEmpty
                    ? albumSongs.first.artist
                    : 'Unknown Artist';
                final albumArt = albumSongs.isNotEmpty
                    ? (albumSongs.firstWhere(
                        (song) => song.albumArt != null,
                        orElse: () => albumSongs.first,
                      ).albumArt)
                    : null;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showAlbumSongs(context, album, albumSongs, artist),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Album art
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              color: Theme.of(context).cardColor,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                albumArt != null
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.file(
                                          File(albumArt),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildPlaceholder();
                                          },
                                        ),
                                      )
                                    : _buildPlaceholder(),
                                // Play button overlay
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        audioProvider.playPlaylist(albumSongs);
                                      },
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Album info
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artist,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  '${albumSongs.length} track${albumSongs.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).customColors.gradient1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  void _showAlbumSongs(
    BuildContext context,
    String album,
    List<dynamic> songs,
    String artist,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final albumArt = songs
              .firstWhere(
                (song) => song.albumArt != null,
                orElse: () => songs.first,
              )
              .albumArt;

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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).cardColor,
                        ),
                        child: albumArt != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(albumArt),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.album,
                                      size: 30,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.album,
                                size: 30,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              artist,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${songs.length} tracks',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 12,
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
                              child: Center(
                                child: Text(
                                  '${song.track ?? index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
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
                              song.durationString,
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
                                : IconButton(
                                    onPressed: () {
                                      // Show song options
                                    },
                                    icon: const Icon(Icons.more_vert),
                                    iconSize: 20,
                                  ),
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
