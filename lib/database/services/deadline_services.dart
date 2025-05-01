import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/deadline_model.dart';

class DeadlineService {
  final CollectionReference _deadlinesCollection = FirebaseFirestore.instance.collection('deadlines');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addDeadline(DeadlineModel deadline) async {
    try {
      await _deadlinesCollection.doc(deadline.id).set({
        ...deadline.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to add deadline: $e');
    }
  }

  Future<void> deleteDeadline(String deadlineId) async {
    try {
      await _deadlinesCollection.doc(deadlineId).delete();
    } catch (e) {
      throw Exception('Failed to delete deadline: $e');
    }
  }

  Future<void> updateDeadline(DeadlineModel deadline) async {
    try {
      await _deadlinesCollection.doc(deadline.id).update({
        ...deadline.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to update deadline: $e');
    }
  }

  Stream<List<DeadlineModel>> getAllDeadlines() {
    return _deadlinesCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final deadlines = snapshot.docs.map((doc) {
            return DeadlineModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort deadlines by day and time
          deadlines.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If days are equal, sort by start time
            return a.timeEnd.compareTo(b.timeEnd);
          });
          return deadlines;
        });
  }

  Stream<List<DeadlineModel>> getDeadlinesByDay(DateTime day) {
    // Convert DateTime to start of the day for comparison
    final targetDay = DateTime(day.year, day.month, day.day);
    
    return _deadlinesCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final deadlines = snapshot.docs.map((doc) {
            return DeadlineModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          // Filter deadlines for the specific day
          final dayDeadlines = deadlines.where((deadline) {
            final deadlineDay = DateTime(
              deadline.day.year,
              deadline.day.month,
              deadline.day.day
            );
            return deadlineDay.isAtSameMomentAs(targetDay);
          }).toList();
          
          // Sort deadlines by time
          dayDeadlines.sort((a, b) => a.timeEnd.compareTo(b.timeEnd));
          return dayDeadlines;
        });
  }

  Stream<List<DeadlineModel>> getUpcomingDeadlines() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    return _deadlinesCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final deadlines = snapshot.docs.map((doc) {
            return DeadlineModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();

          // Filter deadlines that are from today onwards and not done
          final upcomingDeadlines = deadlines.where((deadline) {
            final deadlineDay = DateTime(deadline.day.year, deadline.day.month, deadline.day.day);
            return deadlineDay.isAfter(startOfToday.subtract(Duration(days: 1))) && 
                   !deadline.isDone;
          }).toList();
          
          // Sort deadlines by day and time
          upcomingDeadlines.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If days are equal, sort by time
            return a.timeEnd.compareTo(b.timeEnd);
          });
          
          return upcomingDeadlines;
        });
  }
} 