import 'package:audio_service/audio_service.dart';
class DownloadedSong {

  MediaItem toMediaItem() => MediaItem(
        id: id,
        title: title,
        artist: author,
        artUri: thumbnailUrl.isNotEmpty ? Uri.parse(thumbnailUrl) : null,
        extras: {'filePath': filePath},
      );
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String thumbnailUrl;
  final DateTime downloadedAt;

  DownloadedSong({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.thumbnailUrl,
    required this.downloadedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'filePath': filePath,
        'thumbnailUrl': thumbnailUrl,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadedSong.fromMap(Map<String, dynamic> map) => DownloadedSong(
        id: map['id'],
        title: map['title'],
        author: map['author'],
        filePath: map['filePath'],
        thumbnailUrl: map['thumbnailUrl'],
        downloadedAt: DateTime.parse(map['downloadedAt']),
      );
}
