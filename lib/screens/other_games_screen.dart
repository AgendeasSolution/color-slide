import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/common/animated_background.dart';
import '../components/common/banner_ad_widget.dart';
import '../constants/app_constants.dart';
import '../models/fgtp_app_model.dart';
import '../services/audio_service.dart';
import '../services/fgtp_games_service.dart' show FgtpGamesService, NoInternetException;
import '../services/connectivity_service.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_utils.dart';
import '../utils/responsive_helper.dart';
import '../constants/game_constants.dart';

/// Screen to showcase other FGTP Labs games.
class OtherGamesScreen extends StatefulWidget {
  const OtherGamesScreen({super.key});
  @override
  State<OtherGamesScreen> createState() => _OtherGamesScreenState();
}

class _OtherGamesScreenState extends State<OtherGamesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AudioService _audioService;
  late final FgtpGamesService _gamesService;
  final ConnectivityService _connectivityService = ConnectivityService();
  List<FgtpApp> _games = const [];
  List<FgtpApp>? _cachedGames;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _showingCachedData = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration:
          Duration(seconds: AppConstants.backgroundAnimationDuration),
    )..repeat();
    _audioService = AudioService.instance;
    _gamesService = FgtpGamesService();
    _loadGames();
  }
  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }
  Future<void> _loadGames({bool forceRefresh = false}) async {
    setState(() {
      if (!_isLoading) {
        _isLoading = true;
      }
      _errorMessage = null;
      _isOffline = false;
      if (forceRefresh) {
        _showingCachedData = false;
      }
    });
    try {
      final games = await _gamesService.fetchMobileGames(
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _games = games;
        _cachedGames = games;
        _isLoading = false;
        _showingCachedData = false;
        _isOffline = false;
        _errorMessage = null;
      });
    } on NoInternetException {
      if (!mounted) {
        return;
      }
      if ((_cachedGames ?? const []).isNotEmpty) {
        setState(() {
          _games = _cachedGames!;
          _isLoading = false;
          _isOffline = true;
          _showingCachedData = true;
          _errorMessage =
              'No internet connection. Showing the last available games.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _isOffline = true;
          _showingCachedData = false;
          _errorMessage = 'No internet connection. Please try again.';
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      if ((_cachedGames ?? const []).isNotEmpty) {
        setState(() {
          _games = _cachedGames!;
          _isLoading = false;
          _showingCachedData = true;
          _errorMessage =
              'We had trouble loading new games. Showing cached data.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _showingCachedData = false;
          _errorMessage = 'Unable to load games right now. Please retry.';
        });
      }
    }
  }
  Future<void> _openStore(FgtpApp app) async {
    _audioService.playMouseClickSound();
    
    // Check internet connectivity before attempting to open store URL
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your network and try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    try {
      final platform = Theme.of(context).platform;
      final primaryUrl = app.primaryStoreUrl(platform);
      final urls = [
        if (primaryUrl != null) primaryUrl,
        ...app.availableStoreUrls.where((url) => url != primaryUrl),
      ].map(Uri.parse);
      
      for (final uri in urls) {
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to open store. Please try again.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
            return;
          }
        } catch (e) {
          // Continue to next URL if this one fails
          continue;
        }
      }
      
      // If we get here, none of the URLs could be launched
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open store. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open store. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          AnimatedBackground(controller: _bgController),
          SafeArea(
            child: Stack(
              children: [
                Column(  
                  children: [
                    _buildHeader(context),
                    if (_showingCachedData) _buildCachedBanner(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildContent(),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BannerAdWidget(
                    onAdLoaded: null,
                    onAdFailedToLoad: null,
                    onAdClicked: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getButtonHeight(context);
    final iconSize = ResponsiveHelper.getIconSize(context, 18);
    final buttonPadding = ResponsiveHelper.getSpacing(context, 8);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final titleStyle = ResponsiveUtils.getResponsiveTextStyle(
      context,
      baseFontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      letterSpacing: 1.1,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, ResponsiveHelper.getSpacing(context, 12)),
      child: Row(
            children: [
          ElevatedButton(
            onPressed: () {
              AudioService.instance.playMouseClickSound();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary.withOpacity(0.1),
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.all(buttonPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              minimumSize: Size(buttonHeight, buttonHeight),
            ),
            child: Icon(Icons.arrow_back, size: iconSize),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context, 16)),
          Expanded(
            child: Text(
              'FGTP Labs',
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: buttonHeight),
        ],
      ),
    );
  }
  Widget _buildCachedBanner() {
    final bannerColor = _isOffline
        ? AppColors.accent.withOpacity(0.2)
        : AppColors.secondary.withOpacity(0.2);
    final borderColor = _isOffline
        ? AppColors.accent.withOpacity(0.4)
        : AppColors.secondary.withOpacity(0.4);
    final textColor = _isOffline ? AppColors.accent : AppColors.secondary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
                ),
                child: Row(
        children: [
          Icon(
            _isOffline ? Icons.wifi_off : Icons.cloud_download,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? 'Showing cached data',
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!_isLoading)
            TextButton(
              onPressed: () => _loadGames(forceRefresh: true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    if (_errorMessage != null && !_showingCachedData) {
      return _buildErrorState();
    }
    if (_games.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadGames(forceRefresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final crossAxisCount = _getCrossAxisCount(maxWidth);
          final horizontalSpacing = ResponsiveUtils.getResponsiveSpacing(
            context,
            16,
          );
          final verticalSpacing = ResponsiveUtils.getResponsiveSpacing(
            context,
            14,
          );
          final totalHorizontalSpacing =
              horizontalSpacing * (crossAxisCount - 1);
          final cardWidth = (maxWidth - totalHorizontalSpacing) / crossAxisCount;
          final aspectRatio = _calculateCardAspectRatio(context, cardWidth);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 120),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: horizontalSpacing,
              mainAxisSpacing: verticalSpacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _games.length,
            itemBuilder: (context, index) {
              final app = _games[index];
              return _GameCard(
                app: app,
                onTap: () => _openStore(app),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            Icon(
              _isOffline ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: _isOffline ? AppColors.accent : AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong.',
              style: ResponsiveUtils.getResponsiveTextStyle(
                context,
                baseFontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadGames(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'More games coming soon!',
        style: ResponsiveUtils.getResponsiveTextStyle(
          context,
          baseFontSize: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth > 1000) {
      return 4;
    }
    if (maxWidth > 720) {
      return 3;
    }
    return 2;
  }
  double _calculateCardAspectRatio(BuildContext context, double cardWidth) {
    final cardPadding = ResponsiveUtils.getResponsiveSpacing(context, 4);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 6);
    final buttonHeight = ResponsiveUtils.getResponsiveSpacing(context, 36);
    final textStyle = ResponsiveUtils.getResponsiveTextStyle(
      context,
      baseFontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
    final fontSize = textStyle.fontSize ?? 16;
    final lineHeight = (textStyle.height ?? 1) * fontSize;
    final textHeight = lineHeight * 2;
    // Account for doubled spacing (spacing * 2) above and below text = spacing * 4 total
    final totalHeight = ((cardPadding * 2) +
            cardWidth +
            (spacing * 2) +
            buttonHeight +
            textHeight)
        .clamp(1, double.infinity);
    return cardWidth / totalHeight;
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.app, required this.onTap});
  final FgtpApp app;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cardPadding = ResponsiveUtils.getResponsiveSpacing(context, 10);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 6);
    final buttonHeight = ResponsiveUtils.getResponsiveSpacing(context, 36);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 24)),
        gradient: LinearGradient(
          colors: [
            AppColors.bgCard.withOpacity(0.1),
            AppColors.bgCardHover.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(
                    context,
                    14,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.surfaceGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: app.imageUrl.isNotEmpty
                      ? Image.network(
                          app.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _PlaceholderArtwork(name: app.name),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            );
                          },
                        )
                      : _PlaceholderArtwork(name: app.name),
                            ),
                          ),
                        ),
            SizedBox(height: spacing * 2),
            Text(
              app.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ResponsiveUtils.getResponsiveTextStyle(
                context,
                baseFontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: spacing * 2),
            SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 10),
                    ),
                  ),
                ).copyWith(
                  elevation: ButtonStyleButton.allOrNull(0.0),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) => states.contains(MaterialState.pressed)
                        ? AppColors.white.withOpacity(0.12)
                        : null,
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.buttonGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 10),
                    ),
                    boxShadow: ResponsiveUtils.getResponsiveBoxShadow(
                      context,
                      color: AppColors.accent.withOpacity(0.25),
                      baseBlurRadius: 12,
                      baseSpreadRadius: 0,
                      baseOffset: const Offset(0, 6),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow, size: 20, color: AppColors.white),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(context, 6),
                        ),
                        Text(
                          'Play Now',
                          style: ResponsiveUtils.getResponsiveTextStyle(
                            context,
                            baseFontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}

class _PlaceholderArtwork extends StatelessWidget {
  const _PlaceholderArtwork({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ResponsiveUtils.getResponsiveTextStyle(
            context,
            baseFontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.white.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}
