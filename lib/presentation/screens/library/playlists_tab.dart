import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_app/data/models/playlist.dart';
import 'package:music_app/data/models/song.dart';
import 'package:provider/provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../../app/theme.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, MusicLibraryProvider>(
      builder: (context, playlistProvider, libraryProvider, child) {
        return Column(
          children: [
            // Quick access playlists
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Access',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<List<Song>>(
                          future: libraryProvider.getFavorites(),
                          builder: (context, snapshot) {
                            final favorites = snapshot.data ?? <Song>[];
                            return _buildQuickPlaylistCard(
                              context,
                              'Favorites',
                              '${favorites.length} songs',
                              Icons.favorite,
                              Theme.of(context).colorScheme.error,
                              () {
                                if (favorites.isNotEmpty) {
                                  _showPlaylistSongs(
                                    context,
                                    'Favorites',
                                    favorites,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No favorite songs'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FutureBuilder<List<Song>>(
                          future: libraryProvider.getRecentlyAdded(),
                          builder: (context, snapshot) {
                            final recent = snapshot.data ?? <Song>[];
                            return _buildQuickPlaylistCard(
                              context,
                              'Recently Added',
                              '${recent.length} songs',
                              Icons.schedule,
                              Theme.of(context).colorScheme.secondary,
                              () {
                                if (recent.isNotEmpty) {
                                  _showPlaylistSongs(
                                    context,
                                    'Recently Added',
                                    recent,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No recently added songs'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<List<Song>>(
                          future: libraryProvider.getMostPlayed(),
                          builder: (context, snapshot) {
                            final mostPlayed = snapshot.data ?? <Song>[];
                            return _buildQuickPlaylistCard(
                              context,
                              'Most Played',
                              '${mostPlayed.length} songs',
                              Icons.trending_up,
                              Theme.of(context).colorScheme.primary,
                              () {
                                if (mostPlayed.isNotEmpty) {
                                  _showPlaylistSongs(
                                    context,
                                    'Most Played',
                                    mostPlayed,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No play history'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickPlaylistCard(
                          context,
                          'All Songs',
                          '${libraryProvider.songs.length} songs',
                          Icons.library_music,
                              Theme.of(context).colorScheme.tertiary,
                          () {
                            if (libraryProvider.songs.isNotEmpty) {
                              _showPlaylistSongs(
                                context,
                                'All Songs',
                                libraryProvider.songs,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Custom playlists section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Playlists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showCreatePlaylistDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                  ),
                ],
              ),
            ),
            // Custom playlists list
            Expanded(
              child: playlistProvider.playlists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_add,
                            size: 64,
                            color: Theme.of(context).dividerColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No playlists yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first playlist to get started',
                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showCreatePlaylistDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Playlist'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: playlistProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlistProvider.playlists[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: Theme.of(context).customColors.gradient1,
                              ),
                              child: const Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              playlist.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${playlist.songIds.length} song${playlist.songIds.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                switch (value) {
                                  case 'play':
                                    _playPlaylist(context, playlist);
                                    break;
                                  case 'edit':
                                    _showEditPlaylistDialog(context, playlist);
                                    break;
                                  case 'delete':
                                    _showDeletePlaylistDialog(
                                      context,
                                      playlist,
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
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 12),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 12),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              final playlistSongs = playlistProvider.getPlaylistSongs(playlist.id);
                              _showPlaylistSongs(
                                context,
                                playlist.name,
                                playlistSongs,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickPlaylistCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistSongs(
    BuildContext context,
    String playlistName,
    List<Song> songs,
  ) {
    final audioProvider = Provider.of<AudioPlayerProvider>(
      context,
      listen: false,
    );

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
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: Theme.of(context).customColors.gradient1,
                        ),
                        child: const Icon(
                          Icons.playlist_play,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlistName,
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
                      IconButton(
                        onPressed: () {
                          if (songs.isNotEmpty) {
                            final shuffled = List<Song>.from(songs);
                            shuffled.shuffle();
                            audioProvider.playPlaylist(shuffled);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.shuffle),
                      ),
                      IconButton(
                        onPressed: () {
                          if (songs.isNotEmpty) {
                            audioProvider.playPlaylist(songs);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: songs.isEmpty
                      ? const Center(child: Text('No songs in this playlist'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
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
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                  size: 20,
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.music_note,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        size: 20,
                                      ),
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${song.artist} • ${song.durationString}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  _showSongOptions(context, song);
                                },
                                icon: const Icon(Icons.more_vert),
                              ),
                              onTap: () {
                                audioProvider.playPlaylist(
                                  songs,
                                  startIndex: index,
                                );
                                Navigator.pop(context);
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

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'Enter playlist name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                playlistProvider.createPlaylist(name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playlist "$name" created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'Enter playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                playlistProvider.updatePlaylist(playlist.id, name);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(BuildContext context, Playlist playlist) {
    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              playlistProvider.deletePlaylist(playlist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Playlist "${playlist.name}" deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _playPlaylist(BuildContext context, Playlist playlist) {
    final audioProvider = Provider.of<AudioPlayerProvider>(
      context,
      listen: false,
    );
    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );

    final songs = playlistProvider.getPlaylistSongs(playlist.id);
    if (songs.isNotEmpty) {
      audioProvider.playPlaylist(songs);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playlist is empty')));
    }
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AudioPlayerProvider>(
                  context,
                  listen: false,
                ).playSong(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<MusicLibraryProvider>(
                  context,
                  listen: false,
                ).toggleFavorite(song.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlistProvider.playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlistProvider.playlists[index];
              return ListTile(
                title: Text(playlist.name),
                subtitle: Text('${playlist.songIds.length} songs'),
                onTap: () {
                  playlistProvider.addSongToPlaylist(
                    playlist.id,
                    song.id.toString(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to "${playlist.name}"')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
