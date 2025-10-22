import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ConnectivityHelper {
  /// Check if device has internet connection
  /// Works on both web and mobile platforms
  static Future<bool> hasInternetConnection() async {
    // On web, we can't use InternetAddress.lookup
    // So we'll try a simple HTTP request instead
    if (kIsWeb) {
      try {
        final response = await http.get(
          Uri.parse('https://www.google.com'),
        ).timeout(const Duration(seconds: 5));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    } else {
      // On mobile/desktop, use InternetAddress.lookup
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    }
  }
  
  /// Check connectivity before making a request
  static Future<void> ensureConnected() async {
    if (!await hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
  }
}