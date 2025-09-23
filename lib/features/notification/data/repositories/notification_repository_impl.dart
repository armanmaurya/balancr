import '../../domain/entities/fcm_token_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> saveFCMToken(String userId, FCMTokenEntity token) async {
    try {
      await _remoteDataSource.saveFCMToken(userId, token);
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  @override
  Future<void> deleteFCMToken(String userId, String token) async {
    try {
      await _remoteDataSource.deleteFCMToken(userId, token);
    } catch (e) {
      throw Exception('Failed to delete FCM token: $e');
    }
  }

  @override
  Future<String?> getCurrentFCMToken() async {
    try {
      return await _remoteDataSource.getCurrentFCMToken();
    } catch (e) {
      throw Exception('Failed to get current FCM token: $e');
    }
  }

  @override
  Future<void> initializeFCM() async {
    try {
      await _remoteDataSource.initializeFCM();
    } catch (e) {
      throw Exception('Failed to initialize FCM: $e');
    }
  }

  @override
  Stream<String> onTokenRefresh() {
    return _remoteDataSource.onTokenRefresh();
  }

  // Notification management methods
  
  @override
  Future<List<NotificationEntity>> getNotifications(String userId, {int? limit}) async {
    try {
      return await _remoteDataSource.getNotifications(userId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getUnreadNotifications(String userId, {int? limit}) async {
    try {
      return await _remoteDataSource.getUnreadNotifications(userId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _remoteDataSource.markNotificationAsRead(userId, notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markNotificationsAsRead(String userId, List<String> notificationIds) async {
    try {
      await _remoteDataSource.markNotificationsAsRead(userId, notificationIds);
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _remoteDataSource.markAllNotificationsAsRead(userId);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<NotificationEntity?> getNotificationById(String userId, String notificationId) async {
    try {
      return await _remoteDataSource.getNotificationById(userId, notificationId);
    } catch (e) {
      throw Exception('Failed to get notification by ID: $e');
    }
  }

  @override
  Stream<List<NotificationEntity>> getNotificationsStream(String userId, {int? limit}) {
    try {
      return _remoteDataSource.getNotificationsStream(userId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get notifications stream: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      return await _remoteDataSource.getUnreadNotificationsCount(userId);
    } catch (e) {
      throw Exception('Failed to get unread notifications count: $e');
    }
  }

  @override
  Stream<int> getUnreadNotificationsCountStream(String userId) {
    try {
      return _remoteDataSource.getUnreadNotificationsCountStream(userId);
    } catch (e) {
      throw Exception('Failed to get unread notifications count stream: $e');
    }
  }
}