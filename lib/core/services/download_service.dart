import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/downloaded_song.dart';
import '../../data/sources/database_helper.dart';

class DownloadService {
  final YoutubeExplode _yt = YoutubeExplode();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Downloads a YouTube audio stream, saves it locally, and inserts into DB.
  Future<DownloadedSong?> downloadSong({
    required String videoId,
    required String title,
    required String author,
    required String thumbnailUrl,
  }) async {
    try {
      // Get audio stream manifest
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      // Prepare file path
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final filePath = '${dir.path}/downloads/$fileName';
      final file = File(filePath);
      await file.parent.create(recursive: true);

      // Download and save audio
      final stream = _yt.videos.streamsClient.get(audioStreamInfo);
      final output = file.openWrite();
      await stream.pipe(output);
      await output.close();

      // Create DownloadedSong
      final downloadedSong = DownloadedSong(
        id: videoId,
        title: title,
        author: author,
        filePath: filePath,
        thumbnailUrl: thumbnailUrl,
        downloadedAt: DateTime.now(),
      );

      // Insert into DB
      await _dbHelper.insertDownloadedSong(downloadedSong);
      return downloadedSong;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
