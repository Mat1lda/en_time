package com.example.en_time;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import androidx.core.app.NotificationCompat;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.en_time/timer";
    private static final String TIMER_CHANNEL_ID = "timer_channel";
    private static final int NOTIFICATION_ID = 1;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        createAlarmNotificationChannel();
        createTimerNotificationChannel();
        
        // Set up method channel for timer notifications
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("showNotification")) {
                        String title = call.argument("title");
                        String message = call.argument("message");
                        showTimerNotification(title, message);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private void createAlarmNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Uri soundUri = Uri.parse("android.resource://" + getPackageName() + "/raw/alarm_sound");

            AudioAttributes attributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build();

            NotificationChannel channel = new NotificationChannel(
                    "alarm_channel", // ID phải khớp với cái bạn gửi từ FCM
                    "Kênh báo thức",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Dành riêng cho thông báo báo thức");
            channel.enableVibration(true);
            channel.setVibrationPattern(new long[]{0, 1000, 1000, 1000, 1000, 1000});
            channel.setSound(soundUri, attributes);

            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            manager.createNotificationChannel(channel);
        }
    }

    private void createTimerNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    TIMER_CHANNEL_ID,
                    "Timer Notifications",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Timer completion notifications");
            channel.enableVibration(true);
            channel.setVibrationPattern(new long[]{0, 500, 500, 500});

            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            manager.createNotificationChannel(channel);
        }
    }

    private void showTimerNotification(String title, String message) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, TIMER_CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setVibrate(new long[]{0, 500, 500, 500});

        NotificationManager notificationManager = 
            (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(NOTIFICATION_ID, builder.build());
    }
}

