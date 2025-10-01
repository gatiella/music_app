import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/presentation/providers/music_library_provider.dart';

class DownloadButton extends StatelessWidget {
  final String videoId;
  final String title;
  final String author;
  final String thumbnailUrl;

  const DownloadButton({
    super.key,
    required this.videoId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Download'),
      onPressed: () async {
        final provider = Provider.of<MusicLibraryProvider>(context, listen: false);
        final result = await provider.downloadSongFromYouTube(
          videoId: videoId,
          title: title,
          author: author,
          thumbnailUrl: thumbnailUrl,
        );
        final snackBar = SnackBar(
          content: Text(result != null ? 'Download complete!' : 'Download failed.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}
