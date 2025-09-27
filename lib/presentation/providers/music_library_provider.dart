import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/data/models/song.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicLibraryProvider extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> get songs => _songs;

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
      // Check if running on web/desktop - on_audio_query doesn't work there
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // Load mock data for web/desktop testing
        _loadMockData();
      } else {
        // Use on_audio_query for mobile platforms
        await _loadFromDevice();
      }

      print('Loaded ${_songs.length} songs');
    } catch (e) {
      print('Error loading music: $e');
      // Load mock data as fallback
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromDevice() async {
    final audioQuery = OnAudioQuery();

    // Check permissions first
    bool permissionStatus = await audioQuery.permissionsStatus();
    if (!permissionStatus) {
      bool permissionRequest = await audioQuery.permissionsRequest();
      if (!permissionRequest) {
        print('Permission denied');
        return;
      }
    }

    final songList = await audioQuery.querySongs();

    _songs = songList.map((song) {
      try {
        // Convert SongModel to Song - only use properties that exist on SongModel
        return Song(
          id: song.id,
          title: song.title.isNotEmpty ? song.title : 'Unknown Title',
          artist: song.artist?.isNotEmpty == true
              ? song.artist!
              : 'Unknown Artist',
          album: song.album?.isNotEmpty == true ? song.album! : 'Unknown Album',
          albumArt: null, // SongModel doesn't provide album art directly
          path: song.data,
          duration: song.duration ?? 0,
          genre: song.genre,
          year: null, // SongModel doesn't have year property
          track: song.track,
          size: song.size,
          dateAdded: song.dateAdded != null
              ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded! * 1000)
              : null,
          dateModified: song.dateModified != null
              ? DateTime.fromMillisecondsSinceEpoch(song.dateModified! * 1000)
              : null,
          isFavorite: false,
          playCount: 0,
          lastPlayed: null,
        );
      } catch (e) {
        print('Error converting song: $e');
        // Return a default song if conversion fails
        return Song(
          id: song.id,
          title: 'Unknown Title',
          artist: 'Unknown Artist',
          album: 'Unknown Album',
          path: song.data,
          duration: 0,
          size: song.size,
          isFavorite: false,
          playCount: 0,
        );
      }
    }).toList();
  }

  void _loadMockData() {
    // Mock songs for testing on web/desktop
    _songs = [
      Song(
        id: 1,
        title: 'Sample Song 1',
        artist: 'Artist One',
        album: 'Album One',
        path: '/mock/path/song1.mp3',
        duration: 180000, // 3 minutes
        size: 3500000,
        genre: 'Pop',
        year: 2023,
        track: 1,
        isFavorite: false,
        playCount: 5,
        dateAdded: DateTime.now().subtract(Duration(days: 30)),
      ),
      Song(
        id: 2,
        title: 'Sample Song 2',
        artist: 'Artist Two',
        album: 'Album Two',
        path: '/mock/path/song2.mp3',
        duration: 240000, // 4 minutes
        size: 4200000,
        genre: 'Rock',
        year: 2022,
        track: 1,
        isFavorite: true,
        playCount: 12,
        dateAdded: DateTime.now().subtract(Duration(days: 15)),
      ),
      Song(
        id: 3,
        title: 'Sample Song 3',
        artist: 'Artist One',
        album: 'Album One',
        path: '/mock/path/song3.mp3',
        duration: 200000, // 3:20
        size: 3800000,
        genre: 'Pop',
        year: 2023,
        track: 2,
        isFavorite: false,
        playCount: 8,
        dateAdded: DateTime.now().subtract(Duration(days: 45)),
      ),
      Song(
        id: 4,
        title: 'Sample Song 4',
        artist: 'Artist Three',
        album: 'Album Three',
        path: '/mock/path/song4.mp3',
        duration: 210000, // 3:30
        size: 4000000,
        genre: 'Jazz',
        year: 2021,
        track: 1,
        isFavorite: true,
        playCount: 3,
        dateAdded: DateTime.now().subtract(Duration(days: 60)),
      ),
      Song(
        id: 5,
        title: 'Sample Song 5',
        artist: 'Artist Two',
        album: 'Album Four',
        path: '/mock/path/song5.mp3',
        duration: 190000, // 3:10
        size: 3700000,
        genre: 'Rock',
        year: 2022,
        track: 1,
        isFavorite: false,
        playCount: 15,
        dateAdded: DateTime.now().subtract(Duration(days: 10)),
      ),
    ];
  }

  // Get songs by album
  List<Song> getSongsByAlbum(String album) {
    return _songs.where((song) => song.album == album).toList();
  }

  // Get songs by artist
  List<Song> getSongsByArtist(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  // Get favorite songs
  List<Song> getFavorites() {
    return _songs.where((song) => song.isFavorite).toList();
  }

  // Get recently added songs (last 50 songs)
  List<Song> getRecentlyAdded() {
    final recentSongs = _songs.where((song) => song.dateAdded != null).toList();
    recentSongs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    return recentSongs.take(50).toList();
  }

  // Get most played songs
  List<Song> getMostPlayed() {
    final playedSongs = _songs.where((song) => song.playCount > 0).toList();
    playedSongs.sort((a, b) => b.playCount.compareTo(a.playCount));
    return playedSongs.take(50).toList();
  }

  // Toggle favorite status
  void toggleFavorite(int songId) {
    final songIndex = _songs.indexWhere((song) => song.id == songId);
    if (songIndex != -1) {
      _songs[songIndex] = _songs[songIndex].copyWith(
        isFavorite: !_songs[songIndex].isFavorite,
      );
      notifyListeners();
    }
  }

  // Increment play count
  void incrementPlayCount(int songId) {
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
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _songs;
    final lowercaseQuery = query.toLowerCase();
    return _songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          song.artist.toLowerCase().contains(lowercaseQuery) ||
          song.album.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get song by ID
  Song? getSongById(int id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }
}
