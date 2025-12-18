import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to manage game progress and level completion
class ProgressService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _currentLevelKey = 'current_level';
  
  static final ProgressService _instance = ProgressService._();
  factory ProgressService() => _instance;
  
  ProgressService._();
  
  static ProgressService get instance => _instance;
  
  SharedPreferences? _prefs;
  
  /// Initialize the service
  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      // If SharedPreferences fails, create empty instance
      throw Exception('Failed to initialize progress service');
    }
  }
  
  /// Get all completed levels
  Future<List<int>> getCompletedLevels() async {
    try {
      await init();
      if (_prefs == null) return [];
      
      final completedLevels = _prefs!.getStringList(_completedLevelsKey) ?? [];
      final parsedLevels = <int>[];
      
      for (final level in completedLevels) {
        try {
          final parsed = int.tryParse(level);
          if (parsed != null && parsed > 0) {
            parsedLevels.add(parsed);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
      
      return parsedLevels;
    } catch (e) {
      return [];
    }
  }
  
  /// Check if a level is completed
  Future<bool> isLevelCompleted(int level) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level);
  }
  
  /// Mark a level as completed
  Future<void> completeLevel(int level) async {
    try {
      await init();
      if (_prefs == null) return;
      
      final completedLevels = await getCompletedLevels();
      if (!completedLevels.contains(level) && level > 0) {
        completedLevels.add(level);
        await _prefs!.setStringList(
          _completedLevelsKey, 
          completedLevels.map((e) => e.toString()).toList()
        );
      }
    } catch (e) {
      // Silently handle completion error
    }
  }
  
  /// Get the highest unlocked level
  Future<int> getHighestUnlockedLevel() async {
    final completedLevels = await getCompletedLevels();
    if (completedLevels.isEmpty) return 1; // Level 1 is always unlocked
    return completedLevels.length + 1;
  }
  
  /// Check if a level is unlocked
  Future<bool> isLevelUnlocked(int level) async {
    if (level == 1) return true; // Level 1 is always unlocked
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level - 1);
  }
  
  /// Reset all progress (for testing or new game)
  Future<void> resetProgress() async {
    try {
      await init();
      if (_prefs == null) return;
      
      await _prefs!.remove(_completedLevelsKey);
      await _prefs!.remove(_currentLevelKey);
    } catch (e) {
      // Silently handle reset error
    }
  }
  
  /// Get current level (last played or 1)
  Future<int> getCurrentLevel() async {
    try {
      await init();
      if (_prefs == null) return 1;
      
      final level = _prefs!.getInt(_currentLevelKey);
      return (level != null && level > 0) ? level : 1;
    } catch (e) {
      return 1;
    }
  }
  
  /// Set current level
  Future<void> setCurrentLevel(int level) async {
    try {
      await init();
      if (_prefs == null || level < 1) return;
      
      await _prefs!.setInt(_currentLevelKey, level);
    } catch (e) {
      // Silently handle set level error
    }
  }
}
