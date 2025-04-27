import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class SubjectModel {
  final String id;
  final DateTime rangeStart; // New field
  final DateTime rangeEnd;   // New field
  final DateTime timeStart;
  final DateTime timeEnd;
  final String subject;
  final Color subjectColor;
  final List<int> weekdays; // New field to store selected weekdays (1-7)

  SubjectModel({
    required this.id,
    required this.rangeStart,
    required this.rangeEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.subject,
    required this.subjectColor,
    required this.weekdays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rangeStart': rangeStart.toIso8601String(),
      'rangeEnd': rangeEnd.toIso8601String(),
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'subject': subject,
      'subjectColor': subjectColor.value,
      'weekdays': weekdays,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    try {
      DateTime parseDateTime(String? dateTimeStr) {
        if (dateTimeStr == null) return DateTime.now();
        try {
          return DateTime.parse(dateTimeStr);
        } catch (e) {
          print('Error parsing date: $e for string: $dateTimeStr');
          return DateTime.now();
        }
      }

      return SubjectModel(
        id: map['id'] ?? '',
        rangeStart: parseDateTime(map['rangeStart']),
        rangeEnd: parseDateTime(map['rangeEnd']),
        timeStart: parseDateTime(map['timeStart']),
        timeEnd: parseDateTime(map['timeEnd']),
        subject: map['subject'] ?? '',
        subjectColor: Color(map['subjectColor'] ?? 0xff92A3FD),
        weekdays: List<int>.from(map['weekdays'] ?? []),
      );
    } catch (e) {
      print('Error in SubjectModel.fromMap: $e for data: $map');
      return SubjectModel(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        rangeStart: DateTime.now(),
        rangeEnd: DateTime.now().add(Duration(days: 7)),
        timeStart: DateTime.now(),
        timeEnd: DateTime.now().add(Duration(hours: 1)),
        subject: map['subject'] ?? 'Default Subject',
        subjectColor: Color(0xff92A3FD),
        weekdays: [DateTime.now().weekday],
      );
    }
  }

  Appointment toAppointment() {
    // Create recurring appointments for each weekday within the range
    final List<Appointment> appointments = [];
    
    DateTime current = rangeStart;
    while (current.isBefore(rangeEnd) || current.isAtSameMomentAs(rangeEnd)) {
      if (weekdays.contains(current.weekday)) {
        appointments.add(Appointment(
          startTime: DateTime(
            current.year,
            current.month,
            current.day,
            timeStart.hour,
            timeStart.minute,
          ),
          endTime: DateTime(
            current.year,
            current.month,
            current.day,
            timeEnd.hour,
            timeEnd.minute,
          ),
          subject: subject,
          color: subjectColor,
          id: id,
        ));
      }
      current = current.add(Duration(days: 1));
    }
    
    return appointments.first; // Return the first appointment for compatibility
  }

  List<Appointment> toAppointments() {
    // Create recurring appointments for each weekday within the range
    final List<Appointment> appointments = [];
    
    DateTime current = rangeStart;
    while (current.isBefore(rangeEnd) || current.isAtSameMomentAs(rangeEnd)) {
      if (weekdays.contains(current.weekday)) {
        appointments.add(Appointment(
          startTime: DateTime(
            current.year,
            current.month,
            current.day,
            timeStart.hour,
            timeStart.minute,
          ),
          endTime: DateTime(
            current.year,
            current.month,
            current.day,
            timeEnd.hour,
            timeEnd.minute,
          ),
          subject: subject,
          color: subjectColor,
          id: id,
        ));
      }
      current = current.add(Duration(days: 1));
    }
    
    return appointments;
  }
}