// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import '../database/models/task_model.dart';
//
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();
//
//   final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
//
//   Future<void> initialize() async {
//     tz.initializeTimeZones();
//
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notifications.initialize(initSettings);
//   }
//
//   Future<void> scheduleTaskNotification(TaskModel task) async {
//     // Parse the time string (assuming format "HH:mm")
//     final timeParts = task.timeStart.split(':');
//     if (timeParts.length != 2) return;
//
//     final hour = int.parse(timeParts[0]);
//     final minute = int.parse(timeParts[1]);
//
//     // Create DateTime for the task
//     final taskDateTime = DateTime(
//       task.day.year,
//       task.day.month,
//       task.day.day,
//       hour,
//       minute,
//     );
//
//     // Schedule notification 10 minutes before
//     final notificationTime = taskDateTime.subtract(const Duration(minutes: 10));
//
//     // Don't schedule if the time has already passed
//     if (notificationTime.isBefore(DateTime.now())) return;
//
//     final id = task.id.hashCode; // Use task ID as notification ID
//
//     await _notifications.zonedSchedule(
//       id,
//       'Nhắc nhở công việc',
//       'Công việc "${task.content}" sẽ bắt đầu sau 10 phút',
//       tz.TZDateTime.from(notificationTime, tz.local),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'task_reminders',
//           'Task Reminders',
//           channelDescription: 'Notifications for task reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//         iOS: const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   Future<void> cancelTaskNotification(String taskId) async {
//     await _notifications.cancel(taskId.hashCode);
//   }
//
//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }
// }
