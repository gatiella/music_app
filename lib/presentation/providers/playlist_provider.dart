import 'package:flutter/foundation.dart';
import '../../data/models/playlist.dart';
import '../../data/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  final List<Song> _allSongs = [];

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  void setAllSongs(List<Song> songs) {
    _allSongs.clear();
    _allSongs.addAll(songs);
    notifyListeners();
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    notifyListeners();

    // TODO: Save to database
  }

  Future<void> updatePlaylist(String playlistId, String name,
      {String? description}) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: name,
        description: description,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      // TODO: Save to database
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
    // TODO: Delete from database
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1 && !_playlists[index].songIds.contains(songId)) {
      final updatedSongIds = List<String>.from(_playlists[index].songIds)
        ..add(songId);
      _playlists[index] = _playlists[index].copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      // TODO: Save to database
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedSongIds = List<String>.from(_playlists[index].songIds)
        ..remove(songId);
      _playlists[index] = _playlists[index].copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      // TODO: Save to database
    }
  }

  Future<void> reorderSongsInPlaylist(
      String playlistId, int oldIndex, int newIndex) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final songIds = List<String>.from(_playlists[index].songIds);
      final songId = songIds.removeAt(oldIndex);
      songIds.insert(newIndex, songId);

      _playlists[index] = _playlists[index].copyWith(
        songIds: songIds,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      // TODO: Save to database
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
    final originalPlaylist = getPlaylistById(playlistId);
    if (originalPlaylist != null) {
      final duplicatedPlaylist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName,
        description: originalPlaylist.description,
        songIds: List<String>.from(originalPlaylist.songIds),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _playlists.add(duplicatedPlaylist);
      notifyListeners();
      // TODO: Save to database
    }
  }

  Future<void> loadPlaylists() async {
    // TODO: Load playlists from database
    // This is a placeholder implementation
    _playlists = [];
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
