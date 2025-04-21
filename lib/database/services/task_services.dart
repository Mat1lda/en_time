import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class TaskService {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final NotificationService _notificationService = NotificationService();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).set({
        ...task.toMap(),
        'userId': currentUserId,
      });
      //await _notificationService.scheduleTaskNotification(task);
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      //await _notificationService.cancelTaskNotification(taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).update({
        ...task.toMap(),
        'userId': currentUserId,
      });
      //await _notificationService.cancelTaskNotification(task.id);
      //await _notificationService.scheduleTaskNotification(task);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Get all tasks
  Stream<List<TaskModel>> getAllTasks() {
    return _tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return TaskModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort tasks by day and time
          tasks.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If days are equal, sort by time
            return a.timeStart.compareTo(b.timeStart);
          });
          return tasks;
        });
  }

  // Get tasks for a specific day
  Stream<List<TaskModel>> getTasksByDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return TaskModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          
          // Filter tasks for the specific day
          final filteredTasks = tasks.where((task) {
            try {
              final taskDay = DateTime(task.day.year, task.day.month, task.day.day);
              return taskDay.isAtSameMomentAs(startOfDay);
            } catch (e) {
              print('Error comparing dates: $e');
              return false;
            }
          }).toList();
          
          // Sort tasks by time
          filteredTasks.sort((a, b) => a.timeStart.compareTo(b.timeStart));
          return filteredTasks;
        });
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'isDone': !currentStatus,
        'userId': currentUserId,
      });
      if (!currentStatus) {
        // If task is marked as done, cancel its notification
        //await _notificationService.cancelTaskNotification(taskId);
      }
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  Stream<List<TaskModel>> getCompletedTasks() {
    return _tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .where('isDone', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return TaskModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort tasks by day and time
          tasks.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If days are equal, sort by time
            return a.timeStart.compareTo(b.timeStart);
          });
          return tasks;
        });
  }

  // Get upcoming tasks (today and future)
  Stream<List<TaskModel>> getUpcomingTasks() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final currentTime = DateFormat('hh:mm a').format(now);  // Format current time as "hh:mm a"
    
    return _tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return TaskModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();

          // Filter tasks that are upcoming and not done
          final upcomingTasks = tasks.where((task) {
            if (task.isDone) return false;  // Skip completed tasks

            try {
              final taskDay = DateTime(task.day.year, task.day.month, task.day.day);
              
              // For future days, include all tasks
              if (taskDay.isAfter(startOfToday)) {
                return true;
              }
              
              // For today, check the specific time
              if (taskDay.isAtSameMomentAs(startOfToday)) {
                // Parse task time and current time to 24-hour format for comparison
                final taskDateTime = DateFormat('hh:mm a').parse(task.timeStart);
                final currentDateTime = DateFormat('hh:mm a').parse(currentTime);
                
                return taskDateTime.isAfter(currentDateTime);
              }
              
              return false;
            } catch (e) {
              print('Error comparing dates and times: $e');
              return false;
            }
          }).toList();
          
          // Sort tasks by day and time
          upcomingTasks.sort((a, b) {
            // First sort by day
            final dayCompare = a.day.compareTo(b.day);
            if (dayCompare != 0) return dayCompare;
            // If dates are equal, sort by time
            return DateFormat('hh:mm a').parse(a.timeStart)
                .compareTo(DateFormat('hh:mm a').parse(b.timeStart));
          });
          
          return upcomingTasks;
        });
  }
}
