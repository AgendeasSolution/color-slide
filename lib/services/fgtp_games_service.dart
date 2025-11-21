import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/fgtp_app_model.dart';
import 'connectivity_service.dart';

/// Exception for no internet connection
class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

/// Service for fetching games from FGTP Labs API with caching
class FgtpGamesService {
  static const String _apiUrl = 'https://api.freegametoplay.com/apps';
  static const String _currentGameName = 'Color Slide';
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Fetch mobile games from the API
  /// Returns list of games excluding the current game
  Future<List<FgtpApp>> fetchMobileGames({bool forceRefresh = false}) async {
    // Check internet connectivity before making API call
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) {
      throw NoInternetException('No internet connection. Please check your network and try again.');
    }

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw NoInternetException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          
          // Validate JSON structure
          if (jsonData is! Map<String, dynamic>) {
            throw Exception('Invalid response format: expected Map');
          }
          
          final gamesResponse = jsonData['data'];
          if (gamesResponse is! List) {
            throw Exception('Invalid response format: data is not a list');
          }

          // Convert to FgtpApp and filter out current game with error handling
          final games = <FgtpApp>[];
          for (final item in gamesResponse) {
            try {
              if (item is Map<String, dynamic>) {
                final app = FgtpApp.fromJson(item);
                if (app.name != _currentGameName) {
                  games.add(app);
                }
              }
            } catch (e) {
              // Continue with next item
            }
          }

          return games;
        } catch (e) {
          throw Exception('Failed to parse games data: $e');
        }
      } else {
        throw Exception('Failed to load games: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NoInternetException('No internet connection: ${e.message}');
    } catch (e) {
      if (e is NoInternetException) {
        rethrow;
      }
      throw Exception('Failed to load games: $e');
    }
  }
}

