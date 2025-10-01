import 'package:flutter/material.dart';
import 'package:music_app/presentation/providers/ytmusic_favorites_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_playlist_items_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ytmusic_playlist.dart';
import '../../providers/ytmusic_playlists_provider.dart';
import 'ytmusic_playlist_items_widget.dart';

class YTMusicPlaylistDetailsScreen extends StatefulWidget {
  final YTMusicPlaylist playlist;
  const YTMusicPlaylistDetailsScreen({super.key, required this.playlist});

  @override
  State<YTMusicPlaylistDetailsScreen> createState() => _YTMusicPlaylistDetailsScreenState();
}

class _YTMusicPlaylistDetailsScreenState extends State<YTMusicPlaylistDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _coverController;
  late TextEditingController _tagsController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
    _descController = TextEditingController(text: widget.playlist.description ?? '');
    _coverController = TextEditingController(text: widget.playlist.coverImageUrl ?? '');
    _tagsController = TextEditingController(text: widget.playlist.tags?.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _coverController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Playlist' : 'Playlist Details'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
              tooltip: 'Edit',
            ),
          if (_editing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                final desc = _descController.text.trim();
                final cover = _coverController.text.trim();
                final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                await Provider.of<YTMusicPlaylistsProvider>(context, listen: false).updatePlaylist(
                  playlist.id,
                  name: name,
                  coverImageUrl: cover.isNotEmpty ? cover : null,
                  description: desc.isNotEmpty ? desc : null,
                  tags: tags.isNotEmpty ? tags : null,
                );
                setState(() => _editing = false);
              },
              tooltip: 'Save',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _editing ? _buildEditForm() : _buildDetailsView(),
      ),
    );
  }

  Widget _buildEditForm() {
    return ListView(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        TextField(
          controller: _coverController,
          decoration: const InputDecoration(labelText: 'Cover Image URL'),
        ),
        TextField(
          controller: _tagsController,
          decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    final playlist = widget.playlist;
    return ListView(
      children: [
        if (playlist.coverImageUrl != null && playlist.coverImageUrl!.isNotEmpty)
          Image.network(playlist.coverImageUrl!, height: 180, fit: BoxFit.cover),
        const SizedBox(height: 16),
        Text(playlist.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (playlist.description != null && playlist.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(playlist.description!),
          ),
        if (playlist.tags != null && playlist.tags!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: playlist.tags!.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Playlist Items', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    tooltip: 'Add from Favorites',
                    onPressed: () => _showBatchAddDialog(context, playlist.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share/Export',
                    onPressed: () => _showExportDialog(context, playlist.id),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: YTMusicPlaylistItemsWidget(playlistId: playlist.id),
        ),
      ],
    );

  }

  void _showBatchAddDialog(BuildContext context, String playlistId) {
    final favoritesProvider = Provider.of<YTMusicFavoritesProvider>(context, listen: false);
    final playlistItemsProvider = Provider.of<YTMusicPlaylistItemsProvider>(context, listen: false);
    final selected = <String>{};
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add from Favorites'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: ListView(
            children: favoritesProvider.favorites.map((fav) {
              return CheckboxListTile(
                value: selected.contains(fav.videoId),
                onChanged: (checked) {
                  if (checked == true) {
                    selected.add(fav.videoId);
                  } else {
                    selected.remove(fav.videoId);
                  }
                  // Force rebuild
                  (ctx as Element).markNeedsBuild();
                },
                title: Text(fav.title),
                subtitle: Text(fav.author),
                secondary: fav.thumbnailUrl.isNotEmpty
                    ? Image.network(fav.thumbnailUrl, width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.music_video),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selected.isNotEmpty) {
                await playlistItemsProvider.addItems(selected.toList());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, String playlistId) async {
    final playlistsProvider = Provider.of<YTMusicPlaylistsProvider>(context, listen: false);
    final videoIds = await playlistsProvider.exportPlaylist(playlistId);
    final exportText = videoIds.join(', ');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Playlist'),
        content: SelectableText(exportText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
