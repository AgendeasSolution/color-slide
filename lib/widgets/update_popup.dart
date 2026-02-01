import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../services/sound_service.dart';
import '../services/update_service.dart';
import 'dart:io';

/// Update pop-up widget that appears at the bottom of the screen
class UpdatePopup extends StatefulWidget {
  final VoidCallback? onDismiss;

  const UpdatePopup({
    super.key,
    this.onDismiss,
  });

  @override
  State<UpdatePopup> createState() => _UpdatePopupState();
}

class _UpdatePopupState extends State<UpdatePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    
    try {
      final updateService = UpdateService();
      final storeUrl = updateService.getStoreUrl();
      
      if (storeUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(storeUrl);
          canLaunchUrl(uri).then((canLaunch) {
            if (canLaunch && mounted) {
              launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              ).catchError((error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to open store. Please try again.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              });
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to open store. Please try again.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }).catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to open store. Please try again.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open store. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open store. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleDismiss() {
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    _slideController.reverse().then((_) {
      if (mounted && widget.onDismiss != null) {
        widget.onDismiss!();
      }
    }).catchError((error) {
      if (mounted && widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgCard,
              AppColors.bgCardHover,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context, 20),
              vertical: ResponsiveHelper.getSpacing(context, 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Heading
                    Expanded(
                      child: Text(
                        'Update Available!',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 24),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Close Button
                    GestureDetector(
                      onTap: _handleDismiss,
                      child: Container(
                        width: ResponsiveHelper.getIconSize(context, 32),
                        height: ResponsiveHelper.getIconSize(context, 32),
                        decoration: BoxDecoration(
                          color: AppColors.bgCardHover.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textMuted.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
                
                // Image and Description Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      width: ResponsiveHelper.getSpacing(context, 80),
                      height: ResponsiveHelper.getSpacing(context, 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context, 12),
                        ),
                        child: Image.asset(
                          'assets/img/color-slide.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.3),
                                    AppColors.secondary.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.update,
                                color: AppColors.textPrimary,
                                size: ResponsiveHelper.getIconSize(context, 40),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.getSpacing(context, 16)),
                    
                    // Description
                    Expanded(
                      child: Text(
                        'A new version of Color Slide is available with exciting features, bug fixes, and performance improvements. Update now to enjoy the best experience!',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: AppColors.textSecondary,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context, 20)),
                
                // Buttons Row
                Row(
                  children: [
                    // Update Button
                    Expanded(
                      child: Container(
                        height: ResponsiveHelper.getButtonHeight(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getBorderRadius(context, 12),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryHover,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleUpdate,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context, 12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Platform.isIOS
                                        ? Icons.apple
                                        : Icons.android,
                                    color: Colors.white,
                                    size: ResponsiveHelper.getIconSize(context, 20),
                                  ),
                                  SizedBox(
                                    width: ResponsiveHelper.getSpacing(context, 8),
                                  ),
                                  Text(
                                    'Update Now',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getFontSize(
                                          context, 16),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.6),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                    
                    // Later Button
                    Container(
                      height: ResponsiveHelper.getButtonHeight(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context, 20),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.textMuted.withOpacity(0.5),
                          width: 1.5,
                        ),
                        color: AppColors.bgCardHover.withOpacity(0.3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleDismiss,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getBorderRadius(context, 12),
                          ),
                          child: Center(
                            child: Text(
                              'Later',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                    context, 14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

