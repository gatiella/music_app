import 'package:flutter/foundation.dart';
import '../../data/models/ytmusic_favorite.dart';
import '../../data/repositories/music_repository.dart';

class YTMusicFavoritesProvider extends ChangeNotifier {
  final MusicRepository _musicRepository;
  List<YTMusicFavorite> _favorites = [];
  bool _isLoading = false;

  YTMusicFavoritesProvider({MusicRepository? musicRepository})
      : _musicRepository = musicRepository ?? MusicRepository();

  List<YTMusicFavorite> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    final data = await _musicRepository.getAllYTMusicFavorites();
    _favorites = data.map((map) => YTMusicFavorite.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(YTMusicFavorite favorite) async {
    await _musicRepository.insertYTMusicFavorite(favorite.toMap());
    await loadFavorites();
  }

  Future<void> removeFavorite(String videoId) async {
    await _musicRepository.deleteYTMusicFavorite(videoId);
    await loadFavorites();
  }

  bool isFavorite(String videoId) {
    return _favorites.any((fav) => fav.videoId == videoId);
  }
}
