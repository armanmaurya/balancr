import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fcm_token_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../../../services/push_notification_service.dart';

// Data source provider
final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource();
});

// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

// FCM Token refresh stream provider
final fcmTokenRefreshProvider = StreamProvider<String>((ref) {
  return ref.watch(notificationRepositoryProvider).onTokenRefresh();
});

// Current FCM token provider
final currentFCMTokenProvider = FutureProvider<String?>((ref) {
  return ref.watch(notificationRepositoryProvider).getCurrentFCMToken();
});

// Notification management providers

// Get notifications for a specific user
final userNotificationsProvider = FutureProvider.family<List<NotificationEntity>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getNotifications(userId);
});

// Get unread notifications for a specific user
final unreadNotificationsProvider = FutureProvider.family<List<NotificationEntity>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getUnreadNotifications(userId);
});

// Get notifications stream for real-time updates
final notificationsStreamProvider = StreamProvider.family<List<NotificationEntity>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getNotificationsStream(userId);
});

// Get unread notifications count
final unreadNotificationsCountProvider = FutureProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getUnreadNotificationsCount(userId);
});

// Get unread notifications count stream for real-time updates
final unreadNotificationsCountStreamProvider = StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).getUnreadNotificationsCountStream(userId);
});

// Get a specific notification by ID
final notificationByIdProvider = FutureProvider.family<NotificationEntity?, ({String userId, String notificationId})>((ref, params) {
  return ref.watch(notificationRepositoryProvider).getNotificationById(params.userId, params.notificationId);
});

// Notification service provider - handles FCM initialization and token management
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    repository: ref.watch(notificationRepositoryProvider),
    dataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

/// Service class to handle notification-related operations
class NotificationService {
  final NotificationRepository _repository;
  final NotificationRemoteDataSource _dataSource;
  final PushNotificationService _pushService;

  NotificationService({
    required NotificationRepository repository,
    required NotificationRemoteDataSource dataSource,
  }) : _repository = repository,
       _dataSource = dataSource,
       _pushService = PushNotificationService.instance;

  /// Initialize FCM for the current user
  Future<void> initializeFCM() async {
    try {
      await _repository.initializeFCM();
      if (kDebugMode) {
        print('FCM initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize FCM: $e');
      }
      rethrow;
    }
  }

  /// Save current device's FCM token for a user
  Future<void> saveTokenForUser(String userId) async {
    try {
      final token = await _repository.getCurrentFCMToken();
      if (token == null) {
        throw Exception('Failed to get FCM token');
      }

      final fcmTokenEntity = FCMTokenEntity(
        token: token,
        platform: _dataSource.getCurrentPlatform(),
        createdAt: DateTime.now(),
      );

      await _repository.saveFCMToken(userId, fcmTokenEntity);
      
      if (kDebugMode) {
        print('FCM token saved for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save FCM token: $e');
      }
      rethrow;
    }
  }

  /// Delete current device's FCM token for a user
  Future<void> deleteTokenForUser(String userId) async {
    try {
      final token = await _repository.getCurrentFCMToken();
      if (token != null) {
        await _repository.deleteFCMToken(userId, token);
        if (kDebugMode) {
          print('FCM token deleted for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete FCM token: $e');
      }
      rethrow;
    }
  }

  /// Listen to token refresh and update in Firestore
  Stream<String> listenToTokenRefresh() {
    return _repository.onTokenRefresh();
  }

  /// Handle user login - initialize FCM and save token
  Future<void> handleUserLogin(String userId) async {
    try {
      // Initialize FCM first
      await initializeFCM();
      
      // Initialize PushNotificationService with user context
      await _pushService.initialize(
        notificationRepository: _repository,
        userId: userId,
      );
      
      // Save token is now handled by PushNotificationService during initialization
      
      if (kDebugMode) {
        print('FCM setup completed for user login: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to setup FCM for user login: $e');
      }
      // Don't rethrow here as this shouldn't block login
    }
  }

  /// Handle user logout - delete current device token only
  Future<void> handleUserLogout(String userId) async {
    try {
      await deleteTokenForUser(userId);
      
      // Update PushNotificationService to clear user context
      _pushService.updateUserContext(
        notificationRepository: null,
        userId: null,
      );
      
      if (kDebugMode) {
        print('FCM cleanup completed for user logout: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup FCM for user logout: $e');
      }
      // Don't rethrow here as this shouldn't block logout
    }
  }

  // Notification management methods

  /// Get all notifications for a user
  Future<List<NotificationEntity>> getNotifications(String userId, {int? limit}) async {
    try {
      return await _repository.getNotifications(userId, limit: limit);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get notifications: $e');
      }
      rethrow;
    }
  }

  /// Get unread notifications for a user
  Future<List<NotificationEntity>> getUnreadNotifications(String userId, {int? limit}) async {
    try {
      return await _repository.getUnreadNotifications(userId, limit: limit);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get unread notifications: $e');
      }
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _repository.markNotificationAsRead(userId, notificationId);
      if (kDebugMode) {
        print('Marked notification as read: $notificationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark notification as read: $e');
      }
      rethrow;
    }
  }

  /// Mark multiple notifications as read
  Future<void> markNotificationsAsRead(String userId, List<String> notificationIds) async {
    try {
      await _repository.markNotificationsAsRead(userId, notificationIds);
      if (kDebugMode) {
        print('Marked ${notificationIds.length} notifications as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark notifications as read: $e');
      }
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _repository.markAllNotificationsAsRead(userId);
      if (kDebugMode) {
        print('Marked all notifications as read for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark all notifications as read: $e');
      }
      rethrow;
    }
  }

  /// Get a notification by ID
  Future<NotificationEntity?> getNotificationById(String userId, String notificationId) async {
    try {
      return await _repository.getNotificationById(userId, notificationId);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get notification by ID: $e');
      }
      rethrow;
    }
  }

  /// Get notifications stream for real-time updates
  Stream<List<NotificationEntity>> getNotificationsStream(String userId, {int? limit}) {
    return _repository.getNotificationsStream(userId, limit: limit);
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      return await _repository.getUnreadNotificationsCount(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get unread notifications count: $e');
      }
      rethrow;
    }
  }

  /// Get unread notifications count stream for real-time updates
  Stream<int> getUnreadNotificationsCountStream(String userId) {
    return _repository.getUnreadNotificationsCountStream(userId);
  }

  // Methods that delegate to PushNotificationService for unified access

  /// Get notifications from PushNotificationService (unified access)
  Future<List<NotificationEntity>> getNotificationsFromService({int? limit}) async {
    return await _pushService.getNotifications(limit: limit);
  }

  /// Get unread notifications from PushNotificationService (unified access)
  Future<List<NotificationEntity>> getUnreadNotificationsFromService({int? limit}) async {
    return await _pushService.getUnreadNotifications(limit: limit);
  }

  /// Mark notification as read via PushNotificationService
  Future<void> markNotificationAsReadViaService(String notificationId) async {
    await _pushService.markNotificationAsRead(notificationId);
  }

  /// Mark all notifications as read via PushNotificationService
  Future<void> markAllNotificationsAsReadViaService() async {
    await _pushService.markAllNotificationsAsRead();
  }

  /// Get unread notifications count from PushNotificationService
  Future<int> getUnreadNotificationsCountFromService() async {
    return await _pushService.getUnreadNotificationsCount();
  }

  /// Get notifications stream from PushNotificationService
  Stream<List<NotificationEntity>> getNotificationsStreamFromService({int? limit}) {
    return _pushService.getNotificationsStream(limit: limit);
  }

  /// Get unread notifications count stream from PushNotificationService
  Stream<int> getUnreadNotificationsCountStreamFromService() {
    return _pushService.getUnreadNotificationsCountStream();
  }
}