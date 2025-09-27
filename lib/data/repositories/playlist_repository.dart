import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../sources/local_data_source.dart';
import '../../core/services/database_service.dart';
import '../../core/services/file_service.dart';

class PlaylistRepository {
  final LocalDataSource _localDataSource;

  PlaylistRepository({
    LocalDataSource? localDataSource,
    DatabaseService? databaseService,
    FileService? fileService,
  }) : _localDataSource = localDataSource ?? LocalDataSource();

  // PLAYLIST CRUD OPERATIONS

  /// Create a new playlist
  Future<String?> createPlaylist(String name, {String? description}) async {
    try {
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: description?.trim(),
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final playlistId = await _localDataSource.insertPlaylist(playlist);
      debugPrint('Created playlist: $name with ID: $playlistId');
      return playlistId;
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      return null;
    }
  }

  /// Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    try {
      return await _localDataSource.getAllPlaylists();
    } catch (e) {
      debugPrint('Error getting all playlists: $e');
      return [];
    }
  }

  /// Get playlist by ID
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return await _localDataSource.getPlaylistById(id);
    } catch (e) {
      debugPrint('Error getting playlist by ID: $e');
      return null;
    }
  }

  /// Update playlist
  Future<bool> updatePlaylist(
    String playlistId,
    String name, {
    String? description,
  }) async {
    try {
      final existingPlaylist = await getPlaylistById(playlistId);
      if (existingPlaylist == null) {
        debugPrint('Playlist not found: $playlistId');
        return false;
      }

      final updatedPlaylist = existingPlaylist.copyWith(
        name: name.trim(),
        description: description?.trim(),
        updatedAt: DateTime.now(),
      );

      final result = await _localDataSource.updatePlaylist(updatedPlaylist);
      debugPrint('Updated playlist: $name');
      return result > 0;
    } catch (e) {
      debugPrint('Error updating playlist: $e');
      return false;
    }
  }

  /// Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final result = await _localDataSource.deletePlaylist(playlistId);
      debugPrint('Deleted playlist: $playlistId');
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      return false;
    }
  }

  /// Duplicate playlist
  Future<String?> duplicatePlaylist(String playlistId, String newName) async {
    try {
      final originalPlaylist = await getPlaylistById(playlistId);
      if (originalPlaylist == null) {
        debugPrint('Original playlist not found: $playlistId');
        return null;
      }

      final duplicatedPlaylist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName.trim(),
        description: originalPlaylist.description,
        songIds: List<String>.from(originalPlaylist.songIds),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coverArt: originalPlaylist.coverArt,
      );

      final newPlaylistId = await _localDataSource.insertPlaylist(
        duplicatedPlaylist,
      );
      debugPrint('Duplicated playlist: $newName with ID: $newPlaylistId');
      return newPlaylistId;
    } catch (e) {
      debugPrint('Error duplicating playlist: $e');
      return null;
    }
  }

  // PLAYLIST SONG OPERATIONS

  /// Get songs in a playlist
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      return await _localDataSource.getPlaylistSongs(playlistId);
    } catch (e) {
      debugPrint('Error getting playlist songs: $e');
      return [];
    }
  }

  /// Add song to playlist
  Future<bool> addSongToPlaylist(String playlistId, int songId) async {
    try {
      // Check if song already exists in playlist
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) {
        debugPrint('Playlist not found: $playlistId');
        return false;
      }

      if (playlist.songIds.contains(songId.toString())) {
        debugPrint('Song already exists in playlist');
        return false;
      }

      final result = await _localDataSource.addSongToPlaylist(
        playlistId,
        songId,
      );
      debugPrint('Added song $songId to playlist $playlistId');
      return result > 0;
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
      return false;
    }
  }

  /// Add multiple songs to playlist
  Future<int> addSongsToPlaylist(String playlistId, List<int> songIds) async {
    try {
      int addedCount = 0;

      for (final songId in songIds) {
        final success = await addSongToPlaylist(playlistId, songId);
        if (success) addedCount++;
      }

      debugPrint('Added $addedCount songs to playlist $playlistId');
      return addedCount;
    } catch (e) {
      debugPrint('Error adding songs to playlist: $e');
      return 0;
    }
  }

  /// Remove song from playlist
  Future<bool> removeSongFromPlaylist(String playlistId, int songId) async {
    try {
      final result = await _localDataSource.removeSongFromPlaylist(
        playlistId,
        songId,
      );
      debugPrint('Removed song $songId from playlist $playlistId');
      return result > 0;
    } catch (e) {
      debugPrint('Error removing song from playlist: $e');
      return false;
    }
  }

  /// Remove multiple songs from playlist
  Future<int> removeSongsFromPlaylist(
    String playlistId,
    List<int> songIds,
  ) async {
    try {
      int removedCount = 0;

      for (final songId in songIds) {
        final success = await removeSongFromPlaylist(playlistId, songId);
        if (success) removedCount++;
      }

      debugPrint('Removed $removedCount songs from playlist $playlistId');
      return removedCount;
    } catch (e) {
      debugPrint('Error removing songs from playlist: $e');
      return 0;
    }
  }

  /// Reorder songs in playlist
  Future<bool> reorderPlaylistSongs(
    String playlistId,
    List<int> songIds,
  ) async {
    try {
      final result = await _localDataSource.reorderPlaylistSongs(
        playlistId,
        songIds,
      );
      debugPrint('Reordered songs in playlist $playlistId');
      return result > 0;
    } catch (e) {
      debugPrint('Error reordering playlist songs: $e');
      return false;
    }
  }

  /// Move song within playlist
  Future<bool> moveSongInPlaylist(
    String playlistId,
    int fromIndex,
    int toIndex,
  ) async {
    try {
      final songs = await getPlaylistSongs(playlistId);
      if (fromIndex < 0 ||
          fromIndex >= songs.length ||
          toIndex < 0 ||
          toIndex >= songs.length) {
        return false;
      }

      final songIds = songs.map((song) => song.id).toList();
      final songId = songIds.removeAt(fromIndex);
      songIds.insert(toIndex, songId);

      return await reorderPlaylistSongs(playlistId, songIds);
    } catch (e) {
      debugPrint('Error moving song in playlist: $e');
      return false;
    }
  }

  /// Clear all songs from playlist
  Future<bool> clearPlaylist(String playlistId) async {
    try {
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) return false;

      final result = await reorderPlaylistSongs(playlistId, []);
      debugPrint('Cleared playlist $playlistId');
      return result; // Fixed: removed the invalid >= 0 comparison on boolean
    } catch (e) {
      debugPrint('Error clearing playlist: $e');
      return false;
    }
  }

  // PLAYLIST SEARCH AND FILTERING

  /// Search playlists by name
  Future<List<Playlist>> searchPlaylists(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllPlaylists();
      }

      final allPlaylists = await getAllPlaylists();
      final searchQuery = query.toLowerCase().trim();

      return allPlaylists.where((playlist) {
        return playlist.name.toLowerCase().contains(searchQuery) ||
            (playlist.description?.toLowerCase().contains(searchQuery) ??
                false);
      }).toList();
    } catch (e) {
      debugPrint('Error searching playlists: $e');
      return [];
    }
  }

  /// Get playlists containing a specific song
  Future<List<Playlist>> getPlaylistsContainingSong(int songId) async {
    try {
      final allPlaylists = await getAllPlaylists();
      return allPlaylists
          .where((playlist) => playlist.songIds.contains(songId.toString()))
          .toList();
    } catch (e) {
      debugPrint('Error getting playlists containing song: $e');
      return [];
    }
  }

  /// Get empty playlists
  Future<List<Playlist>> getEmptyPlaylists() async {
    try {
      final allPlaylists = await getAllPlaylists();
      return allPlaylists.where((playlist) => playlist.isEmpty).toList();
    } catch (e) {
      debugPrint('Error getting empty playlists: $e');
      return [];
    }
  }

  /// Get playlists by creation date range
  Future<List<Playlist>> getPlaylistsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allPlaylists = await getAllPlaylists();
      return allPlaylists
          .where(
            (playlist) =>
                playlist.createdAt.isAfter(startDate) &&
                playlist.createdAt.isBefore(endDate),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting playlists by date range: $e');
      return [];
    }
  }

  // PLAYLIST STATISTICS

  /// Get playlist statistics
  Future<Map<String, dynamic>> getPlaylistStats(String playlistId) async {
    try {
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) return {};

      final songs = await getPlaylistSongs(playlistId);
      if (songs.isEmpty) {
        return {
          'songCount': 0,
          'totalDuration': 0,
          'averageDuration': 0,
          'artists': [],
          'albums': [],
          'genres': [],
        };
      }

      final totalDuration = songs.fold<int>(
        0,
        (sum, song) => sum + song.duration,
      );
      final averageDuration = totalDuration ~/ songs.length;

      final artists = songs.map((song) => song.artist).toSet().toList();
      final albums = songs.map((song) => song.album).toSet().toList();
      final genres = songs
          .map((song) => song.genre)
          .where((genre) => genre != null)
          .toSet()
          .toList();

      return {
        'songCount': songs.length,
        'totalDuration': totalDuration,
        'averageDuration': averageDuration,
        'artists': artists,
        'albums': albums,
        'genres': genres,
        'createdAt': playlist.createdAt,
        'updatedAt': playlist.updatedAt,
      };
    } catch (e) {
      debugPrint('Error getting playlist stats: $e');
      return {}; // Fixed: Added proper return statement and closed the method
    }
  }
}
