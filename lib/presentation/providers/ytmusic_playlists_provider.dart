import 'package:flutter/foundation.dart';
import '../../data/models/ytmusic_playlist.dart';
import '../../data/repositories/music_repository.dart';

class YTMusicPlaylistsProvider extends ChangeNotifier {
  final MusicRepository _musicRepository;
  List<YTMusicPlaylist> _playlists = [];
  bool _isLoading = false;

  YTMusicPlaylistsProvider({MusicRepository? musicRepository})
      : _musicRepository = musicRepository ?? MusicRepository();

  List<YTMusicPlaylist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();
    final data = await _musicRepository.getAllYTMusicPlaylists();
    _playlists = data.map((map) => YTMusicPlaylist.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlaylist(YTMusicPlaylist playlist) async {
    await _musicRepository.insertYTMusicPlaylist(playlist.toMap());
    await loadPlaylists();
  }

  Future<void> updatePlaylist(String playlistId, {String? name, String? coverImageUrl, String? description, List<String>? tags}) async {
    await _musicRepository.updateYTMusicPlaylist(
      playlistId,
      name: name,
      coverImageUrl: coverImageUrl,
      description: description,
      tags: tags,
    );
    await loadPlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _musicRepository.deleteYTMusicPlaylist(playlistId);
    await loadPlaylists();
  }

  // Add, remove, reorder, and export items
  Future<void> addItems(String playlistId, List<String> videoIds) async {
    await _musicRepository.addYTMusicItemsToPlaylist(playlistId, videoIds);
    // Optionally reload playlist items here
  }

  Future<void> removeItems(String playlistId, List<String> videoIds) async {
    await _musicRepository.removeYTMusicItemsFromPlaylist(playlistId, videoIds);
    // Optionally reload playlist items here
  }

  Future<void> reorderItems(String playlistId, List<String> orderedVideoIds) async {
    await _musicRepository.reorderYTMusicPlaylistItems(playlistId, orderedVideoIds);
    // Optionally reload playlist items here
  }

  Future<List<String>> exportPlaylist(String playlistId) async {
    return await _musicRepository.exportYTMusicPlaylist(playlistId);
  }
}
