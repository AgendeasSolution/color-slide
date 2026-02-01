import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../services/sound_service.dart';

/// Game header widget with exit button, level name, and reset button
class GameHeader extends StatelessWidget {
  final int currentLevel;
  final VoidCallback onReset;
  final VoidCallback onExit;

  const GameHeader({
    super.key,
    required this.currentLevel,
    required this.onReset,
    required this.onExit,
  });

  void _handleExit() {
    SoundService.instance.playButtonTap();
    onExit();
  }

  void _handleReset() {
    SoundService.instance.playButtonTap();
    onReset();
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getButtonHeight(context) * 0.88;
    final iconSize = ResponsiveHelper.getIconSize(context, 22);
    final fontSize = ResponsiveHelper.getFontSize(context, 26);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);

    Widget _buildIconButton({
      required VoidCallback onTap,
      required IconData icon,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: buttonHeight,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: AppColors.bgCard.withOpacity(0.9),
              border: Border.all(color: AppColors.gameAccent, width: 1.5),
            ),
            child: Icon(icon, size: iconSize, color: AppColors.gameAccent),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconButton(onTap: _handleExit, icon: Icons.arrow_back),
        Expanded(
          child: Center(
            child: Text(
              "Level $currentLevel",
              style: GoogleFonts.rajdhani(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        _buildIconButton(onTap: _handleReset, icon: Icons.refresh),
      ],
    );
  }
}
