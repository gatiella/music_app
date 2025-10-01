import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  // Example: Use lyrics.ovh API (free, simple, for demo)
  Future<String?> fetchLyrics({required String artist, required String title}) async {
    final url = Uri.parse('https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['lyrics'] as String?;
    }
    return null;
  }
}
