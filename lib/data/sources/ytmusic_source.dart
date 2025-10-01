
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YTMusicSource {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Fetch trending or popular music videos for quick picks
  Future<List<Video>> fetchQuickPicks() async {
    // Use a default search query for trending/popular music
    final results = await _yt.search.search('Top Music');
    return results.whereType<Video>().toList();
  }

  Future<List<Video>> search(String query) async {
    final results = await _yt.search.search(query);
    return results.whereType<Video>().toList();
  }

  Future<String?> getAudioStreamUrl(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    final audio = manifest.audioOnly.withHighestBitrate();
    return audio.url.toString();
  }

  void close() {
    _yt.close();
  }
}
