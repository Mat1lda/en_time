import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectService {
  final CollectionReference _subjectsCollection = FirebaseFirestore.instance.collection('subjects');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addSubject(SubjectModel subject) async {
    try {
      await _subjectsCollection.doc(subject.id).set({
        ...subject.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to add subject: $e');
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _subjectsCollection.doc(subjectId).delete();
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }

  Future<void> updateSubject(SubjectModel subject) async {
    try {
      await _subjectsCollection.doc(subject.id).update({
        ...subject.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to update subject: $e');
    }
  }

  Stream<List<SubjectModel>> getAllSubjects() {
    return _subjectsCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final subjects = snapshot.docs.map((doc) {
            return SubjectModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort subjects by day and time
          subjects.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If days are equal, sort by start time
            return a.timeStart.compareTo(b.timeStart);
          });
          return subjects;
        });
  }

  Stream<List<SubjectModel>> getSubjectsByDay(DateTime day) {
    // Convert DateTime to start and end of the day for query
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _subjectsCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('day', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('day', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) {
          final subjects = snapshot.docs.map((doc) {
            return SubjectModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort subjects by time
          subjects.sort((a, b) => a.timeStart.compareTo(b.timeStart));
          return subjects;
        });
  }

  Future<List<SubjectModel>> getUpcomingSubjects({int limit = 3}) async {
    try {
      final snapshot = await _subjectsCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final now = DateTime.now();

      final upcomingSubjects = snapshot.docs.map((doc) {
        return SubjectModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).where((subject) {
        return subject.timeStart.isAfter(now);
      }).toList();

      // Sắp xếp theo thời gian bắt đầu
      upcomingSubjects.sort((a, b) => a.timeStart.compareTo(b.timeStart));

      return upcomingSubjects.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming subjects: $e');
    }
  }

} 