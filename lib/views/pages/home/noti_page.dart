import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("scheduledNotifications")
            .where("sent", isEqualTo: true)
            .orderBy("notificationTime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text("No notifications available."),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final title = notification["title"] ?? "No Title";
              final taskId = notification["taskId"] ?? "Unknown Task";
              final notificationTime = (notification["notificationTime"] as Timestamp).toDate();

              return ListTile(
                title: Text(title),
                subtitle: Text("Task ID: $taskId\nTime: $notificationTime"),
                leading: const Icon(Icons.notifications),
              );
            },
          );
        },
      ),
    );
  }
}