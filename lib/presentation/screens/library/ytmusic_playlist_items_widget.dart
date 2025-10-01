import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ytmusic_favorite.dart';
import '../../providers/ytmusic_playlist_items_provider.dart';
import '../ytmusic_video_screen.dart';

class YTMusicPlaylistItemsWidget extends StatelessWidget {
  final String playlistId;
  const YTMusicPlaylistItemsWidget({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<YTMusicPlaylistItemsProvider>(
      create: (_) => YTMusicPlaylistItemsProvider(
        playlistId: playlistId,
        playlistsProvider: Provider.of(context, listen: false),
        favoritesProvider: Provider.of(context, listen: false),
      )..loadItems(),
      child: Consumer<YTMusicPlaylistItemsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.items.isEmpty) {
            return const Center(child: Text('No items in this playlist.'));
          }
          return ReorderableListView(
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;
              final items = List<YTMusicFavorite>.from(provider.items);
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              await provider.reorderItems(items.map((e) => e.videoId).toList());
            },
            children: [
              for (final item in provider.items)
                ListTile(
                  key: ValueKey(item.videoId),
                  leading: item.thumbnailUrl.isNotEmpty
                      ? Image.network(item.thumbnailUrl, width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.music_video),
                  title: Text(item.title),
                  subtitle: Text(item.author),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.removeItem(item.videoId),
                    tooltip: 'Remove from playlist',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YTMusicVideoScreen(
                          videoId: item.videoId,
                          title: item.title,
                          author: item.author,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
