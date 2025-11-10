import '../services/sound_service.dart';

/// Audio service wrapper for consistent API
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  /// Play mouse click sound
  Future<void> playMouseClickSound() async {
    await SoundService.instance.playButtonTap();
  }
}

