import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'screens/splash_screen.dart';
import 'utils/error_handler.dart';

/// Optimized app initialization with centralized error handling
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services in parallel with error handling
  await _initializeServices();
  
  // Configure system UI
  await _configureSystemUI();
  
  runApp(const ColorSlideGame());
}

/// Initialize all app services with error handling
Future<void> _initializeServices() async {
  await ErrorHandler.safeExecuteAll([
    () => Firebase.initializeApp(),
    () => MobileAds.instance.initialize(),
    () => _initializeOneSignal(),
  ]);
}

/// Initialize OneSignal with comprehensive error handling
Future<void> _initializeOneSignal() async {
  await ErrorHandler.safeExecute(() async {
    OneSignal.initialize("5daf5ca5-3ea8-486e-a1d2-da804c13c66c");
    
    // Request notification permissions
    OneSignal.Notifications.requestPermission(true).catchError((_) {
      // Game continues normally if permission request fails
      return false;
    });
    
    // Set up notification handlers
    await ErrorHandler.silentExecute(() async {
      OneSignal.Notifications.addClickListener((_) {
        // Handle notification click - optional
      });
      
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        ErrorHandler.silentExecuteSync(() {
          event.notification.display();
        });
      });
    });
  });
}

/// Configure system UI preferences
Future<void> _configureSystemUI() async {
  await ErrorHandler.safeExecute(() => SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]));
  
  ErrorHandler.silentExecuteSync(() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  });
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
        // Fallback to platform emoji font when Inter has no glyph (e.g. 🍪🍩🍡)
        textTheme: ThemeData().textTheme.apply(
          fontFamily: 'Inter',
          fontFamilyFallback: const ['Apple Color Emoji', 'Noto Color Emoji', 'NotoColorEmoji'],
        ),
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
