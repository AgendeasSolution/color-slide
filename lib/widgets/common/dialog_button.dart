import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../services/sound_service.dart';

/// Reusable dialog button widget
class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  void _handlePressed() {
    SoundService.instance.playButtonTap();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.getSpacing(context, 24),
      vertical: ResponsiveHelper.getSpacing(context, 15),
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);
    final fontSize = ResponsiveHelper.getFontSize(context, 14);
    
    return ElevatedButton(
      onPressed: _handlePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.textMuted : AppColors.primary,
        foregroundColor: AppColors.bgDark,
        padding: buttonPadding,
        minimumSize: Size(0, ResponsiveHelper.getButtonHeight(context)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: 0.3,
        ),
      ),
      child: Center(
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
