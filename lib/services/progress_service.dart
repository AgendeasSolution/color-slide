import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage game progress and level completion
class ProgressService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _currentLevelKey = 'current_level';
  
  static ProgressService? _instance;
  static ProgressService get instance => _instance ??= ProgressService._();
  
  ProgressService._();
  
  SharedPreferences? _prefs;
  
  /// Initialize the service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Get all completed levels
  Future<List<int>> getCompletedLevels() async {
    await init();
    final completedLevels = _prefs!.getStringList(_completedLevelsKey) ?? [];
    return completedLevels.map((e) => int.parse(e)).toList();
  }
  
  /// Check if a level is completed
  Future<bool> isLevelCompleted(int level) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level);
  }
  
  /// Mark a level as completed
  Future<void> completeLevel(int level) async {
    await init();
    final completedLevels = await getCompletedLevels();
    if (!completedLevels.contains(level)) {
      completedLevels.add(level);
      await _prefs!.setStringList(
        _completedLevelsKey, 
        completedLevels.map((e) => e.toString()).toList()
      );
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
    await init();
    await _prefs!.remove(_completedLevelsKey);
    await _prefs!.remove(_currentLevelKey);
  }
  
  /// Get current level (last played or 1)
  Future<int> getCurrentLevel() async {
    await init();
    return _prefs!.getInt(_currentLevelKey) ?? 1;
  }
  
  /// Set current level
  Future<void> setCurrentLevel(int level) async {
    await init();
    await _prefs!.setInt(_currentLevelKey, level);
  }
}
