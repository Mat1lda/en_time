import 'package:flutter/services.dart';
import 'dart:async';

class TimerService {
  static const platform = MethodChannel('com.example.en_time/timer');
  Timer? _timer;

  Future<void> showNotification(String title, String message) async {
    try {
      await platform.invokeMethod('showNotification', {
        'title': title,
        'message': message
      });
    } on PlatformException catch (e) {
      print('Failed to show notification: ${e.message}');
    }
  }

  void startTimer(int minutes, Function(int) onTick, Function() onComplete) {
    int timeLeft = minutes * 60;
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
        onTick(timeLeft);
      } else {
        timer.cancel();
        onComplete();
        showNotification('Hết giờ!', 'Thời gian tập trung đã kết thúc');
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}