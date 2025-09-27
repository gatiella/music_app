import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/file_utils.dart';
import '../constants/app_constants.dart';
import '../../data/models/song.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Scan device for audio files
  Future<List<Song>> scanAudioFiles() async {
    try {
      debugPrint('Starting audio file scan...');

      // Check permissions first
      bool hasPermission = await _audioQuery.permissionsStatus();
      if (!hasPermission) {
        hasPermission = await _audioQuery.permissionsRequest();
        if (!hasPermission) {
          throw FileServiceException('Storage permission denied');
        }
      }

      // Query songs from device
      final List<SongModel> songModels = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      debugPrint('Found ${songModels.length} audio files');

      // Convert to our Song model
      final List<Song> songs = [];
      for (final songModel in songModels) {
        try {
          // Validate file exists and is accessible
          if (await FileUtils.fileExists(songModel.data)) {
            final song = await _convertSongModel(songModel);
            songs.add(song);
          }
        } catch (e) {
          debugPrint('Error processing song ${songModel.title}: $e');
          // Continue with other songs
        }
      }

      debugPrint('Successfully processed ${songs.length} songs');
      return songs;
    } catch (e) {
      debugPrint('Error scanning audio files: $e');
      throw FileServiceException('Failed to scan audio files: $e');
    }
  }

  /// Convert SongModel to Song - Fixed year property issue
  Future<Song> _convertSongModel(SongModel songModel) async {
    // Get file size
    final fileSize = await FileUtils.getFileSize(songModel.data);

    // Get file modification date
    final modificationDate = await FileUtils.getFileModificationDate(
      songModel.data,
    );

    return Song(
      id: songModel.id,
      title: songModel.title,
      artist: songModel.artist ?? 'Unknown Artist',
      album: songModel.album ?? 'Unknown Album',
      albumArt: null, // Will be handled separately
      path: songModel.data,
      duration: songModel.duration ?? 0,
      genre: songModel.genre,
      year: null, // SongModel doesn't have year property, set to null
      track: songModel.track,
      size: fileSize,
      dateAdded: songModel.dateAdded != null
          ? DateTime.fromMillisecondsSinceEpoch(songModel.dateAdded!)
          : null,
      dateModified: modificationDate,
    );
  }

  /// Get album artwork for a song
  Future<Uint8List?> getAlbumArtwork(int songId, {int size = 200}) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: size,
      );
    } catch (e) {
      debugPrint('Error getting album artwork for song $songId: $e');
      return null;
    }
  }

  /// Save album artwork to file
  Future<String?> saveAlbumArtwork(int songId, Uint8List artworkData) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final artworkDir = Directory('${documentsDir.path}/artwork');

      if (!await artworkDir.exists()) {
        await artworkDir.create(recursive: true);
      }

      final artworkPath = '${artworkDir.path}/$songId.jpg';
      final artworkFile = File(artworkPath);

      await artworkFile.writeAsBytes(artworkData);
      return artworkPath;
    } catch (e) {
      debugPrint('Error saving album artwork: $e');
      return null;
    }
  }

  /// Get cached album artwork path
  Future<String?> getCachedAlbumArtwork(int songId) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final artworkPath = '${documentsDir.path}/artwork/$songId.jpg';

      if (await FileUtils.fileExists(artworkPath)) {
        return artworkPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting cached album artwork: $e');
      return null;
    }
  }

  /// Get or create album artwork
  Future<String?> getOrCreateAlbumArtwork(int songId) async {
    try {
      // First check if we have cached artwork
      String? cachedPath = await getCachedAlbumArtwork(songId);
      if (cachedPath != null) {
        return cachedPath;
      }

      // Try to get artwork from the audio file
      final artworkData = await getAlbumArtwork(songId);
      if (artworkData != null) {
        return await saveAlbumArtwork(songId, artworkData);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting or creating album artwork: $e');
      return null;
    }
  }

  /// Scan specific directory for audio files
  Future<List<File>> scanDirectory(String dirPath) async {
    try {
      return await FileUtils.getAudioFilesInDirectory(dirPath);
    } catch (e) {
      throw FileServiceException('Failed to scan directory: $e');
    }
  }

  /// Get audio file metadata
  Future<Map<String, dynamic>?> getAudioMetadata(String filePath) async {
    try {
      if (!await FileUtils.fileExists(filePath)) {
        return null;
      }

      // Use on_audio_query to get metadata
      final songModels = await _audioQuery.querySongs(
        path: filePath,
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );

      if (songModels.isNotEmpty) {
        final song = songModels.first;
        return {
          'title': song.title,
          'artist': song.artist ?? 'Unknown Artist',
          'album': song.album ?? 'Unknown Album',
          'duration': song.duration ?? 0,
          'genre': song.genre,
          'year': null, // SongModel doesn't have year property
          'track': song.track,
          'size': song.size,
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error getting audio metadata: $e');
      return null;
    }
  }

  /// Export playlist to M3U file
  Future<bool> exportPlaylistM3U(String playlistName, List<Song> songs) async {
    try {
      final filePath = await FileUtils.createPlaylistFilePath(playlistName);
      final songPaths = songs.map((song) => song.path).toList();
      return await FileUtils.exportPlaylistM3U(filePath, songPaths);
    } catch (e) {
      debugPrint('Error exporting playlist: $e');
      return false;
    }
  }

  /// Import playlist from M3U file
  Future<List<String>?> importPlaylistM3U(String filePath) async {
    try {
      return await FileUtils.importPlaylistM3U(filePath);
    } catch (e) {
      debugPrint('Error importing playlist: $e');
      return null;
    }
  }

  /// Get storage directories
  Future<List<Directory>> getStorageDirectories() async {
    try {
      final List<Directory> directories = [];

      // Add external storage directories
      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs != null) {
          directories.addAll(externalDirs);
        }
      }

      // Add application documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      directories.add(documentsDir);

      return directories;
    } catch (e) {
      debugPrint('Error getting storage directories: $e');
      return [];
    }
  }

  /// Get common music directories
  List<String> getCommonMusicDirectories() {
    return [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Downloads',
      '/sdcard/Music',
      '/sdcard/Download',
      '/sdcard/Downloads',
    ];
  }

  /// Validate audio file
  Future<bool> validateAudioFile(String filePath) async {
    try {
      // Check if file exists
      if (!await FileUtils.fileExists(filePath)) {
        return false;
      }

      // Check file extension
      if (!FileUtils.isAudioFile(filePath)) {
        return false;
      }

      // Check file size (should be > 0)
      final fileSize = await FileUtils.getFileSize(filePath);
      if (fileSize <= 0) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating audio file: $e');
      return false;
    }
  }

  /// Clean up artwork cache
  Future<void> cleanupArtworkCache() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final artworkDir = Directory('${documentsDir.path}/artwork');

      if (await artworkDir.exists()) {
        await for (final file in artworkDir.list()) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up artwork cache: $e');
    }
  }

  /// Get artwork cache size
  Future<int> getArtworkCacheSize() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final artworkDir = Directory('${documentsDir.path}/artwork');

      if (!await artworkDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final file in artworkDir.list()) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting artwork cache size: $e');
      return 0;
    }
  }

  /// Create backup of music library data
  Future<bool> createBackup(Map<String, dynamic> data) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${documentsDir.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath =
          '${backupDir.path}/music_library_backup_$timestamp.json';

      final backupContent = {
        'version': AppConstants.appVersion,
        'backupDate': DateTime.now().toIso8601String(),
        'data': data,
      };

      return await FileUtils.saveTextToFile(
        backupPath,
        backupContent.toString(),
      );
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }

  /// Restore from backup
  Future<Map<String, dynamic>?> restoreFromBackup(String backupPath) async {
    try {
      final backupContent = await FileUtils.readTextFromFile(backupPath);
      if (backupContent == null) {
        return null;
      }

      // Parse JSON content
      // Note: In a real implementation, you'd use dart:convert
      // For now, returning a placeholder
      return {'restored': true};
    } catch (e) {
      debugPrint('Error restoring from backup: $e');
      return null;
    }
  }

  /// Get all backup files
  Future<List<File>> getBackupFiles() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${documentsDir.path}/backups');

      if (!await backupDir.exists()) {
        return [];
      }

      final List<File> backupFiles = [];
      await for (final file in backupDir.list()) {
        if (file is File && file.path.endsWith('.json')) {
          backupFiles.add(file);
        }
      }

      // Sort by modification date (newest first)
      backupFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return backupFiles;
    } catch (e) {
      debugPrint('Error getting backup files: $e');
      return [];
    }
  }

  /// Delete old backup files (keep only recent ones)
  Future<void> cleanupBackups({int maxBackups = 5}) async {
    try {
      final backupFiles = await getBackupFiles();

      if (backupFiles.length > maxBackups) {
        final filesToDelete = backupFiles.skip(maxBackups);
        for (final file in filesToDelete) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up backups: $e');
    }
  }

  /// Check if file is corrupted
  Future<bool> isFileCorrupted(String filePath) async {
    try {
      final file = File(filePath);

      // Basic checks
      if (!await file.exists()) {
        return true;
      }

      final stat = await file.stat();
      if (stat.size == 0) {
        return true;
      }

      // Try to read a small portion of the file
      final bytes = await file.openRead(0, 1024).first;
      if (bytes.isEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking file corruption: $e');
      return true; // Assume corrupted if we can't check
    }
  }

  /// Get file modification time
  Future<DateTime?> getFileModificationTime(String filePath) async {
    try {
      return await FileUtils.getFileModificationDate(filePath);
    } catch (e) {
      debugPrint('Error getting file modification time: $e');
      return null;
    }
  }

  /// Check if file has been modified since last scan
  Future<bool> hasFileBeenModified(
    String filePath,
    DateTime? lastScanTime,
  ) async {
    if (lastScanTime == null) return true;

    final modificationTime = await getFileModificationTime(filePath);
    if (modificationTime == null) return true;

    return modificationTime.isAfter(lastScanTime);
  }
}

/// Custom exception for file service operations
class FileServiceException implements Exception {
  final String message;

  const FileServiceException(this.message);

  @override
  String toString() => 'FileServiceException: $message';
}
