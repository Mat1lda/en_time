import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
class SubjectModel {
  final String id;
  final DateTime day;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String subject;
  final Color subjectColor;

  SubjectModel({
    required this.id,
    required this.day,
    required this.timeStart,
    required this.timeEnd,
    required this.subject,
    required this.subjectColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'subject': subject,
      'subjectColor': subjectColor.value,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    try {
      DateTime parseDateTime(String? dateTimeStr) {
        if (dateTimeStr == null) return DateTime.now();
        try {
          // First try parsing as ISO 8601
          try {
            return DateTime.parse(dateTimeStr);
          } catch (e) {
            // If that fails, try parsing as time string
            final format = DateFormat("hh:mm a");
            final time = format.parse(dateTimeStr);
            // Combine with current date
            final now = DateTime.now();
            return DateTime(now.year, now.month, now.day, time.hour, time.minute);
          }
        } catch (e) {
          print('Error parsing date: $e for string: $dateTimeStr');
          return DateTime.now(); // Fallback to current time
        }
      }

      return SubjectModel(
        id: map['id'] ?? '',
        day: parseDateTime(map['day']),
        timeStart: parseDateTime(map['timeStart']),
        timeEnd: parseDateTime(map['timeEnd']),
        subject: map['subject'] ?? '',
        subjectColor: Color(map['subjectColor'] ?? 0xff92A3FD),
      );
    } catch (e) {
      print('Error in SubjectModel.fromMap: $e for data: $map');
      // Return a default model in case of error
      return SubjectModel(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        day: DateTime.now(),
        timeStart: DateTime.now(),
        timeEnd: DateTime.now().add(Duration(hours: 1)),
        subject: map['subject'] ?? 'Default Subject',
        subjectColor: Color(0xff92A3FD), // Default color
      );
    }
  }

  Appointment toAppointment() {
    return Appointment(
      id: id,
      startTime: timeStart,
      endTime: timeEnd,
      subject: subject,
      color: subjectColor,
    );
  }
} 