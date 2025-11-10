import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fgtp_app_model.dart';

/// Exception for no internet connection
class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

/// Service for fetching games from FGTP Labs API with caching
class FgtpGamesService {
  static const String _apiUrl = 'https://api.freegametoplay.com/apps';
  static const String _currentGameName = 'Color Slide';

  /// Fetch mobile games from the API
  /// Returns list of games excluding the current game
  Future<List<FgtpApp>> fetchMobileGames({bool forceRefresh = false}) async {
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
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final gamesResponse = jsonData['data'] as List<dynamic>;

        // Convert to FgtpApp and filter out current game
        final games = gamesResponse
            .map((item) => FgtpApp.fromJson(item as Map<String, dynamic>))
            .where((app) => app.name != _currentGameName)
            .toList();

        return games;
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

