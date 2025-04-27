// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:en_time/database/models/subject_model.dart';
//
// class CalendarService {
//   Future<void> exportSubjectToCalendar(SubjectModel subject) async {
//     // Create recurring events for each weekday
//     for (int weekday in subject.weekdays) {
//       final Event event = Event(
//         title: subject.subject,
//         description: 'Môn học từ thời khóa biểu En Time',
//         location: '',
//         startDate: _getNextWeekday(subject.rangeStart, weekday, subject.timeStart),
//         endDate: _getNextWeekday(subject.rangeStart, weekday, subject.timeEnd),
//         recurrence: Recurrence(
//           frequency: Frequency.weekly,
//           endDate: subject.rangeEnd,
//         ),
//       );
//
//       final success = await Add2Calendar.addEvent2Cal(event);
//       if (!success) {
//         throw Exception('Không thể thêm sự kiện vào lịch');
//       }
//     }
//   }
//
//   DateTime _getNextWeekday(DateTime startDate, int targetWeekday, DateTime timeReference) {
//     DateTime date = DateTime(
//       startDate.year,
//       startDate.month,
//       startDate.day,
//       timeReference.hour,
//       timeReference.minute,
//     );
//
//     while (date.weekday != targetWeekday) {
//       date = date.add(Duration(days: 1));
//     }
//
//     return date;
//   }
// }