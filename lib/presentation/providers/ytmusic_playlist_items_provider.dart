import 'package:flutter/material.dart';
import 'package:music_app/presentation/providers/ytmusic_favorites_provider.dart';
import 'package:music_app/presentation/providers/ytmusic_playlists_provider.dart';
import '../../../data/models/ytmusic_favorite.dart';


class YTMusicPlaylistItemsProvider extends ChangeNotifier {
  final String playlistId;
  final YTMusicPlaylistsProvider playlistsProvider;
  final YTMusicFavoritesProvider favoritesProvider;
  List<YTMusicFavorite> _items = [];
  bool _isLoading = false;

  YTMusicPlaylistItemsProvider({
    required this.playlistId,
    required this.playlistsProvider,
    required this.favoritesProvider,
  });

  List<YTMusicFavorite> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    final videoIds = await playlistsProvider.exportPlaylist(playlistId);
    _items = videoIds
        .map((id) => favoritesProvider.favorites.firstWhere(
              (fav) => fav.videoId == id,
              orElse: () => YTMusicFavorite(
                videoId: id,
                title: 'Unknown',
                author: '',
                thumbnailUrl: '',
                savedAt: DateTime.now(),
              ),
            ))
        .toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItems(List<String> videoIds) async {
    await playlistsProvider.addItems(playlistId, videoIds);
    await loadItems();
  }

  Future<void> removeItem(String videoId) async {
    await playlistsProvider.removeItems(playlistId, [videoId]);
    await loadItems();
  }

  Future<void> reorderItems(List<String> orderedVideoIds) async {
    await playlistsProvider.reorderItems(playlistId, orderedVideoIds);
    await loadItems();
  }
}
