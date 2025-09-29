import 'package:flutter/foundation.dart';
import '../../data/models/playlist.dart';
import '../../data/models/song.dart';
import '../../data/repositories/playlist_repository.dart';


class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;
  List<Playlist> _playlists = [];
  final List<Song> _allSongs = [];

  PlaylistProvider({PlaylistRepository? playlistRepository})
      : _playlistRepository = playlistRepository ?? PlaylistRepository();

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  void setAllSongs(List<Song> songs) {
    _allSongs.clear();
    _allSongs.addAll(songs);
    notifyListeners();
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final playlistId = await _playlistRepository.createPlaylist(name, description: description);
    if (playlistId != null) {
      await loadPlaylists();
    }
  }

  Future<void> updatePlaylist(String playlistId, String name, {String? description}) async {
    final success = await _playlistRepository.updatePlaylist(playlistId, name, description: description);
    if (success) {
      await loadPlaylists();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final success = await _playlistRepository.deletePlaylist(playlistId);
    if (success) {
      await loadPlaylists();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final intId = int.tryParse(songId);
    if (intId == null) return;
    final success = await _playlistRepository.addSongToPlaylist(playlistId, intId);
    if (success == true) {
      await loadPlaylists();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final intId = int.tryParse(songId);
    if (intId == null) return;
    final success = await _playlistRepository.removeSongFromPlaylist(playlistId, intId);
    if (success == true) {
      await loadPlaylists();
    }
  }

  Future<void> reorderSongsInPlaylist(String playlistId, int oldIndex, int newIndex) async {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return;
    final songIds = List<String>.from(playlist.songIds);
    final songId = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, songId);
    // Convert songIds to int for repository
    final intSongIds = songIds.map((id) => int.tryParse(id)).whereType<int>().toList();
    final success = await _playlistRepository.reorderPlaylistSongs(playlistId, intSongIds);
    if (success == true) {
      await loadPlaylists();
    }
  }

  List<Song> getPlaylistSongs(String playlistId) {
    final playlist = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(
        id: '',
        name: '',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (playlist.id.isEmpty) return [];

    return playlist.songIds
        .map((songId) => _allSongs.firstWhere(
              (song) => song.id.toString() == songId,
              orElse: () => Song(
                id: 0,
                title: '',
                artist: '',
                album: '',
                path: '',
                duration: 0,
                size: 0,
              ),
            ))
        .where((song) => song.id != 0)
        .toList();
  }

  Playlist? getPlaylistById(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  bool isPlaylistEmpty(String playlistId) {
    final playlist = getPlaylistById(playlistId);
    return playlist?.songIds.isEmpty ?? true;
  }

  int getPlaylistSongCount(String playlistId) {
    final playlist = getPlaylistById(playlistId);
    return playlist?.songIds.length ?? 0;
  }

  Duration getPlaylistDuration(String playlistId) {
    final songs = getPlaylistSongs(playlistId);
    final totalMilliseconds = songs.fold(0, (sum, song) => sum + song.duration);
    return Duration(milliseconds: totalMilliseconds);
  }

  List<Playlist> searchPlaylists(String query) {
    if (query.isEmpty) return _playlists;

    return _playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(query.toLowerCase()) ||
          (playlist.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  Future<void> duplicatePlaylist(String playlistId, String newName) async {
    final newId = await _playlistRepository.duplicatePlaylist(playlistId, newName);
    if (newId != null) {
      await loadPlaylists();
    }
  }

  Future<void> loadPlaylists() async {
    _playlists = await _playlistRepository.getAllPlaylists();
    notifyListeners();
  }

  Future<void> exportPlaylist(String playlistId) async {
    // TODO: Implement playlist export functionality
    final playlist = getPlaylistById(playlistId);
    if (playlist != null) {
      debugPrint('Exporting playlist: ${playlist.name}');
    }
  }

  Future<void> importPlaylist(Map<String, dynamic> playlistData) async {
    // TODO: Implement playlist import functionality
    debugPrint('Importing playlist: ${playlistData['name']}');
  }
}
