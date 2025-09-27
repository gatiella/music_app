import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestPermissions() async {
    // Skip permissions on desktop platforms
    if (!_isMobilePlatform()) {
      debugPrint('Skipping permissions on desktop platform');
      return true;
    }

    try {
      // Request multiple permissions at once
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.audio,
        Permission.notification,
        Permission.manageExternalStorage,
      ].request();

      // Check if all essential permissions are granted
      bool storageGranted = await _checkStoragePermission();
      bool audioGranted = statuses[Permission.audio]?.isGranted ?? false;
      bool notificationGranted =
          statuses[Permission.notification]?.isGranted ?? false;

      debugPrint('Storage Permission: $storageGranted');
      debugPrint('Audio Permission: $audioGranted');
      debugPrint('Notification Permission: $notificationGranted');

      return storageGranted && audioGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> _checkStoragePermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }

    try {
      // For Android 13+ (API level 33), we need different permissions
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.audio.isGranted) {
        return true;
      }

      // For older Android versions
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Try requesting the new media permissions for Android 13+
      Map<Permission, PermissionStatus> mediaStatuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();

      return mediaStatuses[Permission.audio]?.isGranted ?? false;
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (!_isMobilePlatform()) {
      return true;
    }
    return await _checkStoragePermission();
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
      // First try the new Android 13+ permissions
      PermissionStatus audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) {
        return true;
      }

      // Fallback to legacy storage permission
      PermissionStatus storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
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
      await openAppSettings();
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
}
