import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/tile_image_constants.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../models/level.dart';

/// Tile image indicators – first N images per level (N = number of columns).
class ColorIndicators extends StatelessWidget {
  final Level config;

  const ColorIndicators({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorHeight = ResponsiveHelper.getSpacing(context, GameConstants.emojiIndicatorHeight);
    final padding = ResponsiveHelper.getSpacing(context, 4);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, 6);
    final cellWidth = ResponsiveHelper.getCellWidth(context, config);
    final gridSpacing = ResponsiveHelper.getGridSpacing(context);

    final imagePaths = List.generate(
      config.colors.length,
      (i) => TileImageConstants.imageForColorIndex(i),
    );

    final totalWidth = (cellWidth * config.colors.length) + (gridSpacing * (config.colors.length - 1));

    return Center(
      child: SizedBox(
        width: totalWidth,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < imagePaths.length; i++) ...[
              if (i > 0) SizedBox(width: gridSpacing),
              SizedBox(
                width: cellWidth,
                child: Container(
                  height: indicatorHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x99303C37),
                        Color(0xCC0F1623),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: AppColors.gameAccentDim, width: 1),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Image.asset(
                        imagePaths[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
