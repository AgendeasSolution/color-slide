import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Service for checking app updates from App Store and Play Store
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // Store URLs
  static const String _appStoreUrl = 'https://apps.apple.com/us/app/color-slide-ball-slide-puzzle/id6754687571';
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.fgtp.color_slide';
  
  // Preference keys
  static const String _lastShownTimestampKey = 'update_popup_last_shown';
  
  // Cache for package info
  PackageInfo? _packageInfo;
  String? _cachedVersion;
  
  final ConnectivityService _connectivityService = ConnectivityService();
  
  /// Initialize and cache package info
  Future<void> _ensurePackageInfo() async {
    if (_packageInfo == null) {
      _packageInfo = await PackageInfo.fromPlatform();
      _cachedVersion = _packageInfo!.version;
    }
  }
  
  /// Get current app version dynamically
  Future<String> _getCurrentVersion() async {
    await _ensurePackageInfo();
    return _cachedVersion ?? '1.0.0';
  }

  /// Check if an update is available and if pop-up should be shown
  /// Returns true if update is available and 24 hours have passed since last shown
  Future<bool> checkForUpdate() async {
    try {
      // Check if pop-up was shown in the last 24 hours
      if (!await _shouldShowPopup()) {
        return false;
      }

      // Check internet connectivity first
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (!hasInternet) {
        return false;
      }

      // Get current app version
      final currentVersion = await _getCurrentVersion();

      // Get platform-specific store version
      String? storeVersion;
      if (Platform.isIOS) {
        storeVersion = await _getAppStoreVersion();
      } else if (Platform.isAndroid) {
        storeVersion = await _getPlayStoreVersion();
      }

      if (storeVersion == null) {
        return false;
      }

      // Compare versions
      return _isVersionNewer(storeVersion, currentVersion);
    } catch (e) {
      return false;
    }
  }

  /// Check if pop-up should be shown (24 hours have passed since last shown)
  Future<bool> _shouldShowPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownTimestamp = prefs.getInt(_lastShownTimestampKey);
      
      // If never shown before, allow showing
      if (lastShownTimestamp == null) {
        return true;
      }
      
      // Calculate time difference
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = now - lastShownTimestamp;
      const oneDayInMillis = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
      
      // Show if 24 hours have passed
      return timeDifference >= oneDayInMillis;
    } catch (e) {
      // On error, allow showing (fail open)
      return true;
    }
  }

  /// Mark the pop-up as shown (store current timestamp)
  Future<void> _markPopupAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastShownTimestampKey, now);
    } catch (e) {
      // Silently handle error
    }
  }

  /// Mark the pop-up as dismissed (same as shown, to prevent showing again today)
  Future<void> markPopupAsDismissed() async {
    await _markPopupAsShown();
  }

  /// Get App Store version by parsing the HTML
  Future<String?> _getAppStoreVersion() async {
    try {
      final response = await http.get(Uri.parse(_appStoreUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final html = response.body;
        
        // Try to find version in the HTML
        // App Store typically has version in meta tags or structured data
        final versionPattern = RegExp(r'"version":"([\d.]+)"');
        final match = versionPattern.firstMatch(html);
        
        if (match != null) {
          return match.group(1);
        }
        
        // Alternative: Look for version in text content
        final altPattern = RegExp(r'Version\s+([\d.]+)', caseSensitive: false);
        final altMatch = altPattern.firstMatch(html);
        
        if (altMatch != null) {
          return altMatch.group(1);
        }
      }
    } catch (e) {
      // Silently handle fetch error
    }
    return null;
  }

  /// Get Play Store version by parsing the HTML
  Future<String?> _getPlayStoreVersion() async {
    try {
      final response = await http.get(Uri.parse(_playStoreUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final html = response.body;
        
        // Play Store has version in structured data or meta tags
        final versionPattern = RegExp(r'"version":"([\d.]+)"');
        final match = versionPattern.firstMatch(html);
        
        if (match != null) {
          return match.group(1);
        }
        
        // Alternative: Look for "Current Version" text
        final altPattern = RegExp(r'Current Version[^>]*>([\d.]+)', caseSensitive: false);
        final altMatch = altPattern.firstMatch(html);
        
        if (altMatch != null) {
          return altMatch.group(1);
        }
      }
    } catch (e) {
      // Silently handle fetch error
    }
    return null;
  }

  /// Compare two version strings
  /// Returns true if version1 is newer than version2
  bool _isVersionNewer(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      
      // Pad shorter version with zeros
      while (v1Parts.length < v2Parts.length) {
        v1Parts.add(0);
      }
      while (v2Parts.length < v1Parts.length) {
        v2Parts.add(0);
      }
      
      for (int i = 0; i < v1Parts.length; i++) {
        if (v1Parts[i] > v2Parts[i]) {
          return true;
        } else if (v1Parts[i] < v2Parts[i]) {
          return false;
        }
      }
      
      return false; // Versions are equal
    } catch (e) {
      return false;
    }
  }

  /// Get the store URL for the current platform
  String getStoreUrl() {
    if (Platform.isIOS) {
      return _appStoreUrl;
    } else if (Platform.isAndroid) {
      return _playStoreUrl;
    }
    return '';
  }

  /// Get current app version
  Future<String> getCurrentVersion() async {
    return await _getCurrentVersion();
  }
}

