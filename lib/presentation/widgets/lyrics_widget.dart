import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/presentation/providers/lyrics_provider.dart';

class LyricsWidget extends StatelessWidget {
  final String artist;
  final String title;
  const LyricsWidget({super.key, required this.artist, required this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LyricsProvider()..fetchLyrics(artist, title),
      child: Consumer<LyricsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
          }
          if (provider.lyrics != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.lyrics!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: Text('No lyrics found.'));
        },
      ),
    );
  }
}
