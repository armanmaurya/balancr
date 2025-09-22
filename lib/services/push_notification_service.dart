import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

// Top-level background handler must be a global function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolates.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print('Background message received: ${message.messageId}');
    // Handle the background message here
  } catch (e) {
    print('Background handler error: $e');
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      // Request permissions (required on iOS, recommended on Android 13+)
      await _requestPermission();
    } catch (e) {
      print('FCM permission request failed: $e');
    }

    try {
      // Get and log FCM token (you may send to backend)
      final token = await _messaging.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('FCM getToken failed: $e');
    }

    try {
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        // TODO: Send to backend if needed
      });

      // Foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('FCM Foreground message: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        // TODO: Show in-app notification or handle data
      });

      // App opened from terminated state via notification
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageNavigation(initialMessage);
      }

      // App opened from background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
    } catch (e) {
      print('FCM listener setup failed: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Permission granted: ${settings.authorizationStatus}');
  }

  void _handleMessageNavigation(RemoteMessage message) {
    print('Handling message navigation: ${message.messageId}');
    print('Data: ${message.data}');
    
    // TODO: Implement navigation logic based on message.data
    // Example:
    // final type = message.data['type'];
    // final id = message.data['id'];
    // if (type == 'transaction') {
    //   // Navigate to transaction details
    // } else if (type == 'contact') {
    //   // Navigate to contact details
    // }
  }
}