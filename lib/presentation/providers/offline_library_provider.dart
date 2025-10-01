import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_app/data/models/downloaded_song.dart';
import 'package:music_app/data/sources/database_helper.dart';

class OfflineLibraryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<DownloadedSong> _downloadedSongs = [];
  bool _isLoading = false;

  List<DownloadedSong> get downloadedSongs => _downloadedSongs;
  bool get isLoading => _isLoading;

  Future<void> loadDownloadedSongs() async {
    try {
      _isLoading = true;
      notifyListeners();
      _downloadedSongs = await _dbHelper.getAllDownloadedSongs();
    } catch (e, st) {
      debugPrint('Error loading songs: $e\n$st');
      _downloadedSongs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDownloadedSong(String id) async {
    try {
      await _dbHelper.deleteDownloadedSong(id);
      _downloadedSongs.removeWhere((song) => song.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting song $id: $e');
    }
  }

  Future<int> cleanupMissingFiles() async {
    int removed = 0;
    final missing = <String>[];
    for (final song in _downloadedSongs) {
      if (!(await File(song.filePath).exists())) {
        missing.add(song.id);
      }
    }
    for (final id in missing) {
      await deleteDownloadedSong(id);
      removed++;
    }
    return removed;
  }
}
