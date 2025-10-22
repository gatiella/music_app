import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/foundation.dart';

class YTMusicSource {
  // Singleton pattern for better resource management
  static final YTMusicSource _instance = YTMusicSource._internal();
  factory YTMusicSource() => _instance;
  YTMusicSource._internal();

  YoutubeExplode? _yt;
  
  YoutubeExplode get _youtube {
    _yt ??= YoutubeExplode();
    return _yt!;
  }

  /// Fetch trending or popular music videos for quick picks
  Future<List<Video>> fetchQuickPicks() async {
    try {
      debugPrint('Fetching quick picks...');
      final results = await _youtube.search.search('Top Music');
      final videos = results.whereType<Video>().toList();
      debugPrint('Found ${videos.length} quick picks');
      return videos;
    } catch (e) {
      debugPrint('Error fetching quick picks: $e');
      rethrow;
    }
  }

  Future<List<Video>> search(String query) async {
    try {
      debugPrint('Searching for: $query');
      final results = await _youtube.search.search(query);
      final videos = results.whereType<Video>().toList();
      debugPrint('Found ${videos.length} results for "$query"');
      return videos;
    } catch (e) {
      debugPrint('Error searching for "$query": $e');
      rethrow;
    }
  }

  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      debugPrint('Getting audio stream for: $videoId');
      final manifest = await _youtube.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      debugPrint('Got audio stream URL for $videoId');
      return audio.url.toString();
    } catch (e) {
      debugPrint('Error getting audio stream for $videoId: $e');
      rethrow;
    }
  }

  void close() {
    debugPrint('Closing YTMusicSource');
    _yt?.close();
    _yt = null;
  }
}