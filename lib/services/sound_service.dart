import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for managing sound effects and haptic feedback
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static SoundService get instance => _instance;

  bool _isSoundEnabled = true;
  bool _isHapticEnabled = true;
  
  // Separate audio players for each sound type to allow simultaneous/rapid playback
  final AudioPlayer _buttonTapPlayer = AudioPlayer();
  final AudioPlayer _swipePlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  final AudioPlayer _failPlayer = AudioPlayer();

  /// Initialize the sound service
  Future<void> init() async {
    // Set release mode to stop for quick sounds
    await _buttonTapPlayer.setReleaseMode(ReleaseMode.stop);
    await _swipePlayer.setReleaseMode(ReleaseMode.stop);
    await _winPlayer.setReleaseMode(ReleaseMode.stop);
    await _failPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Play button tap sound (mouse_click_5.mp3)
  Future<void> playButtonTap() async {
    if (!_isSoundEnabled) return;
    
    try {
      // Stop current playback and reset to beginning for reliable replay
      await _buttonTapPlayer.stop();
      await _buttonTapPlayer.play(AssetSource('audio/mouse_click_5.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      // If stop fails or player is already stopped, just play
      try {
        await _buttonTapPlayer.play(AssetSource('audio/mouse_click_5.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
    }
  }

  /// Play swipe sound (swipe_1.mp3) - for color ball taps
  Future<void> playSwipe() async {
    if (!_isSoundEnabled) return;
    
    try {
      // Stop current playback and reset to beginning for reliable replay
      await _swipePlayer.stop();
      await _swipePlayer.play(AssetSource('audio/swipe_1.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      // If stop fails or player is already stopped, just play
      try {
        await _swipePlayer.play(AssetSource('audio/swipe_1.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
    }
  }

  /// Play win sound (win_2.mp3) - for puzzle solved
  Future<void> playWin() async {
    if (!_isSoundEnabled) return;
    
    try {
      // Stop current playback and reset to beginning for reliable replay
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      // If stop fails or player is already stopped, just play
      try {
        await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
    }
  }

  /// Play fail sound (fail_3.mp3) - for game over, time's up, or losing
  Future<void> playFail() async {
    if (!_isSoundEnabled) {
      return;
    }
    
    try {
      // Stop current playback and reset to beginning for reliable replay
      await _failPlayer.stop();
      await _failPlayer.play(AssetSource('audio/fail_3.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      // If stop fails or player is already stopped, just play
      try {
        await _failPlayer.play(AssetSource('audio/fail_3.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (error) {
        // Ignore errors
      }
    }
  }

  /// Play level selection sound
  Future<void> playLevelSelect() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _buttonTapPlayer.stop();
      await _buttonTapPlayer.play(AssetSource('audio/mouse_click_5.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      try {
        await _buttonTapPlayer.play(AssetSource('audio/mouse_click_5.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
    }
  }

  /// Play level completion sound
  Future<void> playLevelComplete() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      try {
        await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
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
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      try {
        await _winPlayer.play(AssetSource('audio/win_2.mp3'), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors
      }
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
      _buttonTapPlayer.stop();
      _swipePlayer.stop();
      _winPlayer.stop();
      _failPlayer.stop();
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
    _buttonTapPlayer.dispose();
    _swipePlayer.dispose();
    _winPlayer.dispose();
    _failPlayer.dispose();
  }
}
