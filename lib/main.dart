import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize OneSignal with App ID (optional - game works without notifications)
  try {
    OneSignal.initialize("5daf5ca5-3ea8-486e-a1d2-da804c13c66c");
    
    // Request notification permissions (optional - game continues regardless)
    // Use catchError to ensure game doesn't crash if permission is denied
    OneSignal.Notifications.requestPermission(true).catchError((error) {
      print('OneSignal permission request failed (game continues normally): $error');
    });
    
    // Set up notification handlers (optional - game works without these)
    OneSignal.Notifications.addClickListener((event) {
      // Handle notification click - optional
      print('OneSignal notification clicked: ${event.notification.notificationId}');
    });
    
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Show the notification if permission was granted
      print('OneSignal notification received in foreground: ${event.notification.notificationId}');
      event.notification.display();
    });
  } catch (e) {
    // If OneSignal initialization fails, game continues normally
    print('OneSignal initialization failed (game continues normally): $e');
  }
  
  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Hide system UI for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
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
          child: child!,
        );
      },
    );
  }
}
