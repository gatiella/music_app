import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../../core/services/database_service.dart';

class LocalDataSource {

  // YT Music Playlists Operations
  Future<int> insertYTMusicPlaylist(Map<String, dynamic> playlist) async {
    try {
      return await _databaseService.insertYTMusicPlaylist(playlist);
    } catch (e) {
      debugPrint('Error inserting YT Music playlist: $e');
      rethrow;
    }
  }

  Future<int> deleteYTMusicPlaylist(String playlistId) async {
    try {
      return await _databaseService.deleteYTMusicPlaylist(playlistId);
    } catch (e) {
      debugPrint('Error deleting YT Music playlist: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicPlaylists() async {
    try {
      return await _databaseService.getAllYTMusicPlaylists();
    } catch (e) {
      debugPrint('Error getting YT Music playlists: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getYTMusicPlaylistById(String playlistId) async {
    try {
      return await _databaseService.getYTMusicPlaylistById(playlistId);
    } catch (e) {
      debugPrint('Error getting YT Music playlist by ID: $e');
      rethrow;
    }
  }

  Future<int> updateYTMusicPlaylist(String playlistId, {String? name, String? coverImageUrl, String? description, List<String>? tags}) async {
    try {
      return await _databaseService.updateYTMusicPlaylist(playlistId, name: name, coverImageUrl: coverImageUrl, description: description, tags: tags);
    } catch (e) {
      debugPrint('Error updating YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> addYTMusicItemsToPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _databaseService.addYTMusicItemsToPlaylist(playlistId, videoIds);
    } catch (e) {
      debugPrint('Error batch adding items to YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> removeYTMusicItemsFromPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _databaseService.removeYTMusicItemsFromPlaylist(playlistId, videoIds);
    } catch (e) {
      debugPrint('Error batch removing items from YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> reorderYTMusicPlaylistItems(String playlistId, List<String> orderedVideoIds) async {
    try {
      await _databaseService.reorderYTMusicPlaylistItems(playlistId, orderedVideoIds);
    } catch (e) {
      debugPrint('Error reordering YT Music playlist items: $e');
      rethrow;
    }
  }

  Future<List<String>> exportYTMusicPlaylist(String playlistId) async {
    try {
      return await _databaseService.exportYTMusicPlaylist(playlistId);
    } catch (e) {
      debugPrint('Error exporting YT Music playlist: $e');
      rethrow;
    }
  }

  // YT Music Favorites Operations
  Future<int> insertYTMusicFavorite(Map<String, dynamic> favorite) async {
    try {
      return await _databaseService.insertYTMusicFavorite(favorite);
    } catch (e) {
      debugPrint('Error inserting YT Music favorite: $e');
      rethrow;
    }
  }

  Future<int> deleteYTMusicFavorite(String videoId) async {
    try {
      return await _databaseService.deleteYTMusicFavorite(videoId);
    } catch (e) {
      debugPrint('Error deleting YT Music favorite: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicFavorites() async {
    try {
      return await _databaseService.getAllYTMusicFavorites();
    } catch (e) {
      debugPrint('Error getting YT Music favorites: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getYTMusicFavoriteById(String videoId) async {
    try {
      return await _databaseService.getYTMusicFavoriteById(videoId);
    } catch (e) {
      debugPrint('Error getting YT Music favorite by ID: $e');
      rethrow;
    }
  }
  final DatabaseService _databaseService;

  LocalDataSource({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  /// Initialize the data source
  Future<void> initialize() async {
    try {
      await _databaseService.initialize();
      debugPrint('LocalDataSource initialized successfully');
    } catch (e) {
      debugPrint('Error initializing LocalDataSource: $e');
      rethrow;
    }
  }

  /// Check if data source is initialized
  bool get isInitialized => _databaseService.isInitialized;

  // SONG OPERATIONS

  /// Insert a single song
  Future<int> insertSong(Song song) async {
    try {
      return await _databaseService.insertSong(song);
    } catch (e) {
      debugPrint('Error inserting song: $e');
      rethrow;
    }
  }

  /// Insert multiple songs in batch
  Future<void> insertSongs(List<Song> songs) async {
    try {
      await _databaseService.insertSongs(songs);
      debugPrint('Inserted ${songs.length} songs');
    } catch (e) {
      debugPrint('Error inserting songs: $e');
      rethrow;
    }
  }

  /// Get all songs
  Future<List<Song>> getAllSongs() async {
    try {
      return await _databaseService.getAllSongs();
    } catch (e) {
      debugPrint('Error getting all songs: $e');
      rethrow;
    }
  }

  /// Get song by ID
  Future<Song?> getSongById(int id) async {
    try {
      return await _databaseService.getSongById(id);
    } catch (e) {
      debugPrint('Error getting song by ID $id: $e');
      return null;
    }
  }

  /// Get songs by artist
  Future<List<Song>> getSongsByArtist(String artist) async {
    try {
      return await _databaseService.getSongsByArtist(artist);
    } catch (e) {
      debugPrint('Error getting songs by artist $artist: $e');
      return [];
    }
  }

  /// Get songs by album
  Future<List<Song>> getSongsByAlbum(String album) async {
    try {
      return await _databaseService.getSongsByAlbum(album);
    } catch (e) {
      debugPrint('Error getting songs by album $album: $e');
      return [];
    }
  }

  /// Get favorite songs
  Future<List<Song>> getFavoriteSongs() async {
    try {
      return await _databaseService.getFavoriteSongs();
    } catch (e) {
      debugPrint('Error getting favorite songs: $e');
      return [];
    }
  }

  /// Get recently added songs
  Future<List<Song>> getRecentlyAddedSongs([int limit = 20]) async {
    try {
      return await _databaseService.getRecentlyAddedSongs(limit);
    } catch (e) {
      debugPrint('Error getting recently added songs: $e');
      return [];
    }
  }

  /// Get most played songs
  Future<List<Song>> getMostPlayedSongs([int limit = 20]) async {
    try {
      return await _databaseService.getMostPlayedSongs(limit);
    } catch (e) {
      debugPrint('Error getting most played songs: $e');
      return [];
    }
  }

  /// Get recently played songs
  Future<List<Song>> getRecentlyPlayedSongs([int limit = 20]) async {
    try {
      return await _databaseService.getRecentlyPlayedSongs(limit);
    } catch (e) {
      debugPrint('Error getting recently played songs: $e');
      return [];
    }
  }

  /// Search songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      return await _databaseService.searchSongs(query);
    } catch (e) {
      debugPrint('Error searching songs with query "$query": $e');
      return [];
    }
  }

  /// Update song
  Future<int> updateSong(Song song) async {
    try {
      return await _databaseService.updateSong(song);
    } catch (e) {
      debugPrint('Error updating song ${song.id}: $e');
      rethrow;
    }
  }

  /// Delete song
  Future<int> deleteSong(int id) async {
    try {
      return await _databaseService.deleteSong(id);
    } catch (e) {
      debugPrint('Error deleting song $id: $e');
      rethrow;
    }
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int songId) async {
    try {
      return await _databaseService.toggleFavorite(songId);
    } catch (e) {
      debugPrint('Error toggling favorite for song $songId: $e');
      rethrow;
    }
  }

  /// Increment play count
  Future<int> incrementPlayCount(int songId) async {
    try {
      return await _databaseService.incrementPlayCount(songId);
    } catch (e) {
      debugPrint('Error incrementing play count for song $songId: $e');
      rethrow;
    }
  }

  // PLAYLIST OPERATIONS

  /// Insert playlist
  Future<String> insertPlaylist(Playlist playlist) async {
    try {
      return await _databaseService.insertPlaylist(playlist);
    } catch (e) {
      debugPrint('Error inserting playlist ${playlist.name}: $e');
      rethrow;
    }
  }

  /// Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    try {
      return await _databaseService.getAllPlaylists();
    } catch (e) {
      debugPrint('Error getting all playlists: $e');
      return [];
    }
  }

  /// Get playlist by ID
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return await _databaseService.getPlaylistById(id);
    } catch (e) {
      debugPrint('Error getting playlist by ID $id: $e');
      return null;
    }
  }

  /// Get playlist songs
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      return await _databaseService.getPlaylistSongs(playlistId);
    } catch (e) {
      debugPrint('Error getting songs for playlist $playlistId: $e');
      return [];
    }
  }

  /// Update playlist
  Future<int> updatePlaylist(Playlist playlist) async {
    try {
      return await _databaseService.updatePlaylist(playlist);
    } catch (e) {
      debugPrint('Error updating playlist ${playlist.id}: $e');
      rethrow;
    }
  }

  /// Delete playlist
  Future<int> deletePlaylist(String id) async {
    try {
      return await _databaseService.deletePlaylist(id);
    } catch (e) {
      debugPrint('Error deleting playlist $id: $e');
      rethrow;
    }
  }

  /// Add song to playlist
  Future<int> addSongToPlaylist(String playlistId, int songId) async {
    try {
      return await _databaseService.addSongToPlaylist(playlistId, songId);
    } catch (e) {
      debugPrint('Error adding song $songId to playlist $playlistId: $e');
      rethrow;
    }
  }

  /// Remove song from playlist
  Future<int> removeSongFromPlaylist(String playlistId, int songId) async {
    try {
      return await _databaseService.removeSongFromPlaylist(playlistId, songId);
    } catch (e) {
      debugPrint('Error removing song $songId from playlist $playlistId: $e');
      rethrow;
    }
  }

  /// Reorder playlist songs
  Future<int> reorderPlaylistSongs(String playlistId, List<int> songIds) async {
    try {
      return await _databaseService.reorderPlaylistSongs(playlistId, songIds);
    } catch (e) {
      debugPrint('Error reordering songs in playlist $playlistId: $e');
      rethrow;
    }
  }

  // UTILITY OPERATIONS

  /// Get unique artists
  Future<List<String>> getUniqueArtists() async {
    try {
      return await _databaseService.getUniqueArtists();
    } catch (e) {
      debugPrint('Error getting unique artists: $e');
      return [];
    }
  }

  /// Get unique albums
  Future<List<String>> getUniqueAlbums() async {
    try {
      return await _databaseService.getUniqueAlbums();
    } catch (e) {
      debugPrint('Error getting unique albums: $e');
      return [];
    }
  }

  /// Get unique genres
  Future<List<String>> getUniqueGenres() async {
    try {
      return await _databaseService.getUniqueGenres();
    } catch (e) {
      debugPrint('Error getting unique genres: $e');
      return [];
    }
  }

  /// Get library statistics
  Future<Map<String, int>> getLibraryStats() async {
    try {
      return await _databaseService.getLibraryStats();
    } catch (e) {
      debugPrint('Error getting library stats: $e');
      return {};
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _databaseService.clearAllData();
      debugPrint('All data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }

  // TRANSACTION OPERATIONS

  /// Execute operations in a transaction
  Future<T> transaction<T>(Future<T> Function() action) async {
    try {
      return await _databaseService.transaction((txn) async {
        return await action();
      });
    } catch (e) {
      debugPrint('Error in transaction: $e');
      rethrow;
    }
  }

  /// Execute batch operations
  Future<List<Object?>> batch(void Function() operations) async {
    try {
      return await _databaseService.batch((batch) {
        operations();
      });
    } catch (e) {
      debugPrint('Error in batch operation: $e');
      rethrow;
    }
  }

  // ADVANCED QUERY OPERATIONS

  /// Get songs with filters
  Future<List<Song>> getSongsWithFilters({
    String? artist,
    String? album,
    String? genre,
    int? minDuration,
    int? maxDuration,
    bool? isFavorite,
    int? minPlayCount,
    DateTime? addedAfter,
    DateTime? addedBefore,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      // Get all songs first (in a real implementation, this would be done with SQL WHERE clauses)
      final allSongs = await getAllSongs();

      // Apply filters
      var filteredSongs = allSongs.where((song) {
        if (artist != null &&
            !song.artist.toLowerCase().contains(artist.toLowerCase())) {
          return false;
        }
        if (album != null &&
            !song.album.toLowerCase().contains(album.toLowerCase())) {
          return false;
        }
        if (genre != null &&
            (song.genre == null ||
                !song.genre!.toLowerCase().contains(genre.toLowerCase()))) {
          return false;
        }
        if (minDuration != null && song.duration < minDuration) {
          return false;
        }
        if (maxDuration != null && song.duration > maxDuration) {
          return false;
        }
        if (isFavorite != null && song.isFavorite != isFavorite) {
          return false;
        }
        if (minPlayCount != null && song.playCount < minPlayCount) {
          return false;
        }
        if (addedAfter != null &&
            (song.dateAdded == null || song.dateAdded!.isBefore(addedAfter))) {
          return false;
        }
        if (addedBefore != null &&
            (song.dateAdded == null || song.dateAdded!.isAfter(addedBefore))) {
          return false;
        }
        return true;
      }).toList();

      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, filteredSongs.length);

      if (startIndex >= filteredSongs.length) {
        return [];
      }

      return filteredSongs.sublist(startIndex, endIndex);
    } catch (e) {
      debugPrint('Error getting songs with filters: $e');
      return [];
    }
  }

  /// Get songs by multiple artists
  Future<List<Song>> getSongsByArtists(List<String> artists) async {
    try {
      if (artists.isEmpty) return [];

      final List<Song> allArtistSongs = [];
      for (final artist in artists) {
        final artistSongs = await getSongsByArtist(artist);
        allArtistSongs.addAll(artistSongs);
      }

      // Remove duplicates based on song ID
      final uniqueSongs = <int, Song>{};
      for (final song in allArtistSongs) {
        uniqueSongs[song.id] = song;
      }

      return uniqueSongs.values.toList();
    } catch (e) {
      debugPrint('Error getting songs by multiple artists: $e');
      return [];
    }
  }

  /// Get songs by multiple albums
  Future<List<Song>> getSongsByAlbums(List<String> albums) async {
    try {
      if (albums.isEmpty) return [];

      final List<Song> allAlbumSongs = [];
      for (final album in albums) {
        final albumSongs = await getSongsByAlbum(album);
        allAlbumSongs.addAll(albumSongs);
      }

      // Remove duplicates based on song ID
      final uniqueSongs = <int, Song>{};
      for (final song in allAlbumSongs) {
        uniqueSongs[song.id] = song;
      }

      return uniqueSongs.values.toList();
    } catch (e) {
      debugPrint('Error getting songs by multiple albums: $e');
      return [];
    }
  }

  /// Get random songs
  Future<List<Song>> getRandomSongs(int count) async {
    try {
      final allSongs = await getAllSongs();
      if (allSongs.length <= count) return allSongs;

      final shuffledSongs = List<Song>.from(allSongs);
      shuffledSongs.shuffle();
      return shuffledSongs.take(count).toList();
    } catch (e) {
      debugPrint('Error getting random songs: $e');
      return [];
    }
  }

  /// Update multiple songs
  Future<int> updateSongs(List<Song> songs) async {
    try {
      int updatedCount = 0;
      for (final song in songs) {
        final result = await updateSong(song);
        if (result > 0) updatedCount++;
      }
      return updatedCount;
    } catch (e) {
      debugPrint('Error updating multiple songs: $e');
      rethrow;
    }
  }

  /// Delete multiple songs
  Future<int> deleteSongs(List<int> songIds) async {
    try {
      int deletedCount = 0;
      for (final songId in songIds) {
        final result = await deleteSong(songId);
        if (result > 0) deletedCount++;
      }
      return deletedCount;
    } catch (e) {
      debugPrint('Error deleting multiple songs: $e');
      rethrow;
    }
  }

  /// Toggle favorite for multiple songs
  Future<int> toggleFavoriteMultiple(List<int> songIds, bool isFavorite) async {
    try {
      int updatedCount = 0;
      for (final songId in songIds) {
        final song = await getSongById(songId);
        if (song != null && song.isFavorite != isFavorite) {
          final result = await toggleFavorite(songId);
          if (result > 0) updatedCount++;
        }
      }
      return updatedCount;
    } catch (e) {
      debugPrint('Error toggling favorite for multiple songs: $e');
      rethrow;
    }
  }

  // BACKUP AND RESTORE OPERATIONS

  /// Export data to JSON format
  Future<Map<String, dynamic>> exportToJson() async {
    try {
      final songs = await getAllSongs();
      final playlists = await getAllPlaylists();

      return {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'songs': songs.map((song) => song.toMap()).toList(),
        'playlists': playlists.map((playlist) => playlist.toMap()).toList(),
      };
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      rethrow;
    }
  }

  /// Import data from JSON format
  Future<void> importFromJson(Map<String, dynamic> data) async {
    try {
      // Clear existing data first
      await clearAllData();

      // Import songs
      final songsData = data['songs'] as List<dynamic>? ?? [];
      final songs = songsData
          .map((songData) => Song.fromMap(songData))
          .toList();
      if (songs.isNotEmpty) {
        await insertSongs(songs);
      }

      // Import playlists
      final playlistsData = data['playlists'] as List<dynamic>? ?? [];
      for (final playlistData in playlistsData) {
        final playlist = Playlist.fromMap(playlistData);
        await insertPlaylist(playlist);
      }

      debugPrint(
        'Successfully imported ${songs.length} songs and ${playlistsData.length} playlists',
      );
    } catch (e) {
      debugPrint('Error importing from JSON: $e');
      rethrow;
    }
  }

  /// Create a backup of specific data
  Future<Map<String, dynamic>> createPartialBackup({
    bool includeSongs = true,
    bool includePlaylists = true,
    bool includeFavoritesOnly = false,
    List<String>? playlistIds,
  }) async {
    try {
      final backup = <String, dynamic>{
        'version': '1.0',
        'backupDate': DateTime.now().toIso8601String(),
        'partial': true,
      };

      if (includeSongs) {
        List<Song> songsToBackup;
        if (includeFavoritesOnly) {
          songsToBackup = await getFavoriteSongs();
        } else {
          songsToBackup = await getAllSongs();
        }
        backup['songs'] = songsToBackup.map((song) => song.toMap()).toList();
      }

      if (includePlaylists) {
        List<Playlist> playlistsToBackup;
        if (playlistIds != null && playlistIds.isNotEmpty) {
          playlistsToBackup = [];
          for (final playlistId in playlistIds) {
            final playlist = await getPlaylistById(playlistId);
            if (playlist != null) {
              playlistsToBackup.add(playlist);
            }
          }
        } else {
          playlistsToBackup = await getAllPlaylists();
        }
        backup['playlists'] = playlistsToBackup
            .map((playlist) => playlist.toMap())
            .toList();
      }

      return backup;
    } catch (e) {
      debugPrint('Error creating partial backup: $e');
      rethrow;
    }
  }

  // MAINTENANCE OPERATIONS

  /// Optimize database performance
  Future<void> optimizeDatabase() async {
    try {
      await _databaseService.vacuum();
      await _databaseService.analyze();
      debugPrint('Database optimization completed');
    } catch (e) {
      debugPrint('Error optimizing database: $e');
      rethrow;
    }
  }

  /// Check database integrity
  Future<bool> checkDatabaseIntegrity() async {
    try {
      return await _databaseService.checkIntegrity();
    } catch (e) {
      debugPrint('Error checking database integrity: $e');
      return false;
    }
  }

  /// Get database size
  Future<int> getDatabaseSize() async {
    try {
      return await _databaseService.getDatabaseSize();
    } catch (e) {
      debugPrint('Error getting database size: $e');
      return 0;
    }
  }

  /// Get data source statistics
  Future<Map<String, dynamic>> getDataSourceStats() async {
    try {
      final libraryStats = await getLibraryStats();
      final databaseSize = await getDatabaseSize();
      final allPlaylists = await getAllPlaylists();

      return {
        ...libraryStats,
        'databaseSize': databaseSize,
        'playlistCount': allPlaylists.length,
        'isInitialized': isInitialized,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting data source stats: $e');
      return {'error': e.toString(), 'isInitialized': isInitialized};
    }
  }

  /// Close data source and cleanup resources
  Future<void> close() async {
    try {
      await _databaseService.close();
      debugPrint('LocalDataSource closed successfully');
    } catch (e) {
      debugPrint('Error closing LocalDataSource: $e');
    }
  }

  // VALIDATION OPERATIONS

  /// Validate data consistency
  Future<Map<String, dynamic>> validateDataConsistency() async {
    try {
      final issues = <String>[];

      // Check for songs without valid paths
      final allSongs = await getAllSongs();
      final songsWithInvalidPaths = allSongs
          .where((song) => song.path.isEmpty)
          .length;
      if (songsWithInvalidPaths > 0) {
        issues.add('Found $songsWithInvalidPaths songs with invalid paths');
      }

      // Check for playlists with invalid song references
      final allPlaylists = await getAllPlaylists();
      final allSongIds = allSongs.map((song) => song.id.toString()).toSet();
      int invalidPlaylistReferences = 0;

      for (final playlist in allPlaylists) {
        final invalidRefs = playlist.songIds
            .where((songId) => !allSongIds.contains(songId))
            .length;
        invalidPlaylistReferences += invalidRefs;
      }

      if (invalidPlaylistReferences > 0) {
        issues.add(
          'Found $invalidPlaylistReferences invalid playlist song references',
        );
      }

      // Check for duplicate songs (same path)
      final pathCounts = <String, int>{};
      for (final song in allSongs) {
        pathCounts[song.path] = (pathCounts[song.path] ?? 0) + 1;
      }
      final duplicatePaths = pathCounts.entries
          .where((entry) => entry.value > 1)
          .length;

      if (duplicatePaths > 0) {
        issues.add('Found $duplicatePaths songs with duplicate paths');
      }

      return {
        'isValid': issues.isEmpty,
        'issues': issues,
        'totalSongs': allSongs.length,
        'totalPlaylists': allPlaylists.length,
        'validatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error validating data consistency: $e');
      return {
        'isValid': false,
        'issues': ['Validation failed: ${e.toString()}'],
        'validatedAt': DateTime.now().toIso8601String(),
      };
    }
  }
}
