import 'package:flutter/material.dart';
import 'package:music_app/core/services/ytmusic_sync_service.dart';
import 'package:music_app/presentation/providers/ytmusic_auth_provider.dart';

class YTMusicSyncProvider extends ChangeNotifier {
  final YTMusicSyncService syncService;
  
  bool _isSyncing = false;
  String? _error;
  
  YTMusicSyncProvider({required this.syncService});

  bool get isSyncing => _isSyncing;
  String? get error => _error;

  Future<void> syncLibrary(YTMusicAuthProvider authProvider) async {
    if (!authProvider.isSignedIn) {
      _error = 'Not signed in to YouTube Music';
      notifyListeners();
      return;
    }
    
    _isSyncing = true;
    _error = null;
    notifyListeners();
    
    try {
      await syncService.syncLibrary(authProvider.user!);
      // TODO: Save fetched data to local DB
    } catch (e) {
      _error = 'Sync failed: $e';
    }
    
    _isSyncing = false;
    notifyListeners();
  }
}