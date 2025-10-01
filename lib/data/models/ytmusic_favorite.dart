class YTMusicFavorite {

  final String videoId;
  final String title;
  final String author;
  final String thumbnailUrl;
  final DateTime savedAt;


  YTMusicFavorite({
    required this.videoId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.savedAt,
  });


  factory YTMusicFavorite.fromMap(Map<String, dynamic> map) {
    return YTMusicFavorite(
      videoId: map['videoId'] ?? map['id'],
      title: map['title'],
      author: map['author'] ?? map['artist'],
      thumbnailUrl: map['thumbnailUrl'],
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['savedAt'] ?? map['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'title': title,
      'author': author,
      'thumbnailUrl': thumbnailUrl,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }
}
