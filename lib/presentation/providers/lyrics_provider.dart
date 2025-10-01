import 'package:flutter/material.dart';
import 'package:music_app/core/services/lyrics_service.dart';

class LyricsProvider extends ChangeNotifier {
  final LyricsService _lyricsService = LyricsService();
  String? _lyrics;
  bool _loading = false;
  String? _error;

  String? get lyrics => _lyrics;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchLyrics(String artist, String title) async {
    _loading = true;
    _error = null;
    _lyrics = null;
    notifyListeners();
    try {
      final result = await _lyricsService.fetchLyrics(artist: artist, title: title);
      if (result != null && result.trim().isNotEmpty) {
        _lyrics = result;
      } else {
        _error = 'No lyrics found.';
      }
    } catch (e) {
      _error = 'Failed to fetch lyrics.';
    }
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _lyrics = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
