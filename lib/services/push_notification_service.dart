import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../features/notification/domain/entities/fcm_token_entity.dart';
import '../features/notification/domain/entities/notification_entity.dart';
import '../features/notification/domain/repositories/notification_repository.dart';
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
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    
    // Note: We can't access user context or repository in background isolate
    // User-specific operations will be handled when the app is opened
    // For now, just log the received message
    
    // TODO: If needed, you could store the message locally using shared_preferences
    // or a local database for processing when the app becomes active
    
  } catch (e) {
    print('Background handler error: $e');
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationRepository? _notificationRepository;
  String? _currentUserId;

  Future<void> initialize({
    NotificationRepository? notificationRepository,
    String? userId,
  }) async {
    _notificationRepository = notificationRepository;
    _currentUserId = userId;

    // Initialize local notifications
    await _initializeLocalNotifications();

    try {
      // Request permissions (required on iOS, recommended on Android 13+)
      await _requestPermission();
    } catch (e) {
      print('FCM permission request failed: $e');
    }

    try {
      // Get and save FCM token to backend
      final token = await _messaging.getToken();
      print('FCM Token: $token');

      print('Saving FCM token to backend for user: $_currentUserId');
      if (token != null &&
          _notificationRepository != null &&
          _currentUserId != null) {
        await _saveFCMTokenToBackend(token);
      }
    } catch (e) {
      print('FCM getToken failed: $e');
    }

    try {
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        if (_notificationRepository != null && _currentUserId != null) {
          _saveFCMTokenToBackend(newToken);
        }
      });

      // Foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('FCM Foreground message: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');

        // Sync notification with backend if repository is available
        if (_notificationRepository != null && _currentUserId != null) {
          _syncNotificationWithBackend(message);
        }

        // Show local notification when app is in foreground
        _showLocalNotification(message);
      });

      // App opened from terminated state via notification
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
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

    // Extract navigation data from the message
    final type = message.data['type'];
    final relatedId = message.data['relatedId'];
    final notificationId = message.data['notificationId'];

    // Mark notification as read if we have the notification ID
    if (notificationId != null) {
      markNotificationAsRead(notificationId);
    }

    // Handle navigation based on notification type
    _navigateBasedOnNotificationType(type, relatedId, message.data);
  }

  /// Navigate to appropriate screen based on notification type
  void _navigateBasedOnNotificationType(
    String? type,
    String? relatedId,
    Map<String, dynamic> data,
  ) {
    if (type == null) return;

    switch (type) {
      case 'transaction':
        if (relatedId != null) {
          // Navigate to transaction details
          print('Navigate to transaction: $relatedId');
          // TODO: Implement navigation using GoRouter or Navigator
          // context.go('/transaction/$relatedId');
        }
        break;
      case 'contact':
        if (relatedId != null) {
          // Navigate to contact details
          print('Navigate to contact: $relatedId');
          // TODO: Implement navigation
          // context.go('/contact/$relatedId');
        }
        break;
      case 'group':
        if (relatedId != null) {
          // Navigate to group details
          print('Navigate to group: $relatedId');
          // TODO: Implement navigation
          // context.go('/group/$relatedId');
        }
        break;
      case 'reminder':
        // Navigate to reminders or specific reminder
        print('Navigate to reminder: $relatedId');
        // TODO: Implement navigation
        break;
      case 'system':
        // Navigate to settings or notifications
        print('Navigate to system notification');
        // TODO: Implement navigation
        // context.go('/notifications');
        break;
      default:
        // Default navigation - go to notifications list
        print('Navigate to notifications list');
        // TODO: Implement navigation
        // context.go('/notifications');
        break;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    // Android notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS notification settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');

    if (response.payload != null) {
      try {
        // The payload contains the original FCM message data as string
        // Parse it to get navigation information
        print('Payload received: ${response.payload}');

        // Try to extract basic navigation info from the payload
        // This is a simplified approach - you might want to use JSON parsing
        // if you're storing structured data in the payload

        // For now, we'll handle basic navigation
        print('Handling local notification tap navigation');
        // TODO: Implement proper payload parsing and navigation
        // You might want to use a global navigator key or navigation service here
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel', // channel id
          'High Importance Notifications', // channel name
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.messageId.hashCode, // notification id
      message.notification?.title ?? 'Balancr',
      message.notification?.body ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: message.data.toString(), // pass data as payload
    );
  }

  /// Save FCM token to backend
  Future<void> _saveFCMTokenToBackend(String token) async {
    try {
      if (_notificationRepository == null || _currentUserId == null) return;

      final fcmToken = FCMTokenEntity(
        token: token,
        platform: _getCurrentPlatform(),
        createdAt: DateTime.now(),
        deviceId: await _getDeviceId(),
      );

      await _notificationRepository!.saveFCMToken(_currentUserId!, fcmToken);
      print('FCM token saved to backend successfully');
    } catch (e) {
      print('Failed to save FCM token to backend: $e');
    }
  }

  /// Sync received FCM notification with backend
  Future<void> _syncNotificationWithBackend(RemoteMessage message) async {
    try {
      if (_notificationRepository == null || _currentUserId == null) return;

      // Note: This method would typically be called when notifications are created
      // server-side. Since we're receiving FCM messages, we might not need to create
      // the notification in backend here as it should already exist.
      // However, we could mark it as delivered or update read status if needed.

      print('Notification synced with backend: ${message.messageId}');
    } catch (e) {
      print('Failed to sync notification with backend: $e');
    }
  }

  /// Get current platform string
  String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Get device ID (simplified implementation)
  Future<String?> _getDeviceId() async {
    // This is a simplified implementation. In a real app, you might want to use
    // a package like device_info_plus to get a proper device identifier
    return null;
  }

  /// Update user context (call this when user logs in/out)
  void updateUserContext({
    NotificationRepository? notificationRepository,
    String? userId,
  }) {
    _notificationRepository = notificationRepository;
    _currentUserId = userId;

    // If user logged out, we might want to clean up the FCM token
    if (userId == null && _notificationRepository != null) {
      _cleanupFCMToken();
    }
  }

  /// Clean up FCM token when user logs out
  Future<void> _cleanupFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && _currentUserId != null) {
        await _notificationRepository!.deleteFCMToken(_currentUserId!, token);
        print('FCM token cleaned up from backend');
      }
    } catch (e) {
      print('Failed to cleanup FCM token: $e');
    }
  }

  /// Get notifications from backend
  Future<List<NotificationEntity>> getNotifications({int? limit}) async {
    if (_notificationRepository == null || _currentUserId == null) {
      return [];
    }

    try {
      return await _notificationRepository!.getNotifications(
        _currentUserId!,
        limit: limit,
      );
    } catch (e) {
      print('Failed to get notifications from backend: $e');
      return [];
    }
  }

  /// Get unread notifications from backend
  Future<List<NotificationEntity>> getUnreadNotifications({int? limit}) async {
    if (_notificationRepository == null || _currentUserId == null) {
      return [];
    }

    try {
      return await _notificationRepository!.getUnreadNotifications(
        _currentUserId!,
        limit: limit,
      );
    } catch (e) {
      print('Failed to get unread notifications from backend: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_notificationRepository == null || _currentUserId == null) return;

    try {
      await _notificationRepository!.markNotificationAsRead(
        _currentUserId!,
        notificationId,
      );
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (_notificationRepository == null || _currentUserId == null) return;

    try {
      await _notificationRepository!.markAllNotificationsAsRead(
        _currentUserId!,
      );
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    if (_notificationRepository == null || _currentUserId == null) return 0;

    try {
      return await _notificationRepository!.getUnreadNotificationsCount(
        _currentUserId!,
      );
    } catch (e) {
      print('Failed to get unread notifications count: $e');
      return 0;
    }
  }

  /// Get notifications stream for real-time updates
  Stream<List<NotificationEntity>> getNotificationsStream({int? limit}) {
    if (_notificationRepository == null || _currentUserId == null) {
      return Stream.empty();
    }

    return _notificationRepository!.getNotificationsStream(
      _currentUserId!,
      limit: limit,
    );
  }

  /// Get unread notifications count stream
  Stream<int> getUnreadNotificationsCountStream() {
    if (_notificationRepository == null || _currentUserId == null) {
      return Stream.value(0);
    }

    return _notificationRepository!.getUnreadNotificationsCountStream(
      _currentUserId!,
    );
  }
}
