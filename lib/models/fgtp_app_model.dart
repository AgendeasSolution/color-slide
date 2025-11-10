import 'package:flutter/material.dart';

/// Model for FGTP Labs app/game data from API
class FgtpApp {
  final String name;
  final String imageUrl;
  final String playstoreUrl;
  final String appstoreUrl;

  FgtpApp({
    required this.name,
    required this.imageUrl,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  factory FgtpApp.fromJson(Map<String, dynamic> json) {
    return FgtpApp(
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      playstoreUrl: json['playstore_url'] as String,
      appstoreUrl: json['appstore_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': imageUrl,
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
    };
  }

  /// Get primary store URL based on platform
  String? primaryStoreUrl(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return appstoreUrl.isNotEmpty ? appstoreUrl : null;
      case TargetPlatform.android:
        return playstoreUrl.isNotEmpty ? playstoreUrl : null;
      default:
        return playstoreUrl.isNotEmpty ? playstoreUrl : appstoreUrl;
    }
  }

  /// Get all available store URLs
  List<String> get availableStoreUrls {
    final urls = <String>[];
    if (playstoreUrl.isNotEmpty) urls.add(playstoreUrl);
    if (appstoreUrl.isNotEmpty) urls.add(appstoreUrl);
    return urls;
  }
}

