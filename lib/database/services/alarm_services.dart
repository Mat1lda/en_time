import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm_model.dart';
import 'package:flutter/material.dart';

class AlarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'alarms';
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Get all alarms
  Stream<List<AlarmModel>> getAlarms() {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final alarms = snapshot.docs
          .map((doc) => AlarmModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort alarms by creation date in descending order
      alarms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return alarms;
    });
  }

  // Get a single alarm
  Future<AlarmModel?> getAlarm(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data()?['userId'] == _currentUserId) {
      return AlarmModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Create a new alarm
  Future<String> createAlarm(String alarmName, TimeOfDay time, Map<WeekDay, bool> repeatDays) async {
    final alarmData = {
      ...AlarmModel(
        alarmName: alarmName,
        time: time,
        repeatDays: repeatDays,
        isEnabled: true,
        createdAt: DateTime.now(),
      ).toMap(),
      'userId': _currentUserId,
    };

    final docRef = await _firestore.collection(_collection).add(alarmData);
    return docRef.id;
  }

  // Update an alarm
  Future<void> updateAlarm(String id, {
    String? alarmName,
    TimeOfDay? time,
    Map<WeekDay, bool>? repeatDays,
    bool? isEnabled,
  }) async {
    final updates = <String, dynamic>{
      if (alarmName != null) 'alarmName': alarmName,
      if (time != null) 'time': '${time.hour}:${time.minute}',
      if (repeatDays != null) 'repeatDays': repeatDays.map(
        (key, value) => MapEntry(key.index.toString(), value)
      ),
      if (isEnabled != null) 'isEnabled': isEnabled,
      'userId': _currentUserId,
    };

    await _firestore.collection(_collection).doc(id).update(updates);
  }

  // Toggle alarm enabled state
  Future<void> toggleAlarmState(String id, bool isEnabled) async {
    await _firestore.collection(_collection).doc(id).update({
      'isEnabled': isEnabled,
      'userId': _currentUserId,
    });
  }

  // Delete an alarm
  Future<void> deleteAlarm(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data()?['userId'] == _currentUserId) {
      await _firestore.collection(_collection).doc(id).delete();
    }
  }
}