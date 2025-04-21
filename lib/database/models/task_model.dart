import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class TaskModel {
  final String id;
  final DateTime day;
  final String timeStart;
  final String content;
  final bool isDone;
  final String taskType;
  final String userId;
  bool isHidden;

  TaskModel({
    required this.id,
    required this.day,
    required this.timeStart,
    required this.content,
    required this.isDone,
    required this.taskType,
    this.isHidden = false,
    required this.userId,
  });

  // Convert TaskModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      'timeStart': timeStart,
      'content': content,
      'isDone': isDone,
      'taskType': taskType,
      'userId': userId,
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
    );
  }

  // Create a copy of TaskModel with some fields changed
  TaskModel copyWith({
    String? id,
    DateTime? day,
    String? timeStart,
    String? content,
    bool? isDone,
    String? taskType,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      day: day ?? this.day,
      timeStart: timeStart ?? this.timeStart,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      taskType: taskType ?? this.taskType,
      userId: userId ?? this.userId,
    );
  }
} 