package com.example.en_time;

import io.flutter.embedding.android.FlutterActivity;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        createAlarmNotificationChannel();
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
}

