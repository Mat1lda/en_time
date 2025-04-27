import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskPriority {
  critical,
  high,
  medium,
  low
}

enum TaskStatus {
  notStarted,
  inProgress,
  completed,
  overdue
}

extension TaskPriorityExtension on TaskPriority {
  String toVietnamese() {
    switch (this) {
      case TaskPriority.critical:
        return 'Khẩn cấp';
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.low:
        return 'Thấp';
    }
  }

  Color getColor() {
    switch (this) {
      case TaskPriority.critical:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String toVietnamese() {
    switch (this) {
      case TaskStatus.notStarted:
        return 'Chưa bắt đầu';
      case TaskStatus.inProgress:
        return 'Đang thực hiện';
      case TaskStatus.completed:
        return 'Đã hoàn thành';
      case TaskStatus.overdue:
        return 'Quá hạn';
    }
  }

  Color getColor() {
    switch (this) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.overdue:
        return Colors.red;
    }
  }
}

class TaskModel {
  final String id;
  final DateTime day;
  final String timeStart;
  final String content;
  final bool isDone;
  final String taskType;
  final String userId;
  final TaskPriority priority;
  bool isHidden;

  TaskModel({
    required this.id,
    required this.day,
    required this.timeStart,
    required this.content,
    required this.isDone,
    required this.taskType,
    this.priority = TaskPriority.medium,
    this.isHidden = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      'timeStart': timeStart,
      'content': content,
      'isDone': isDone,
      'taskType': taskType,
      'userId': userId,
      'priority': priority.index,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      day: DateTime.parse(map['day']),
      timeStart: map['timeStart'] ?? '',
      content: map['content'] ?? '',
      isDone: map['isDone'] ?? false,
      taskType: map['taskType'] ?? '',
      userId: map['userId'] ?? '',
      priority: TaskPriority.values[map['priority'] ?? TaskPriority.medium.index],
    );
  }

  TaskStatus getStatus() {
    if (isDone) return TaskStatus.completed;
    final now = DateTime.now();
    // Parse time string safely (handles both 12-hour and 24-hour formats)
    try {
      final timeComponents = timeStart.toLowerCase();
      int hour;
      int minute;
      
      if (timeComponents.contains('am') || timeComponents.contains('pm')) {
        // 12-hour format (e.g., "2:30 PM")
        final time = timeComponents.replaceAll(RegExp(r'[ap]m'), '').trim().split(':');
        hour = int.parse(time[0]);
        minute = int.parse(time[1]);
        
        if (timeComponents.contains('pm') && hour != 12) {
          hour += 12;
        }
        if (timeComponents.contains('am') && hour == 12) {
          hour = 0;
        }
      } else {
        // 24-hour format (e.g., "14:30")
        final time = timeStart.split(':');
        hour = int.parse(time[0]);
        minute = int.parse(time[1]);
      }

      final taskDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );

      if (now.isBefore(taskDateTime)) {
        return TaskStatus.notStarted;
      } else if (now.isAfter(taskDateTime) && !isDone) {
        return TaskStatus.inProgress;
      } else {
        return TaskStatus.inProgress;
      }
    } catch (e) {
      // Return notStarted as fallback if time parsing fails
      return TaskStatus.notStarted;
    }
  }

  TaskModel copyWith({
    String? id,
    DateTime? day,
    String? timeStart,
    String? content,
    bool? isDone,
    String? taskType,
    String? userId,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      day: day ?? this.day,
      timeStart: timeStart ?? this.timeStart,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      taskType: taskType ?? this.taskType,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
    );
  }
}