import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class FileUtils {
  /// Checks if a file is an audio file based on extension
  static bool isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return AppConstants.audioExtensions.contains(extension);
  }

  /// Gets the file extension from a file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Gets the file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Gets the file name with extension
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Gets the directory path of a file
  static String getDirectoryPath(String filePath) {
    return path.dirname(filePath);
  }

  /// Formats file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Checks if a file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gets file modification date
  static Future<DateTime?> getFileModificationDate(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.modified;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates a directory if it doesn't exist
  static Future<Directory> createDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Gets the app's document directory
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Gets the app's cache directory
  static Future<Directory> getAppCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Creates a file path in the app's documents directory
  static Future<String> getDocumentFilePath(String fileName) async {
    final dir = await getAppDocumentsDirectory();
    return path.join(dir.path, fileName);
  }

  /// Creates a file path in the app's cache directory
  static Future<String> getCacheFilePath(String fileName) async {
    final dir = await getAppCacheDirectory();
    return path.join(dir.path, fileName);
  }

  /// Saves data to a file
  static Future<bool> saveToFile(String filePath, Uint8List data) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Saves text to a file
  static Future<bool> saveTextToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reads data from a file
  static Future<Uint8List?> readFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Reads text from a file
  static Future<String?> readTextFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Deletes a file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copies a file
  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Moves a file
  static Future<bool> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.rename(destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gets all files in a directory
  static Future<List<File>> getFilesInDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        return directory.listSync().whereType<File>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Gets all audio files in a directory recursively
  static Future<List<File>> getAudioFilesInDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        final List<File> audioFiles = [];

        await for (final entity in directory.list(recursive: true)) {
          if (entity is File && isAudioFile(entity.path)) {
            audioFiles.add(entity);
          }
        }

        return audioFiles;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cleans up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            try {
              await entity.delete();
            } catch (e) {
              // Continue with other files if one fails
            }
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Gets cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              totalSize += stat.size;
            } catch (e) {
              // Continue with other files
            }
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clears all cache files
  static Future<bool> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            // Continue with other files
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates file path
  static bool isValidFilePath(String filePath) {
    try {
      // Check if path is not empty
      if (filePath.isEmpty) return false;

      // Check for invalid characters (basic check)
      final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
      for (final char in invalidChars) {
        if (filePath.contains(char)) return false;
      }

      // Check if it's an absolute path
      return path.isAbsolute(filePath);
    } catch (e) {
      return false;
    }
  }

  /// Gets safe file name (removes invalid characters)
  static String getSafeFileName(String fileName) {
    // Replace invalid characters with underscore
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return fileName.replaceAll(invalidChars, '_');
  }

  /// Generates unique file name if file already exists
  static Future<String> getUniqueFileName(
    String dirPath,
    String fileName,
  ) async {
    String name = path.basenameWithoutExtension(fileName);
    String extension = path.extension(fileName);
    String uniqueName = fileName;
    int counter = 1;

    while (await fileExists(path.join(dirPath, uniqueName))) {
      uniqueName = '${name}_$counter$extension';
      counter++;
    }

    return uniqueName;
  }

  /// Checks if directory is writable
  static Future<bool> isDirectoryWritable(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        return false;
      }

      // Try to create a temporary file
      final tempFile = File(path.join(dirPath, '.temp_write_test'));
      await tempFile.writeAsString('test');
      await tempFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets file MIME type based on extension
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);

    switch (extension) {
      case '.mp3':
        return 'audio/mpeg';
      case '.flac':
        return 'audio/flac';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
        return 'audio/mp4';
      case '.wma':
        return 'audio/x-ms-wma';
      default:
        return 'audio/mpeg'; // Default to mp3
    }
  }

  /// Extracts album art file path from audio file path
  static String? getAlbumArtPath(String audioFilePath) {
    final dir = getDirectoryPath(audioFilePath);
    final commonNames = [
      'folder.jpg',
      'cover.jpg',
      'album.jpg',
      'albumart.jpg',
    ];

    for (final name in commonNames) {
      final artPath = path.join(dir, name);
      if (File(artPath).existsSync()) {
        return artPath;
      }
    }

    return null;
  }

  /// Creates playlist file path
  static Future<String> createPlaylistFilePath(String playlistName) async {
    final documentsDir = await getAppDocumentsDirectory();
    final playlistsDir = Directory(path.join(documentsDir.path, 'playlists'));
    await playlistsDir.create(recursive: true);

    final safeName = getSafeFileName(playlistName);
    final fileName = '$safeName.m3u';

    return path.join(playlistsDir.path, fileName);
  }

  /// Exports playlist to M3U format
  static Future<bool> exportPlaylistM3U(
    String filePath,
    List<String> songPaths,
  ) async {
    try {
      final content = '#EXTM3U\n${songPaths.join('\n')}';
      return await saveTextToFile(filePath, content);
    } catch (e) {
      return false;
    }
  }

  /// Imports playlist from M3U format
  static Future<List<String>?> importPlaylistM3U(String filePath) async {
    try {
      final content = await readTextFromFile(filePath);
      if (content == null) return null;

      final lines = content.split('\n');
      final songPaths = <String>[];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
          songPaths.add(trimmed);
        }
      }

      return songPaths;
    } catch (e) {
      return null;
    }
  }
}
