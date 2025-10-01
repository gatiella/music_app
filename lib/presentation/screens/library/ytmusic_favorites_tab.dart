import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ytmusic_favorites_provider.dart';
import '../../screens/ytmusic_video_screen.dart';

class YTMusicFavoritesTab extends StatelessWidget {
  const YTMusicFavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<YTMusicFavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.favorites.isEmpty) {
          return const Center(child: Text('No YT Music favorites yet.'));
        }
        return ListView.builder(
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final fav = provider.favorites[index];
            return ListTile(
              leading: fav.thumbnailUrl.isNotEmpty
                  ? Image.network(fav.thumbnailUrl, width: 56, height: 56, fit: BoxFit.cover)
                  : const Icon(Icons.music_video),
              title: Text(fav.title),
              subtitle: Text(fav.author),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => provider.removeFavorite(fav.videoId),
                tooltip: 'Remove from favorites',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => YTMusicVideoScreen(
                      videoId: fav.videoId,
                      title: fav.title,
                      author: fav.author,
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
}
