import '../entities/fcm_token_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  // FCM Token methods
  /// Save FCM token for the current user
  Future<void> saveFCMToken(String userId, FCMTokenEntity token);
  
  /// Delete FCM token for the current user
  Future<void> deleteFCMToken(String userId, String token);
    
  /// Get the current device's FCM token
  Future<String?> getCurrentFCMToken();
  
  /// Initialize FCM and request permissions
  Future<void> initializeFCM();
  
  /// Listen to FCM token refresh
  Stream<String> onTokenRefresh();

  // Notification management methods
  /// Get all notifications for a user
  Future<List<NotificationEntity>> getNotifications(String userId, {int? limit});
  
  /// Get unread notifications for a user
  Future<List<NotificationEntity>> getUnreadNotifications(String userId, {int? limit});
  
  /// Mark a notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId);
  
  /// Mark multiple notifications as read
  Future<void> markNotificationsAsRead(String userId, List<String> notificationIds);
  
  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId);
  
  /// Get notification by ID
  Future<NotificationEntity?> getNotificationById(String userId, String notificationId);
  
  /// Get notifications stream (real-time updates)
  Stream<List<NotificationEntity>> getNotificationsStream(String userId, {int? limit});
  
  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId);
  
  /// Get unread notifications count stream
  Stream<int> getUnreadNotificationsCountStream(String userId);
}