import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fgtp_game.dart';

/// Service for fetching games from FGTP Labs API
class GamesApiService {
  static const String _apiUrl = 'https://api.freegametoplay.com/apps';
  static const String _currentGameName = 'Color Slide';

  /// Fetch all games from the API
  /// Returns list of games excluding the current game
  static Future<List<FgtpGame>> fetchGames() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final gamesResponse = FgtpGamesResponse.fromJson(jsonData);

        // Filter out the current game
        return gamesResponse.data
            .where((game) => game.name != _currentGameName)
            .toList();
      } else {
        throw Exception('Failed to load games: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list on error to prevent app crash
      return [];
    }
  }
}

