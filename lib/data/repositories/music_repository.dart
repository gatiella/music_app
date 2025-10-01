import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../sources/local_data_source.dart';
import '../../core/services/database_service.dart';
import '../../core/services/file_service.dart';

class MusicRepository {

  // YT Music Playlists Operations
  Future<int> insertYTMusicPlaylist(Map<String, dynamic> playlist) async {
    try {
      return await _localDataSource.insertYTMusicPlaylist(playlist);
    } catch (e) {
      debugPrint('Error inserting YT Music playlist: $e');
      rethrow;
    }
  }

  Future<int> deleteYTMusicPlaylist(String playlistId) async {
    try {
      return await _localDataSource.deleteYTMusicPlaylist(playlistId);
    } catch (e) {
      debugPrint('Error deleting YT Music playlist: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicPlaylists() async {
    try {
      return await _localDataSource.getAllYTMusicPlaylists();
    } catch (e) {
      debugPrint('Error getting YT Music playlists: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getYTMusicPlaylistById(String playlistId) async {
    try {
      return await _localDataSource.getYTMusicPlaylistById(playlistId);
    } catch (e) {
      debugPrint('Error getting YT Music playlist by ID: $e');
      rethrow;
    }
  }

  Future<int> updateYTMusicPlaylist(String playlistId, {String? name, String? coverImageUrl, String? description, List<String>? tags}) async {
    try {
      return await _localDataSource.updateYTMusicPlaylist(playlistId, name: name, coverImageUrl: coverImageUrl, description: description, tags: tags);
    } catch (e) {
      debugPrint('Error updating YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> addYTMusicItemsToPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _localDataSource.addYTMusicItemsToPlaylist(playlistId, videoIds);
    } catch (e) {
      debugPrint('Error batch adding items to YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> removeYTMusicItemsFromPlaylist(String playlistId, List<String> videoIds) async {
    try {
      await _localDataSource.removeYTMusicItemsFromPlaylist(playlistId, videoIds);
    } catch (e) {
      debugPrint('Error batch removing items from YT Music playlist: $e');
      rethrow;
    }
  }

  Future<void> reorderYTMusicPlaylistItems(String playlistId, List<String> orderedVideoIds) async {
    try {
      await _localDataSource.reorderYTMusicPlaylistItems(playlistId, orderedVideoIds);
    } catch (e) {
      debugPrint('Error reordering YT Music playlist items: $e');
      rethrow;
    }
  }

  Future<List<String>> exportYTMusicPlaylist(String playlistId) async {
    try {
      return await _localDataSource.exportYTMusicPlaylist(playlistId);
    } catch (e) {
      debugPrint('Error exporting YT Music playlist: $e');
      rethrow;
    }
  }

  // YT Music Favorites Operations
  Future<int> insertYTMusicFavorite(Map<String, dynamic> favorite) async {
    try {
      return await _localDataSource.insertYTMusicFavorite(favorite);
    } catch (e) {
      debugPrint('Error inserting YT Music favorite: $e');
      rethrow;
    }
  }

  Future<int> deleteYTMusicFavorite(String videoId) async {
    try {
      return await _localDataSource.deleteYTMusicFavorite(videoId);
    } catch (e) {
      debugPrint('Error deleting YT Music favorite: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllYTMusicFavorites() async {
    try {
      return await _localDataSource.getAllYTMusicFavorites();
    } catch (e) {
      debugPrint('Error getting YT Music favorites: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getYTMusicFavoriteById(String videoId) async {
    try {
      return await _localDataSource.getYTMusicFavoriteById(videoId);
    } catch (e) {
      debugPrint('Error getting YT Music favorite by ID: $e');
      rethrow;
    }
  }
  final LocalDataSource _localDataSource;
  final FileService _fileService;

  MusicRepository({
    LocalDataSource? localDataSource,
    DatabaseService? databaseService,
    FileService? fileService,
  }) : _localDataSource = localDataSource ?? LocalDataSource(),
       _fileService = fileService ?? FileService();

  // SONG OPERATIONS

  /// Get all songs from local storage
  Future<List<Song>> getAllSongs() async {
    try {
      return await _localDataSource.getAllSongs();
    } catch (e) {
      debugPrint('Error getting all songs: $e');
      rethrow;
    }
  }

  /// Get song by ID
  Future<Song?> getSongById(int id) async {
    try {
      return await _localDataSource.getSongById(id);
    } catch (e) {
      debugPrint('Error getting song by ID: $e');
      return null;
    }
  }

  /// Search songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await _localDataSource.searchSongs(query);
    } catch (e) {
      debugPrint('Error searching songs: $e');
      return [];
    }
  }

  /// Get songs by artist
  Future<List<Song>> getSongsByArtist(String artist) async {
    try {
      return await _localDataSource.getSongsByArtist(artist);
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Get songs by album
  Future<List<Song>> getSongsByAlbum(String album) async {
    try {
      return await _localDataSource.getSongsByAlbum(album);
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }

  /// Get songs by genre
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final allSongs = await getAllSongs();
      return allSongs.where((song) => song.genre == genre).toList();
    } catch (e) {
      debugPrint('Error getting songs by genre: $e');
      return [];
    }
  }

  /// Get favorite songs
  Future<List<Song>> getFavoriteSongs() async {
    try {
      return await _localDataSource.getFavoriteSongs();
    } catch (e) {
      debugPrint('Error getting favorite songs: $e');
      return [];
    }
  }

  /// Get recently added songs
  Future<List<Song>> getRecentlyAddedSongs([int limit = 20]) async {
    try {
      return await _localDataSource.getRecentlyAddedSongs(limit);
    } catch (e) {
      debugPrint('Error getting recently added songs: $e');
      return [];
    }
  }

  /// Get most played songs
  Future<List<Song>> getMostPlayedSongs([int limit = 20]) async {
    try {
      return await _localDataSource.getMostPlayedSongs(limit);
    } catch (e) {
      debugPrint('Error getting most played songs: $e');
      return [];
    }
  }

  /// Get recently played songs
  Future<List<Song>> getRecentlyPlayedSongs([int limit = 20]) async {
    try {
      return await _localDataSource.getRecentlyPlayedSongs(limit);
    } catch (e) {
      debugPrint('Error getting recently played songs: $e');
      return [];
    }
  }

  /// Update song
  Future<bool> updateSong(Song song) async {
    try {
      final result = await _localDataSource.updateSong(song);
      return result > 0;
    } catch (e) {
      debugPrint('Error updating song: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(int songId) async {
    try {
      final result = await _localDataSource.toggleFavorite(songId);
      return result > 0;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Increment play count
  Future<bool> incrementPlayCount(int songId) async {
    try {
      final result = await _localDataSource.incrementPlayCount(songId);
      return result > 0;
    } catch (e) {
      debugPrint('Error incrementing play count: $e');
      return false;
    }
  }

  /// Delete song
  Future<bool> deleteSong(int id) async {
    try {
      final result = await _localDataSource.deleteSong(id);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting song: $e');
      return false;
    }
  }

  // ARTIST OPERATIONS

  /// Get all artists
  Future<List<Artist>> getAllArtists() async {
    try {
      final uniqueArtists = await _localDataSource.getUniqueArtists();
      final List<Artist> artists = [];

      for (final artistName in uniqueArtists) {
        final artistSongs = await getSongsByArtist(artistName);
        final albums = artistSongs.map((song) => song.album).toSet().toList();
        final genres = artistSongs
            .map((song) => song.genre)
            .where((genre) => genre != null)
            .cast<String>()
            .toSet()
            .toList();

        final artist = Artist(
          name: artistName,
          songIds: artistSongs.map((song) => song.id).toList(),
          albums: albums,
          songCount: artistSongs.length,
          albumCount: albums.length,
          genres: genres,
        );

        artists.add(artist);
      }

      return artists;
    } catch (e) {
      debugPrint('Error getting all artists: $e');
      return [];
    }
  }

  /// Get artist by name
  Future<Artist?> getArtistByName(String name) async {
    try {
      final artistSongs = await getSongsByArtist(name);
      if (artistSongs.isEmpty) return null;

      final albums = artistSongs.map((song) => song.album).toSet().toList();
      final genres = artistSongs
          .map((song) => song.genre)
          .where((genre) => genre != null)
          .cast<String>()
          .toSet()
          .toList();

      return Artist(
        name: name,
        songIds: artistSongs.map((song) => song.id).toList(),
        albums: albums,
        songCount: artistSongs.length,
        albumCount: albums.length,
        genres: genres,
      );
    } catch (e) {
      debugPrint('Error getting artist by name: $e');
      return null;
    }
  }

  // ALBUM OPERATIONS

  /// Get all albums
  Future<List<Album>> getAllAlbums() async {
    try {
      final uniqueAlbums = await _localDataSource.getUniqueAlbums();
      final List<Album> albums = [];

      for (final albumName in uniqueAlbums) {
        final albumSongs = await getSongsByAlbum(albumName);
        if (albumSongs.isNotEmpty) {
          final firstSong = albumSongs.first;
          final totalDuration = albumSongs.fold<int>(
            0,
            (sum, song) => sum + song.duration,
          );

          final album = Album(
            name: albumName,
            artist: firstSong.artist,
            albumArt: firstSong.albumArt,
            year: firstSong.year,
            songIds: albumSongs.map((song) => song.id).toList(),
            trackCount: albumSongs.length,
            totalDuration: totalDuration,
            genre: firstSong.genre,
          );

          albums.add(album);
        }
      }

      return albums;
    } catch (e) {
      debugPrint('Error getting all albums: $e');
      return [];
    }
  }

  /// Get album by name and artist
  Future<Album?> getAlbumByNameAndArtist(String name, String artist) async {
    try {
      final albumSongs = await getSongsByAlbum(name);
      final artistAlbumSongs = albumSongs
          .where((song) => song.artist == artist)
          .toList();

      if (artistAlbumSongs.isEmpty) return null;

      final firstSong = artistAlbumSongs.first;
      final totalDuration = artistAlbumSongs.fold<int>(
        0,
        (sum, song) => sum + song.duration,
      );

      return Album(
        name: name,
        artist: artist,
        albumArt: firstSong.albumArt,
        year: firstSong.year,
        songIds: artistAlbumSongs.map((song) => song.id).toList(),
        trackCount: artistAlbumSongs.length,
        totalDuration: totalDuration,
        genre: firstSong.genre,
      );
    } catch (e) {
      debugPrint('Error getting album by name and artist: $e');
      return null;
    }
  }

  // LIBRARY OPERATIONS

  /// Scan and refresh music library
  Future<bool> refreshLibrary() async {
    try {
      debugPrint('Starting library refresh...');

      // Scan for audio files using FileService
      final scannedSongs = await _fileService.scanAudioFiles();
      debugPrint('Scanned ${scannedSongs.length} songs');

      if (scannedSongs.isNotEmpty) {
        // Process album artwork for each song
        final List<Song> songsWithArtwork = [];
        for (final song in scannedSongs) {
          try {
            final artworkPath = await _fileService.getOrCreateAlbumArtwork(
              song.id,
            );
            final updatedSong = song.copyWith(albumArt: artworkPath);
            songsWithArtwork.add(updatedSong);
          } catch (e) {
            debugPrint('Error processing artwork for song ${song.title}: $e');
            songsWithArtwork.add(song);
          }
        }

        // Save to local database
        await _localDataSource.insertSongs(songsWithArtwork);
        debugPrint('Library refresh completed successfully');
        return true;
      }

      debugPrint('No songs found during scan');
      return false;
    } catch (e) {
      debugPrint('Error refreshing library: $e');
      return false;
    }
  }

  /// Get library statistics
  Future<Map<String, dynamic>> getLibraryStats() async {
    try {
      final stats = await _localDataSource.getLibraryStats();
      final artists = await _localDataSource.getUniqueArtists();
      final albums = await _localDataSource.getUniqueAlbums();
      final genres = await _localDataSource.getUniqueGenres();

      return {
        ...stats,
        'uniqueArtists': artists.length,
        'uniqueAlbums': albums.length,
        'uniqueGenres': genres.length,
      };
    } catch (e) {
      debugPrint('Error getting library stats: $e');
      return {};
    }
  }

  /// Get unique values for filtering
  Future<Map<String, List<String>>> getUniqueValues() async {
    try {
      final artists = await _localDataSource.getUniqueArtists();
      final albums = await _localDataSource.getUniqueAlbums();
      final genres = await _localDataSource.getUniqueGenres();

      return {'artists': artists, 'albums': albums, 'genres': genres};
    } catch (e) {
      debugPrint('Error getting unique values: $e');
      return {'artists': [], 'albums': [], 'genres': []};
    }
  }

  /// Sort songs by different criteria
  List<Song> sortSongs(
    List<Song> songs,
    SortType sortType, {
    bool ascending = true,
  }) {
    final sortedSongs = List<Song>.from(songs);

    switch (sortType) {
      case SortType.title:
        sortedSongs.sort(
          (a, b) => ascending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
        );
        break;
      case SortType.artist:
        sortedSongs.sort(
          (a, b) => ascending
              ? a.artist.compareTo(b.artist)
              : b.artist.compareTo(a.artist),
        );
        break;
      case SortType.album:
        sortedSongs.sort(
          (a, b) => ascending
              ? a.album.compareTo(b.album)
              : b.album.compareTo(a.album),
        );
        break;
      case SortType.duration:
        sortedSongs.sort(
          (a, b) => ascending
              ? a.duration.compareTo(b.duration)
              : b.duration.compareTo(a.duration),
        );
        break;
      case SortType.dateAdded:
        sortedSongs.sort((a, b) {
          if (a.dateAdded == null && b.dateAdded == null) return 0;
          if (a.dateAdded == null) return ascending ? -1 : 1;
          if (b.dateAdded == null) return ascending ? 1 : -1;
          return ascending
              ? a.dateAdded!.compareTo(b.dateAdded!)
              : b.dateAdded!.compareTo(a.dateAdded!);
        });
        break;
      case SortType.playCount:
        sortedSongs.sort(
          (a, b) => ascending
              ? a.playCount.compareTo(b.playCount)
              : b.playCount.compareTo(a.playCount),
        );
        break;
    }

    return sortedSongs;
  }

  /// Filter songs by criteria
  List<Song> filterSongs(
    List<Song> songs, {
    String? artist,
    String? album,
    String? genre,
    int? minDuration,
    int? maxDuration,
    bool? isFavorite,
  }) {
    return songs.where((song) {
      if (artist != null && song.artist != artist) return false;
      if (album != null && song.album != album) return false;
      if (genre != null && song.genre != genre) return false;
      if (minDuration != null && song.duration < minDuration) return false;
      if (maxDuration != null && song.duration > maxDuration) return false;
      if (isFavorite != null && song.isFavorite != isFavorite) return false;
      return true;
    }).toList();
  }

  /// Get random songs
  Future<List<Song>> getRandomSongs([int count = 20]) async {
    try {
      final allSongs = await getAllSongs();
      if (allSongs.length <= count) return allSongs;

      final shuffled = List<Song>.from(allSongs);
      shuffled.shuffle();
      return shuffled.take(count).toList();
    } catch (e) {
      debugPrint('Error getting random songs: $e');
      return [];
    }
  }

  /// Check if song exists in library
  Future<bool> songExists(int songId) async {
    try {
      final song = await getSongById(songId);
      return song != null;
    } catch (e) {
      debugPrint('Error checking if song exists: $e');
      return false;
    }
  }

  /// Validate song file
  Future<bool> validateSongFile(Song song) async {
    try {
      return await _fileService.validateAudioFile(song.path);
    } catch (e) {
      debugPrint('Error validating song file: $e');
      return false;
    }
  }

  /// Clean up invalid songs
  Future<int> cleanupInvalidSongs() async {
    try {
      final allSongs = await getAllSongs();
      int removedCount = 0;

      for (final song in allSongs) {
        final isValid = await validateSongFile(song);
        if (!isValid) {
          await deleteSong(song.id);
          removedCount++;
        }
      }

      debugPrint('Removed $removedCount invalid songs');
      return removedCount;
    } catch (e) {
      debugPrint('Error cleaning up invalid songs: $e');
      return 0;
    }
  }

  /// Export library data
  Future<Map<String, dynamic>?> exportLibrary() async {
    try {
      return await _localDataSource.exportToJson();
    } catch (e) {
      debugPrint('Error exporting library: $e');
      return null;
    }
  }

  /// Import library data
  Future<bool> importLibrary(Map<String, dynamic> data) async {
    try {
      await _localDataSource.importFromJson(data);
      return true;
    } catch (e) {
      debugPrint('Error importing library: $e');
      return false;
    }
  }

  /// Clear all library data
  Future<bool> clearLibrary() async {
    try {
      await _localDataSource.clearAllData();
      return true;
    } catch (e) {
      debugPrint('Error clearing library: $e');
      return false;
    }
  }
}

/// Sort types for songs
enum SortType { title, artist, album, duration, dateAdded, playCount }
