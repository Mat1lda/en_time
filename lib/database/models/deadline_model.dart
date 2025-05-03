import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DeadlineModel {
  final String id;
  final DateTime day;
  //final DateTime timeStart;
  final DateTime timeEnd;
  final String subject;
  final String? idSubject;
  final String deadlineName;
  final Color deadlineColor;
  final bool isDone;

  DeadlineModel({
    required this.id,
    required this.day,
    //required this.timeStart,
    required this.timeEnd,
    required this.subject,
    this.idSubject,
    required this.deadlineName,
    required this.deadlineColor,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day.toIso8601String(),
      //'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'subject': subject,
      'idSubject': idSubject,
      'deadlineName': deadlineName,
      'deadlineColor': deadlineColor.value,
      'isDone': isDone,
    };
  }

  factory DeadlineModel.fromMap(Map<String, dynamic> map) {
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

      return DeadlineModel(
        id: map['id'] ?? '',
        day: parseDateTime(map['day']),
        //timeStart: parseDateTime(map['timeStart']),
        timeEnd: parseDateTime(map['timeEnd']),
        subject: map['subject'] ?? '',
        idSubject: map['idSubject'] ?? '',
        deadlineName: map['deadlineName'] ?? '',
        deadlineColor: Color(map['deadlineColor'] ?? 0xffC58BF2),
        isDone: map['isDone'] ?? false,
      );
    } catch (e) {
      print('Error in DeadlineModel.fromMap: $e for data: $map');
      // Return a default model in case of error
      return DeadlineModel(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        day: DateTime.now(),
        //timeStart: DateTime.now(),
        timeEnd: DateTime.now().add(Duration(hours: 1)),
        subject: map['subject'] ?? 'Default Subject',
        idSubject: map['idSubject'] ?? 'Default idSubject',
        deadlineName: map['deadlineName'] ?? 'Default Deadline',
        deadlineColor: Color(0xffC58BF2), // Default color
        isDone: false,
      );
    }
  }

  Appointment toAppointment() {
    return Appointment(
      id: id,
      startTime: DateTime.now(),
      endTime: timeEnd,
      subject: '$subject - $deadlineName',
      color: deadlineColor,
      notes: 'deadline',  // Used to identify this as a deadline
    );
  }
} 