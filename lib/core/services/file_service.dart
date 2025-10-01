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

  /// Scan device for audio files with multiple fallback strategies
  Future<List<Song>> scanAudioFiles() async {
    try {
      debugPrint('=== Starting Enhanced Audio File Scan ===');

      // Check permissions first
      bool hasPermission = await _audioQuery.permissionsStatus();
      debugPrint('Initial permission status: $hasPermission');
      
      if (!hasPermission) {
        hasPermission = await _audioQuery.permissionsRequest();
        debugPrint('Permission after request: $hasPermission');
        if (!hasPermission) {
          throw FileServiceException('Storage permission denied');
        }
      }

      // Strategy 1: Try standard query without filters (most reliable)
      debugPrint('Strategy 1: Querying with no filters...');
      List<SongModel> songModels = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      debugPrint('Found ${songModels.length} songs with no filters');

      // Strategy 2: Try EXTERNAL uri type if first failed
      if (songModels.isEmpty) {
        debugPrint('Strategy 2: Querying with EXTERNAL uri...');
        songModels = await _audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
        );
        debugPrint('Found ${songModels.length} songs with EXTERNAL uri');
      }

      // Strategy 3: Try INTERNAL uri type
      if (songModels.isEmpty) {
        debugPrint('Strategy 3: Querying with INTERNAL uri...');
        songModels = await _audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.INTERNAL,
        );
        debugPrint('Found ${songModels.length} songs with INTERNAL uri');
      }

      // Strategy 4: Direct file system scan as fallback
      if (songModels.isEmpty) {
        debugPrint('Strategy 4: Performing direct file system scan...');
        return await _directFileSystemScan();
      }

      // Log MediaStore status for debugging
      if (songModels.isEmpty) {
        await _logMediaStoreStatus();
      }

      // Convert and validate songs
      debugPrint('Processing ${songModels.length} songs...');
      final List<Song> songs = [];
      int skippedCount = 0;

      for (final songModel in songModels) {
        try {
          // Basic validation
          if (songModel.data.isEmpty) {
            skippedCount++;
            continue;
          }

          // Check if file exists
          final fileExists = await FileUtils.fileExists(songModel.data);
          if (!fileExists) {
            debugPrint('Skipping non-existent file: ${songModel.data}');
            skippedCount++;
            continue;
          }

          final song = await _convertSongModel(songModel);
          songs.add(song);
        } catch (e) {
          debugPrint('Error processing song ${songModel.title}: $e');
          skippedCount++;
        }
      }

      debugPrint('=== Scan Complete ===');
      debugPrint('Total found: ${songModels.length}');
      debugPrint('Successfully processed: ${songs.length}');
      debugPrint('Skipped: $skippedCount');
      
      if (songs.isNotEmpty) {
        debugPrint('Sample songs:');
        for (var song in songs.take(3)) {
          debugPrint('  - "${song.title}" by ${song.artist}');
          debugPrint('    Path: ${song.path}');
        }
      }

      return songs;
    } catch (e, stackTrace) {
      debugPrint('❌ Error scanning audio files: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Last resort: try direct file system scan
      try {
        debugPrint('Attempting fallback file system scan...');
        return await _directFileSystemScan();
      } catch (fallbackError) {
        debugPrint('Fallback scan also failed: $fallbackError');
        throw FileServiceException('Failed to scan audio files: $e');
      }
    }
  }

  /// Direct file system scan as fallback when MediaStore is empty
  Future<List<Song>> _directFileSystemScan() async {
    debugPrint('Starting direct file system scan...');
    final List<Song> songs = [];
    int fileCount = 0;

    // Common music directories on Android
    final musicDirs = [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Downloads',
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Audiobooks',
      '/storage/emulated/0/Podcasts',
    ];

    for (final dirPath in musicDirs) {
      try {
        final dir = Directory(dirPath);
        if (!await dir.exists()) {
          debugPrint('Directory does not exist: $dirPath');
          continue;
        }

        debugPrint('Scanning directory: $dirPath');
        
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            fileCount++;
            if (FileUtils.isAudioFile(entity.path)) {
              try {
                final song = await _createSongFromFile(entity);
                songs.add(song);
              } catch (e) {
                debugPrint('Error processing file ${entity.path}: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning directory $dirPath: $e');
      }
    }

    debugPrint('Direct scan found ${songs.length} audio files (checked $fileCount files)');
    return songs;
  }

  /// Create Song model from file without MediaStore
  Future<Song> _createSongFromFile(File file) async {
    final fileName = file.path.split('/').last;
    final fileNameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    
    // Try to extract metadata from filename (common format: Artist - Title.mp3)
    String title = fileNameWithoutExt;
    String artist = 'Unknown Artist';
    
    if (fileNameWithoutExt.contains(' - ')) {
      final parts = fileNameWithoutExt.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }

    final fileSize = await FileUtils.getFileSize(file.path);
    final modificationDate = await FileUtils.getFileModificationDate(file.path);

    // Generate a pseudo-ID based on file path hash
    final pathHash = file.path.hashCode.abs();

    return Song(
      id: pathHash,
      title: title,
      artist: artist,
      album: 'Unknown Album',
      albumArt: null,
      path: file.path,
      duration: 0, // Can't get duration without MediaStore
      genre: null,
      year: null,
      track: null,
      size: fileSize,
      dateAdded: modificationDate,
      dateModified: modificationDate,
    );
  }

  /// Log MediaStore status for debugging
  Future<void> _logMediaStoreStatus() async {
    try {
      final albums = await _audioQuery.queryAlbums();
      final artists = await _audioQuery.queryArtists();
      debugPrint('MediaStore Status:');
      debugPrint('  - Albums indexed: ${albums.length}');
      debugPrint('  - Artists indexed: ${artists.length}');
      
      if (albums.isEmpty && artists.isEmpty) {
        debugPrint('⚠️ MediaStore appears to be empty or not indexed');
        debugPrint('This usually happens when:');
        debugPrint('  1. Music files were recently added');
        debugPrint('  2. Device media scanner hasn\'t run yet');
        debugPrint('  3. Files are in non-standard locations');
      }
    } catch (e) {
      debugPrint('Could not query MediaStore status: $e');
    }
  }

  /// Convert SongModel to Song
  Future<Song> _convertSongModel(SongModel songModel) async {
    final fileSize = await FileUtils.getFileSize(songModel.data);
    final modificationDate = await FileUtils.getFileModificationDate(songModel.data);

    return Song(
      id: songModel.id,
      title: songModel.title,
      artist: songModel.artist ?? 'Unknown Artist',
      album: songModel.album ?? 'Unknown Album',
      albumArt: null,
      path: songModel.data,
      duration: songModel.duration ?? 0,
      genre: songModel.genre,
      year: null,
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
      String? cachedPath = await getCachedAlbumArtwork(songId);
      if (cachedPath != null) {
        return cachedPath;
      }

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
}

class FileServiceException implements Exception {
  final String message;
  const FileServiceException(this.message);

  @override
  String toString() => 'FileServiceException: $message';
}