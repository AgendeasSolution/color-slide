import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../constants/game_constants.dart';

/// Empty cell widget for the game board
class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Colors.white.withOpacity(0.2),
      strokeWidth: 2,
      dashPattern: const [6, 4],
      borderType: BorderType.RRect,
      radius: const Radius.circular(GameConstants.borderRadius),
      child: Container(),
    );
  }
}
