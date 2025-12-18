import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

/// Optimized service for checking internet connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  
  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  /// Returns true if connected, false otherwise
  Future<bool> hasInternetConnection() async {
    try {
      // First check network connectivity type
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // If no connectivity at all, return false immediately
      if (connectivityResults.isEmpty || 
          connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Even if connectivity shows as available, verify actual internet access
      // by attempting to reach a reliable server
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
        return false;
      } catch (e) {
        // If lookup fails, no internet
        return false;
      }
    } catch (e) {
      // If connectivity check fails, assume no internet
      return false;
    }
  }

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return [ConnectivityResult.none];
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

