/// Model for FGTP Labs game data from API
class FgtpGame {
  final String name;
  final String image;
  final String playstoreUrl;
  final String appstoreUrl;

  FgtpGame({
    required this.name,
    required this.image,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  factory FgtpGame.fromJson(Map<String, dynamic> json) {
    return FgtpGame(
      name: json['name'] as String,
      image: json['image'] as String,
      playstoreUrl: json['playstore_url'] as String,
      appstoreUrl: json['appstore_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
    };
  }
}

/// API response model
class FgtpGamesResponse {
  final bool success;
  final int count;
  final List<FgtpGame> data;

  FgtpGamesResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory FgtpGamesResponse.fromJson(Map<String, dynamic> json) {
    return FgtpGamesResponse(
      success: json['success'] as bool,
      count: json['count'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => FgtpGame.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

