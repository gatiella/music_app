import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../../data/sources/database_helper.dart';
import '../../data/models/song.dart';
import '../../data/models/playlist.dart';

class DatabaseService {

  // YT Music Playlists Operations
  Future<int> insertYTMusicPlaylist(Map<String, dynamic> playlist) async {
    try {
      return await _databaseHelper.insertYTMusicPlaylist(playlist);
    } catch (e) {
      throw DatabaseException('Failed to insert YT Music playlist: $e');
    }
  }

  Future<int> deleteYTMusicPlaylist(String playlistId) async {
    try {
      return await _databaseHelper.deleteYTMusicPlaylist(playlistId);
    } catch (e) {
      throw DatabaseException('Failed to delete YT Music playlist: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicPlaylists() async {
    try {
      return await _databaseHelper.getAllYTMusicPlaylists();
    } catch (e) {
      throw DatabaseException('Failed to get YT Music playlists: $e');
    }
  }

  Future<Map<String, dynamic>?> getYTMusicPlaylistById(String playlistId) async {
    try {
      return await _databaseHelper.getYTMusicPlaylistById(playlistId);
    } catch (e) {
      throw DatabaseException('Failed to get YT Music playlist by ID: $e');
    }
  }

  Future<int> updateYTMusicPlaylist(String playlistId, {String? name, String? coverImageUrl, String? description, List<String>? tags}) async {
    try {
      return await _databaseHelper.updateYTMusicPlaylist(playlistId, name: name, coverImageUrl: coverImageUrl, description: description, tags: tags);
    } catch (e) {
      throw DatabaseException('Failed to update YT Music playlist: $e');
    }
  }

  Future<void> addYTMusicItemsToPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _databaseHelper.addYTMusicItemsToPlaylist(playlistId, videoIds);
    } catch (e) {
      throw DatabaseException('Failed to batch add items to YT Music playlist: $e');
    }
  }

  Future<void> removeYTMusicItemsFromPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _databaseHelper.removeYTMusicItemsFromPlaylist(playlistId, videoIds);
    } catch (e) {
      throw DatabaseException('Failed to batch remove items from YT Music playlist: $e');
    }
  }

  Future<void> reorderYTMusicPlaylistItems(String playlistId, List<String> orderedVideoIds) async {
    try {
      await _databaseHelper.reorderYTMusicPlaylistItems(playlistId, orderedVideoIds);
    } catch (e) {
      throw DatabaseException('Failed to reorder YT Music playlist items: $e');
    }
  }

  Future<List<String>> exportYTMusicPlaylist(String playlistId) async {
    try {
      return await _databaseHelper.exportYTMusicPlaylist(playlistId);
    } catch (e) {
      throw DatabaseException('Failed to export YT Music playlist: $e');
    }
  }

  // YT Music Favorites Operations
  Future<int> insertYTMusicFavorite(Map<String, dynamic> favorite) async {
    try {
      return await _databaseHelper.insertYTMusicFavorite(favorite);
    } catch (e) {
      throw DatabaseException('Failed to insert YT Music favorite: $e');
    }
  }

  Future<int> deleteYTMusicFavorite(String videoId) async {
    try {
      return await _databaseHelper.deleteYTMusicFavorite(videoId);
    } catch (e) {
      throw DatabaseException('Failed to delete YT Music favorite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicFavorites() async {
    try {
      return await _databaseHelper.getAllYTMusicFavorites();
    } catch (e) {
      throw DatabaseException('Failed to get YT Music favorites: $e');
    }
  }

  Future<Map<String, dynamic>?> getYTMusicFavoriteById(String videoId) async {
    try {
      return await _databaseHelper.getYTMusicFavoriteById(videoId);
    } catch (e) {
      throw DatabaseException('Failed to get YT Music favorite by ID: $e');
    }
  }
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Database? _database;

  /// Initialize the database
  Future<void> initialize() async {
    _database = await _databaseHelper.database;
  }

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _databaseHelper.database;
    return _database!;
  }

  /// Check if database is initialized
  bool get isInitialized => _database != null;

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // SONG OPERATIONS

  /// Insert a song into the database
  Future<int> insertSong(Song song) async {
    try {
      return await _databaseHelper.insertSong(song);
    } catch (e) {
      throw DatabaseException('Failed to insert song: $e');
    }
  }

  /// Insert multiple songs in a batch
  Future<void> insertSongs(List<Song> songs) async {
    final db = await database;
    final batch = db.batch();

    try {
      for (final song in songs) {
        batch.insert(
          AppConstants.songsTable,
          song.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to insert songs: $e');
    }
  }

  /// Get all songs from the database
  Future<List<Song>> getAllSongs() async {
    try {
      return await _databaseHelper.getAllSongs();
    } catch (e) {
      throw DatabaseException('Failed to get all songs: $e');
    }
  }

  /// Get a song by ID
  Future<Song?> getSongById(int id) async {
    try {
      return await _databaseHelper.getSongById(id);
    } catch (e) {
      throw DatabaseException('Failed to get song by ID: $e');
    }
  }

  /// Get songs by artist
  Future<List<Song>> getSongsByArtist(String artist) async {
    try {
      return await _databaseHelper.getSongsByArtist(artist);
    } catch (e) {
      throw DatabaseException('Failed to get songs by artist: $e');
    }
  }

  /// Get songs by album
  Future<List<Song>> getSongsByAlbum(String album) async {
    try {
      return await _databaseHelper.getSongsByAlbum(album);
    } catch (e) {
      throw DatabaseException('Failed to get songs by album: $e');
    }
  }

  /// Get favorite songs
  Future<List<Song>> getFavoriteSongs() async {
    try {
      return await _databaseHelper.getFavoriteSongs();
    } catch (e) {
      throw DatabaseException('Failed to get favorite songs: $e');
    }
  }

  /// Get recently added songs
  Future<List<Song>> getRecentlyAddedSongs([int limit = 20]) async {
    try {
      return await _databaseHelper.getRecentlyAddedSongs(limit);
    } catch (e) {
      throw DatabaseException('Failed to get recently added songs: $e');
    }
  }

  /// Get most played songs
  Future<List<Song>> getMostPlayedSongs([int limit = 20]) async {
    try {
      return await _databaseHelper.getMostPlayedSongs(limit);
    } catch (e) {
      throw DatabaseException('Failed to get most played songs: $e');
    }
  }

  /// Get recently played songs
  Future<List<Song>> getRecentlyPlayedSongs([int limit = 20]) async {
    try {
      return await _databaseHelper.getRecentlyPlayedSongs(limit);
    } catch (e) {
      throw DatabaseException('Failed to get recently played songs: $e');
    }
  }

  /// Search songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      return await _databaseHelper.searchSongs(query);
    } catch (e) {
      throw DatabaseException('Failed to search songs: $e');
    }
  }

  /// Update a song
  Future<int> updateSong(Song song) async {
    try {
      return await _databaseHelper.updateSong(song);
    } catch (e) {
      throw DatabaseException('Failed to update song: $e');
    }
  }

  /// Delete a song
  Future<int> deleteSong(int id) async {
    try {
      return await _databaseHelper.deleteSong(id);
    } catch (e) {
      throw DatabaseException('Failed to delete song: $e');
    }
  }

  /// Toggle favorite status of a song
  Future<int> toggleFavorite(int songId) async {
    try {
      return await _databaseHelper.toggleFavorite(songId);
    } catch (e) {
      throw DatabaseException('Failed to toggle favorite: $e');
    }
  }

  /// Increment play count of a song
  Future<int> incrementPlayCount(int songId) async {
    try {
      return await _databaseHelper.incrementPlayCount(songId);
    } catch (e) {
      throw DatabaseException('Failed to increment play count: $e');
    }
  }

  // PLAYLIST OPERATIONS

  /// Insert a playlist
  Future<String> insertPlaylist(Playlist playlist) async {
    try {
      return await _databaseHelper.insertPlaylist(playlist);
    } catch (e) {
      throw DatabaseException('Failed to insert playlist: $e');
    }
  }

  /// Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    try {
      return await _databaseHelper.getAllPlaylists();
    } catch (e) {
      throw DatabaseException('Failed to get all playlists: $e');
    }
  }

  /// Get a playlist by ID
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return await _databaseHelper.getPlaylistById(id);
    } catch (e) {
      throw DatabaseException('Failed to get playlist by ID: $e');
    }
  }

  /// Get songs in a playlist
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      return await _databaseHelper.getPlaylistSongs(playlistId);
    } catch (e) {
      throw DatabaseException('Failed to get playlist songs: $e');
    }
  }

  /// Update a playlist
  Future<int> updatePlaylist(Playlist playlist) async {
    try {
      return await _databaseHelper.updatePlaylist(playlist);
    } catch (e) {
      throw DatabaseException('Failed to update playlist: $e');
    }
  }

  /// Delete a playlist
  Future<int> deletePlaylist(String id) async {
    try {
      return await _databaseHelper.deletePlaylist(id);
    } catch (e) {
      throw DatabaseException('Failed to delete playlist: $e');
    }
  }

  /// Add a song to a playlist
  Future<int> addSongToPlaylist(String playlistId, int songId) async {
    try {
      return await _databaseHelper.addSongToPlaylist(playlistId, songId);
    } catch (e) {
      throw DatabaseException('Failed to add song to playlist: $e');
    }
  }

  /// Remove a song from a playlist
  Future<int> removeSongFromPlaylist(String playlistId, int songId) async {
    try {
      return await _databaseHelper.removeSongFromPlaylist(playlistId, songId);
    } catch (e) {
      throw DatabaseException('Failed to remove song from playlist: $e');
    }
  }

  /// Reorder songs in a playlist
  Future<int> reorderPlaylistSongs(String playlistId, List<int> songIds) async {
    try {
      return await _databaseHelper.reorderPlaylistSongs(playlistId, songIds);
    } catch (e) {
      throw DatabaseException('Failed to reorder playlist songs: $e');
    }
  }

  // UTILITY OPERATIONS

  /// Get unique artists
  Future<List<String>> getUniqueArtists() async {
    try {
      return await _databaseHelper.getUniqueArtists();
    } catch (e) {
      throw DatabaseException('Failed to get unique artists: $e');
    }
  }

  /// Get unique albums
  Future<List<String>> getUniqueAlbums() async {
    try {
      return await _databaseHelper.getUniqueAlbums();
    } catch (e) {
      throw DatabaseException('Failed to get unique albums: $e');
    }
  }

  /// Get unique genres
  Future<List<String>> getUniqueGenres() async {
    try {
      return await _databaseHelper.getUniqueGenres();
    } catch (e) {
      throw DatabaseException('Failed to get unique genres: $e');
    }
  }

  /// Get library statistics
  Future<Map<String, int>> getLibraryStats() async {
    try {
      return await _databaseHelper.getLibraryStats();
    } catch (e) {
      throw DatabaseException('Failed to get library stats: $e');
    }
  }

  /// Clear all data from the database
  Future<void> clearAllData() async {
    try {
      await _databaseHelper.clearAllData();
    } catch (e) {
      throw DatabaseException('Failed to clear all data: $e');
    }
  }

  // TRANSACTION OPERATIONS

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    try {
      return await db.transaction(action);
    } catch (e) {
      throw DatabaseException('Transaction failed: $e');
    }
  }

  /// Execute a batch operation
  Future<List<Object?>> batch(void Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();

    try {
      operations(batch);
      return await batch.commit();
    } catch (e) {
      throw DatabaseException('Batch operation failed: $e');
    }
  }

  // BACKUP & RESTORE

  /// Export database to JSON
  Future<Map<String, dynamic>> exportToJson() async {
    try {
      final songs = await getAllSongs();
      final playlists = await getAllPlaylists();

      return {
        'version': AppConstants.databaseVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'songs': songs.map((song) => song.toMap()).toList(),
        'playlists': playlists.map((playlist) => playlist.toMap()).toList(),
      };
    } catch (e) {
      throw DatabaseException('Failed to export database: $e');
    }
  }

  /// Import database from JSON
  Future<void> importFromJson(Map<String, dynamic> data) async {
    try {
      final songs =
          (data['songs'] as List<dynamic>?)
              ?.map((songData) => Song.fromMap(songData))
              .toList() ??
          [];

      final playlists =
          (data['playlists'] as List<dynamic>?)
              ?.map((playlistData) => Playlist.fromMap(playlistData))
              .toList() ??
          [];

      // Clear existing data
      await clearAllData();

      // Import songs
      if (songs.isNotEmpty) {
        await insertSongs(songs);
      }

      // Import playlists
      for (final playlist in playlists) {
        await insertPlaylist(playlist);
      }
    } catch (e) {
      throw DatabaseException('Failed to import database: $e');
    }
  }

  // MAINTENANCE OPERATIONS

  /// Vacuum the database to reclaim space
  Future<void> vacuum() async {
    final db = await database;
    try {
      await db.execute('VACUUM');
    } catch (e) {
      throw DatabaseException('Failed to vacuum database: $e');
    }
  }

  /// Analyze the database for query optimization
  Future<void> analyze() async {
    final db = await database;
    try {
      await db.execute('ANALYZE');
    } catch (e) {
      throw DatabaseException('Failed to analyze database: $e');
    }
  }

  /// Get database file size
  Future<int> getDatabaseSize() async {
    final db = await database;
    try {
      final result = await db.rawQuery('PRAGMA page_count');
      final pageCount = result.first['page_count'] as int;

      final pageSizeResult = await db.rawQuery('PRAGMA page_size');
      final pageSize = pageSizeResult.first['page_size'] as int;

      return pageCount * pageSize;
    } catch (e) {
      throw DatabaseException('Failed to get database size: $e');
    }
  }

  /// Check database integrity
  Future<bool> checkIntegrity() async {
    final db = await database;
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.first['integrity_check'] == 'ok';
    } catch (e) {
      throw DatabaseException('Failed to check database integrity: $e');
    }
  }
}

/// Custom exception for database operations
class DatabaseException implements Exception {
  final String message;

  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
