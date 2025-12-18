import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Optimized service for managing sound effects and haptic feedback
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

  // Cache for audio sources to avoid repeated string allocations
  static const String _buttonTapSound = 'audio/mouse_click_5.mp3';
  static const String _swipeSound = 'audio/swipe_1.mp3';
  static const String _winSound = 'audio/win_2.mp3';
  static const String _failSound = 'audio/fail_3.mp3';

  /// Initialize the sound service
  Future<void> init() async {
    // Set release mode to stop for quick sounds - batch operations
    await Future.wait([
      _buttonTapPlayer.setReleaseMode(ReleaseMode.stop),
      _swipePlayer.setReleaseMode(ReleaseMode.stop),
      _winPlayer.setReleaseMode(ReleaseMode.stop),
      _failPlayer.setReleaseMode(ReleaseMode.stop),
    ]);
  }

  /// Reusable method to play sound with error handling
  Future<void> _playSound(AudioPlayer player, String source) async {
    if (!_isSoundEnabled) return;
    
    try {
      await player.stop();
      await player.play(AssetSource(source), volume: 1.0, mode: PlayerMode.lowLatency);
    } catch (e) {
      // If stop fails or player is already stopped, just play
      try {
        await player.play(AssetSource(source), volume: 1.0, mode: PlayerMode.lowLatency);
      } catch (_) {
        // Ignore errors silently
      }
    }
  }

  /// Play button tap sound (mouse_click_5.mp3)
  Future<void> playButtonTap() async {
    await _playSound(_buttonTapPlayer, _buttonTapSound);
  }

  /// Play swipe sound (swipe_1.mp3) - for color ball taps
  Future<void> playSwipe() async {
    await _playSound(_swipePlayer, _swipeSound);
  }

  /// Play win sound (win_2.mp3) - for puzzle solved
  Future<void> playWin() async {
    await _playSound(_winPlayer, _winSound);
  }

  /// Play fail sound (fail_3.mp3) - for game over, time's up, or losing
  Future<void> playFail() async {
    await _playSound(_failPlayer, _failSound);
  }

  /// Play level selection sound
  Future<void> playLevelSelect() async {
    await _playSound(_buttonTapPlayer, _buttonTapSound);
  }

  /// Play level completion sound
  Future<void> playLevelComplete() async {
    await _playSound(_winPlayer, _winSound);
  }

  /// Play error sound
  Future<void> playError() async {
    if (!_isSoundEnabled) return;
    
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Silently handle errors
    }
  }

  /// Play success sound
  Future<void> playSuccess() async {
    await _playSound(_winPlayer, _winSound);
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
      // Stop any playing sounds - batch operations
      Future.wait([
        _buttonTapPlayer.stop(),
        _swipePlayer.stop(),
        _winPlayer.stop(),
        _failPlayer.stop(),
      ]).catchError((_) {
        // Ignore errors when stopping
      });
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
