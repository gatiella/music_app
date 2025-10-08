import 'package:flutter/material.dart';

/// Simple auth provider that doesn't require Google Sign-In
/// You can still use YouTube Music search and playback without authentication
class YTMusicAuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  String? _userName;
  String? _userEmail;

  bool get isSignedIn => _isSignedIn;
  bool get isSigningIn => false;
  bool get isAvailable => true; // Always available in simple mode
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // Mock user object for compatibility
  MockUser? get user => _isSignedIn 
      ? MockUser(_userName ?? 'User', _userEmail ?? 'user@example.com')
      : null;

  Future<void> signIn() async {
    // Mock sign-in - not actually connecting to Google
    await Future.delayed(const Duration(milliseconds: 500));
    _isSignedIn = true;
    _userName = 'Local User';
    _userEmail = 'local@app.com';
    notifyListeners();
  }

  Future<void> signOut() async {
    _isSignedIn = false;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}

/// Mock user class for compatibility
class MockUser {
  final String displayName;
  final String email;

  MockUser(this.displayName, this.email);
}