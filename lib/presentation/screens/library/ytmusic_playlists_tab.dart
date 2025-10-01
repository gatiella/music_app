import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ytmusic_playlist.dart';
import '../../providers/ytmusic_playlists_provider.dart';
import 'ytmusic_playlist_details_screen.dart';

class YTMusicPlaylistsTab extends StatelessWidget {
  const YTMusicPlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<YTMusicPlaylistsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.playlists.isEmpty) {
              return const Center(child: Text('No YT Music playlists yet.'));
            }
            return ListView.builder(
              itemCount: provider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = provider.playlists[index];
                return ListTile(
                  leading: playlist.coverImageUrl != null && playlist.coverImageUrl!.isNotEmpty
                      ? Image.network(playlist.coverImageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.queue_music),
                  title: Text(playlist.name),
                  subtitle: Text(playlist.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.deletePlaylist(playlist.id),
                    tooltip: 'Delete playlist',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YTMusicPlaylistDetailsScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New Playlist'),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final coverController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create YT Music Playlist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: coverController,
                decoration: const InputDecoration(labelText: 'Cover Image URL'),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final desc = descController.text.trim();
              final cover = coverController.text.trim();
              final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final playlist = YTMusicPlaylist(
                id: id,
                name: name,
                createdAt: DateTime.now(),
                coverImageUrl: cover.isNotEmpty ? cover : null,
                description: desc.isNotEmpty ? desc : null,
                tags: tags.isNotEmpty ? tags : null,
              );
              await Provider.of<YTMusicPlaylistsProvider>(context, listen: false).addPlaylist(playlist);
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
