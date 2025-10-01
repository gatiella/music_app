import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {
    // Skip permissions on desktop platforms
    if (!_isMobilePlatform()) {
      debugPrint('Skipping permissions on desktop platform');
      return true;
    }

    try {
      // Get Android version
      int sdkInt = await _getAndroidSdkVersion();
      debugPrint('Android SDK Version: $sdkInt');

      Map<Permission, PermissionStatus> statuses;
      
      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - ONLY use READ_MEDIA_AUDIO
        debugPrint('Using Android 13+ permissions (READ_MEDIA_AUDIO only)');
        statuses = await [
          Permission.audio, // READ_MEDIA_AUDIO - This is the correct permission for Android 13+
          Permission.notification,
        ].request();
        
        debugPrint('Audio Permission: ${statuses[Permission.audio]}');
        debugPrint('Notification Permission: ${statuses[Permission.notification]}');
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32)
        debugPrint('Using Android 11-12 permissions');
        statuses = await [
          Permission.storage,
          Permission.notification,
        ].request();
        
        debugPrint('Storage Permission: ${statuses[Permission.storage]}');
        debugPrint('Notification Permission: ${statuses[Permission.notification]}');
      } else {
        // Android 10 and below (API 29 and below)
        debugPrint('Using legacy storage permissions');
        statuses = await [
          Permission.storage,
          Permission.notification,
        ].request();
        
        debugPrint('Storage Permission: ${statuses[Permission.storage]}');
        debugPrint('Notification Permission: ${statuses[Permission.notification]}');
      }

      // Check final permission status
      bool hasPermission = await checkStoragePermission();
      debugPrint('Final Storage Permission Status: $hasPermission');
      
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting Android version: $e');
      return 0;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      int sdkInt = await _getAndroidSdkVersion();
      
      if (sdkInt >= 33) {
        // Android 13+ - ONLY check READ_MEDIA_AUDIO
        final audioGranted = await Permission.audio.isGranted;
        debugPrint('checkStoragePermission: Android 13+, audio permission: $audioGranted');
        return audioGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 - Check storage
        final storageGranted = await Permission.storage.isGranted;
        debugPrint('checkStoragePermission: Android 11-12, storage permission: $storageGranted');
        return storageGranted;
      } else {
        // Android 10 and below - Check legacy storage
        final storageGranted = await Permission.storage.isGranted;
        debugPrint('checkStoragePermission: Legacy Android, storage permission: $storageGranted');
        return storageGranted;
      }
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<bool> checkAudioPermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      return await Permission.audio.isGranted;
    } catch (e) {
      debugPrint('Error checking audio permission: $e');
      return false;
    }
  }

  static Future<bool> checkNotificationPermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      return await Permission.notification.isGranted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      int sdkInt = await _getAndroidSdkVersion();
      
      if (sdkInt >= 33) {
        // Android 13+ - Request READ_MEDIA_AUDIO
        debugPrint('Requesting READ_MEDIA_AUDIO for Android 13+');
        PermissionStatus status = await Permission.audio.request();
        debugPrint('READ_MEDIA_AUDIO status: $status');
        return status.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 - Request storage
        debugPrint('Requesting storage permission for Android 11-12');
        PermissionStatus storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else {
        // Android 10 and below - Use legacy storage
        debugPrint('Requesting legacy storage permission');
        PermissionStatus status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> requestAudioPermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      PermissionStatus status = await Permission.audio.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting audio permission: $e');
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    if (!_isMobilePlatform()) {
      debugPrint('App settings not available on desktop platform');
      return;
    }

    try {
      await permission_handler.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  static Future<bool> shouldShowRationale(Permission permission) async {
    if (!_isMobilePlatform()) {
      return false;
    }

    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      debugPrint('Error checking rationale: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> getAllPermissionStatuses() async {
    return {
      'storage': await checkStoragePermission(),
      'audio': await checkAudioPermission(),
      'notification': await checkNotificationPermission(),
    };
  }

  /// Check if we're running on a mobile platform that supports permissions
  static bool _isMobilePlatform() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Get detailed permission info for debugging
  static Future<String> getPermissionDebugInfo() async {
    if (!_isMobilePlatform()) {
      return 'Not a mobile platform';
    }

    try {
      int sdkInt = await _getAndroidSdkVersion();
      bool storage = await checkStoragePermission();
      bool audio = await checkAudioPermission();
      bool notification = await checkNotificationPermission();
      
      return '''
Permission Debug Info:
- Android SDK: $sdkInt
- Storage Permission (effective): $storage
- Audio Permission (READ_MEDIA_AUDIO): $audio
- Notification Permission: $notification
- Platform: ${Platform.operatingSystem}
- For SDK $sdkInt, using: ${sdkInt >= 33 ? 'READ_MEDIA_AUDIO' : 'READ_EXTERNAL_STORAGE'}
''';
    } catch (e) {
      return 'Error getting debug info: $e';
    }
  }
}