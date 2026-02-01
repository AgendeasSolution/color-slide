/// Tile image assets for game cells and indicators.
/// Order: cookie, dango, donut, cherries, lollipop, cupcake, strawberry, chocolate, candy, pineapple, grapes.
class TileImageConstants {
  static const String _base = 'assets/img';

  static const List<String> allTileImages = [
    '$_base/cookie.png',
    '$_base/dango.png',
    '$_base/donut.png',
    '$_base/cherries.png',
    '$_base/lollipop.png',
    '$_base/cupcake.png',
    '$_base/strawberry.png',
    '$_base/chocolate.png',
    '$_base/candy.png',
    '$_base/pineapple.png',
    '$_base/grapes.png',
  ];

  /// Returns the image asset path for a color at the given index (0-based).
  static String imageForColorIndex(int index) {
    if (index < 0 || index >= allTileImages.length) return allTileImages[0];
    return allTileImages[index];
  }
}
