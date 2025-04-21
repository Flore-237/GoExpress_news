import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demander la permission pour les notifications
    await _fcm.requestPermission();

    // Obtenir le token FCM
    final token = await _fcm.getToken();
    if (token != null && _auth.currentUser != null) {
      await _saveDeviceToken(token);
    }

    // Écouter les messages en foreground
    FirebaseMessaging.onMessage.listen(_handleNotification);
  }

  Future<void> _saveDeviceToken(String token) async {
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  void _handleNotification(RemoteMessage message) {
    // Traiter la notification reçue
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().toString(),
      title: message.notification?.title ?? 'Nouvelle notification',
      message: message.notification?.body ?? '',
      date: DateTime.now(),
      payload: message.data,
    );

    // Ici vous pourriez ajouter la notification au provider
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    final snapshot = await _firestore
        .collection('notifications')
        .doc(_auth.currentUser?.uid)
        .collection('user_notifications')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(_auth.currentUser?.uid)
        .collection('user_notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? route,
    Map<String, dynamic>? payload,
  }) async {
    // En production, vous utiliseriez Cloud Functions pour envoyer via FCM
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .add({
      'title': title,
      'message': message,
      'date': FieldValue.serverTimestamp(),
      'isRead': false,
      'route': route,
      'payload': payload,
    });
  }
}