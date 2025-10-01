class YTMusicPlaylist {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? coverImageUrl;
  final String? description;
  final List<String>? tags;

  YTMusicPlaylist({
    required this.id,
    required this.name,
    required this.createdAt,
    this.coverImageUrl,
    this.description,
    this.tags,
  });

  factory YTMusicPlaylist.fromMap(Map<String, dynamic> map) {
    return YTMusicPlaylist(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      coverImageUrl: map['coverImageUrl'],
      description: map['description'],
      tags: map['tags'] != null
          ? (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'tags': tags?.join(','),
    };
  }
}
