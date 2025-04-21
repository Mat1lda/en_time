import 'package:en_time/firebase_api.dart';
import 'package:en_time/views/pages/auth/login_page.dart';
import 'package:en_time/views/pages/splash_page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/appTheme.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Xử lý thông báo khi ứng dụng ở background
  print("Handling a background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // final notificationService = NotificationService();
  // await notificationService.initialize();

  //Lắng nghe thông báo từ FCM
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification!.body}');
    }
  });
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('💬 Permission granted: ${settings.authorizationStatus}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Apptheme.lightTheme,
        home: const SplashPage()
        // home: ForgotPasswordPage()
    );
  }
}
