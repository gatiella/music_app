import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';

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
            final albumSongs = libraryProvider.getSongsByAlbum(album);
            final artist = albumSongs.isNotEmpty
                ? albumSongs.first.artist
                : 'Unknown Artist';
            final albumArt = albumSongs
                .firstWhere(
                  (song) => song.albumArt != null,
                  orElse: () => albumSongs.first,
                )
                .albumArt;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    _showAlbumSongs(context, album, albumSongs, artist),
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
                          color: Colors.grey[300],
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    audioProvider.playPlaylist(albumSongs);
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
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
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              '${albumSongs.length} track${albumSongs.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.grey[500],
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
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Icon(Icons.album, size: 48, color: Colors.white),
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
                    color: Colors.grey[400],
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
                          color: Colors.grey[300],
                        ),
                        child: albumArt != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(albumArt),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.album,
                                      size: 30,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.album,
                                size: 30,
                                color: Colors.grey,
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
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${songs.length} tracks',
                              style: TextStyle(
                                color: Colors.grey[500],
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
                                color: Colors.grey[300],
                              ),
                              child: Center(
                                child: Text(
                                  '${song.track ?? index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
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
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              song.durationString,
                              style: TextStyle(
                                color: isCurrentSong
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.7)
                                    : Colors.grey[600],
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
