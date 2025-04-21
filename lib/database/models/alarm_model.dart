import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum WeekDay {
  monday,    // 0
  tuesday,   // 1
  wednesday, // 2
  thursday,  // 3
  friday,    // 4
  saturday,  // 5
  sunday     // 6
}

class AlarmModel {
  final String? id;
  final String alarmName;
  final TimeOfDay time;  //
  final Map<WeekDay, bool> repeatDays;
  final bool isEnabled;
  final DateTime createdAt;

  AlarmModel({
    this.id,
    required this.alarmName,
    required this.time,
    required this.repeatDays,
    required this.isEnabled,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alarmName': alarmName,
      'time': '${time.hour}:${time.minute}',  // Store as HH:mm string
      'repeatDays': repeatDays.map((key, value) => MapEntry(key.index.toString(), value)),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map, String documentId) {
    final timeParts = (map['time'] as String).split(':');
    final repeatDaysMap = (map['repeatDays'] as Map<String, dynamic>?) ?? {};

    return AlarmModel(
      id: documentId,
      alarmName: map['alarmName'] ?? 'Alarm',
      time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1])
      ),
      repeatDays: repeatDaysMap.map((key, value) =>
          MapEntry(WeekDay.values[int.parse(key)], value as bool)),
      isEnabled: map['isEnabled'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static Map<WeekDay, bool> createDefaultRepeatDays() {
    return Map.fromIterable(
      WeekDay.values,
      key: (day) => day,
      value: (_) => false,
    );
  }
}