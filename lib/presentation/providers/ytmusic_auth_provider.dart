import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class YTMusicAuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleSignInAccount? _user;
  bool _isSigningIn = false;
  bool _initialized = false;

  GoogleSignInAccount? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isSigningIn => _isSigningIn;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        // optionally pass clientId / serverClientId
        // clientId: 'YOUR_CLIENT_ID',
        // serverClientId: 'YOUR_SERVER_CLIENT_ID',
      );
      _initialized = true;

      // Listen for authentication events
      _googleSignIn.authenticationEvents.listen((GoogleSignInAuthenticationEvent event) {
        // event is either SignIn or SignOut
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _user = event.user;
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _user = null;
        }
        notifyListeners();
      });
    }
  }

  Future<void> signIn() async {
    _isSigningIn = true;
    notifyListeners();

    await _ensureInitialized();

    try {
      // `authenticate()` is the new method replacing signIn
      final account = await _googleSignIn.authenticate();
      _user = account;

      // You may then perform authorization (scopes) if needed:
      // final authorization = await account.authorizationClient
      //      .authorizationForScopes([... your scopes ...]);

    } catch (e) {
      // Sign in failed / cancelled
      _user = null;
      // optionally log error
    }

    _isSigningIn = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}
