import 'package:flutter/services.dart';

/// Service for managing sound effects and haptic feedback
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static SoundService get instance => _instance;

  bool _isSoundEnabled = true;
  bool _isHapticEnabled = true;

  /// Initialize the sound service
  Future<void> init() async {
    // Initialize sound service
  }

  /// Play button tap sound
  Future<void> playButtonTap() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Play level selection sound
  Future<void> playLevelSelect() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Play level completion sound
  Future<void> playLevelComplete() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Play error sound
  Future<void> playError() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isSoundEnabled) return;
    // Background music would be implemented with actual audio files
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    // Stop background music
  }

  /// Haptic feedback for button taps
  Future<void> hapticButtonTap() async {
    if (!_isHapticEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Haptic feedback for level selection
  Future<void> hapticLevelSelect() async {
    if (!_isHapticEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Haptic feedback for level completion
  Future<void> hapticLevelComplete() async {
    if (!_isHapticEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Haptic feedback for errors
  Future<void> hapticError() async {
    if (!_isHapticEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Toggle sound on/off
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    if (!_isSoundEnabled) {
      // Stop any playing sounds
    }
  }

  /// Toggle haptic feedback on/off
  void toggleHaptic() {
    _isHapticEnabled = !_isHapticEnabled;
  }

  /// Get sound enabled state
  bool get isSoundEnabled => _isSoundEnabled;

  /// Get haptic enabled state
  bool get isHapticEnabled => _isHapticEnabled;

  /// Dispose resources
  void dispose() {
    // Clean up resources
  }
}
