import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("token: $fCMToken");
  }

  // Kiểm tra phiên bản Android hiện tại
  Future<bool> _android13OrAbove() async {
    try {
      final info = await _firebaseMessaging.getNotificationSettings();
      return info.authorizationStatus == AuthorizationStatus.notDetermined;
    } catch (_) {
      return false;
    }
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> saveTokenToFirestore(String userId, String newToken) async {
    final userRef = _firestore.collection('users').doc(userId);

    final snapshot = await userRef.get();
    final existingTokens = List<String>.from(snapshot.data()?['fcmTokens'] ?? []);

    if (!existingTokens.contains(newToken)) {
      existingTokens.add(newToken);
      await userRef.update({
        'fcmTokens': existingTokens,
      });
      print("✅ Token mới đã được thêm vào danh sách.");
    } else {
      print("ℹ️ Token này đã tồn tại trong danh sách.");
    }
  }
  Future<void> removeFcmToken(String userId, String tokenToRemove) async {
    final userRef = _firestore.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final tokens = List<String>.from(snapshot.data()?['fcmTokens'] ?? []);

    tokens.remove(tokenToRemove);
    await userRef.update({'fcmTokens': tokens});
  }
}
