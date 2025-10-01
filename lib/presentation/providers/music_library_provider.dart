import 'package:flutter/foundation.dart';
import 'package:music_app/data/models/song.dart';
import 'package:music_app/data/repositories/music_repository.dart';
import 'package:music_app/core/services/download_service.dart';
import 'package:music_app/data/models/downloaded_song.dart';

class MusicLibraryProvider extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  final List<DownloadedSong> _downloadedSongs = [];
  List<DownloadedSong> get downloadedSongs => _downloadedSongs;

  /// Download a song from YouTube and add to offline library
  Future<DownloadedSong?> downloadSongFromYouTube({
    required String videoId,
    required String title,
    required String author,
    required String thumbnailUrl,
  }) async {
    final downloadedSong = await _downloadService.downloadSong(
      videoId: videoId,
      title: title,
      author: author,
      thumbnailUrl: thumbnailUrl,
    );
    if (downloadedSong != null) {
      _downloadedSongs.add(downloadedSong);
      notifyListeners();
    }
    return downloadedSong;
  }

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

  /// Load music - now properly scans device and refreshes library
  Future<void> loadMusic() async {
    debugPrint('🎵 MusicLibraryProvider: Starting to load music...');
    _isLoading = true;
    notifyListeners();
    
    try {
      // First, try to get songs from database
      debugPrint('🎵 MusicLibraryProvider: Checking database...');
      _songs = await _musicRepository.getAllSongs();
      debugPrint('✅ Database has ${_songs.length} songs');
      
      // If database is empty, scan device for music files
      if (_songs.isEmpty) {
        debugPrint('📱 Database is empty, scanning device for music...');
        final scanSuccess = await _musicRepository.refreshLibrary();
        
        if (scanSuccess) {
          debugPrint('✅ Device scan successful, loading songs from database...');
          _songs = await _musicRepository.getAllSongs();
          debugPrint('✅ Loaded ${_songs.length} songs after scan');
        } else {
          debugPrint('⚠️ Device scan found no music files');
        }
      }
      
      // Log sample songs for debugging
      if (_songs.isNotEmpty) {
        debugPrint('📀 Sample songs from library:');
        for (var song in _songs.take(5)) {
          debugPrint('   - "${song.title}" by ${song.artist}');
          debugPrint('     Path: ${song.path}');
        }
      } else {
        debugPrint('⚠️ MusicLibraryProvider: No songs found after all attempts');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ MusicLibraryProvider: Error loading music: $e');
      debugPrint('Stack trace: $stackTrace');
      _songs = [];
    }
    
    _isLoading = false;
    notifyListeners();
    debugPrint('🎵 MusicLibraryProvider: Load music completed. Total songs: ${_songs.length}');
  }

  /// Force refresh - scans device even if database has songs
  Future<void> forceRefresh() async {
    debugPrint('🔄 MusicLibraryProvider: Force refreshing library...');
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('📱 Scanning device for music files...');
      final scanSuccess = await _musicRepository.refreshLibrary();
      
      if (scanSuccess) {
        debugPrint('✅ Device scan successful, reloading songs...');
        _songs = await _musicRepository.getAllSongs();
        debugPrint('✅ Loaded ${_songs.length} songs after refresh');
        
        if (_songs.isNotEmpty) {
          debugPrint('📀 Sample songs:');
          for (var song in _songs.take(3)) {
            debugPrint('   - "${song.title}" by ${song.artist}');
          }
        }
      } else {
        debugPrint('⚠️ Device scan found no music files');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error during force refresh: $e');
      debugPrint('Stack trace: $stackTrace');
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