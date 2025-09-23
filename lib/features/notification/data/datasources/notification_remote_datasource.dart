import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/fcm_token_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/fcm_token_model.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  NotificationRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  /// Save FCM token for a user
  Future<void> saveFCMToken(String userId, FCMTokenEntity token) async {
    try {
      final tokenModel = FCMTokenModel.fromEntity(token);
      final tokenDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token.token); // Use token as document ID
      
      await tokenDocRef.set(tokenModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  /// Delete a specific FCM token for a user
  Future<void> deleteFCMToken(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete FCM token: $e');
    }
  }

  /// Get the current device's FCM token
  Future<String?> getCurrentFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw Exception('Failed to get current FCM token: $e');
    }
  }

  /// Initialize FCM and request permissions
  Future<void> initializeFCM() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Configure foreground notifications
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      throw Exception('Failed to initialize FCM: $e');
    }
  }

  /// Listen to FCM token refresh
  Stream<String> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  /// Get platform name for the current device
  String getCurrentPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  // Notification management methods
  
  /// Get all notifications for a user
  Future<List<NotificationEntity>> getNotifications(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Get unread notifications for a user
  Future<List<NotificationEntity>> getUnreadNotifications(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark multiple notifications as read
  Future<void> markNotificationsAsRead(String userId, List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final notificationId in notificationIds) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId);
        batch.update(docRef, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Get notification by ID
  Future<NotificationEntity?> getNotificationById(String userId, String notificationId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      
      return NotificationModel.fromFirestore(docSnapshot.data()!, docSnapshot.id).toEntity();
    } catch (e) {
      throw Exception('Failed to get notification by ID: $e');
    }
  }

  /// Get notifications stream (real-time updates)
  Stream<List<NotificationEntity>> getNotificationsStream(String userId, {int? limit}) {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots().map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id).toEntity())
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get notifications stream: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread notifications count: $e');
    }
  }

  /// Get unread notifications count stream
  Stream<int> getUnreadNotificationsCountStream(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.length);
    } catch (e) {
      throw Exception('Failed to get unread notifications count stream: $e');
    }
  }
}