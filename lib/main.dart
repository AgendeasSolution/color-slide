import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Game continues normally if Firebase fails
  }
  
  // Initialize OneSignal with App ID (optional - game works without notifications)
  try {
    OneSignal.initialize("5daf5ca5-3ea8-486e-a1d2-da804c13c66c");
    
    // Request notification permissions (optional - game continues regardless)
    // Use catchError to ensure game doesn't crash if permission is denied
    OneSignal.Notifications.requestPermission(true).catchError((error) {
      // Game continues normally if permission request fails
    });
    
      // Set up notification handlers (optional - game works without these)
      try {
        OneSignal.Notifications.addClickListener((event) {
          // Handle notification click - optional
        });
        
        // Handle notification received while app is in foreground
        OneSignal.Notifications.addForegroundWillDisplayListener((event) {
          // Show the notification if permission was granted
          try {
            event.notification.display();
          } catch (e) {
            // Silently handle display error
          }
        });
      } catch (e) {
        // Silently handle listener setup error
      }
    } catch (e) {
      // If OneSignal initialization fails, game continues normally
    }
  
  // Initialize Google Mobile Ads SDK with error handling
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    // Game continues normally if MobileAds fails
  }
  
  // Set preferred orientations with error handling
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    // Silently handle orientation error
  }
  
  // Hide system UI for immersive experience with error handling
  try {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (e) {
    // Silently handle system UI error
  }
  
  runApp(const ColorSlideGame());
}

class ColorSlideGame extends StatelessWidget {
  const ColorSlideGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Slide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      // Optimize for faster startup
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
