import 'package:flutter/foundation.dart';
import 'package:music_app/data/models/song.dart';
import 'package:music_app/data/repositories/music_repository.dart';



class MusicLibraryProvider extends ChangeNotifier {
  final MusicRepository _musicRepository;
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  MusicLibraryProvider({MusicRepository? musicRepository})
      : _musicRepository = musicRepository ?? MusicRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Get unique albums
  List<String> get albums {
    return _songs
        .map((song) => song.album)
        .where((album) => album.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Get unique artists
  List<String> get artists {
    return _songs
        .map((song) => song.artist)
        .where((artist) => artist.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }



  Future<void> loadMusic() async {
    _isLoading = true;
    notifyListeners();
    try {
      _songs = await _musicRepository.getAllSongs();
      // Removed print statement
    } catch (e) {
      // Removed print statement
      _songs = [];
    }
    _isLoading = false;
    notifyListeners();
  }




  // Get songs by album
  Future<List<Song>> getSongsByAlbum(String album) async {
    return await _musicRepository.getSongsByAlbum(album);
  }

  // Get songs by artist
  Future<List<Song>> getSongsByArtist(String artist) async {
    return await _musicRepository.getSongsByArtist(artist);
  }

  // Get favorite songs
  Future<List<Song>> getFavorites() async {
    return await _musicRepository.getFavoriteSongs();
  }

  // Get recently added songs (last 50 songs)
  Future<List<Song>> getRecentlyAdded() async {
    return await _musicRepository.getRecentlyAddedSongs(50);
  }

  // Get most played songs
  Future<List<Song>> getMostPlayed() async {
    return await _musicRepository.getMostPlayedSongs(50);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(int songId) async {
    // Implement favorite toggle using repository if available
    // await _musicRepository.toggleFavorite(songId);
    // For now, just update local state
    final songIndex = _songs.indexWhere((song) => song.id == songId);
    if (songIndex != -1) {
      _songs[songIndex] = _songs[songIndex].copyWith(
        isFavorite: !_songs[songIndex].isFavorite,
      );
      notifyListeners();
    }
  }

  // Increment play count
  Future<void> incrementPlayCount(int songId) async {
    // Implement play count increment using repository if available
    // await _musicRepository.incrementPlayCount(songId);
    // For now, just update local state
    final songIndex = _songs.indexWhere((song) => song.id == songId);
    if (songIndex != -1) {
      _songs[songIndex] = _songs[songIndex].copyWith(
        playCount: _songs[songIndex].playCount + 1,
        lastPlayed: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Search songs
  Future<List<Song>> searchSongs(String query) async {
    return await _musicRepository.searchSongs(query);
  }

  // Get song by ID
  Future<Song?> getSongById(int id) async {
    return await _musicRepository.getSongById(id);
  }
}
