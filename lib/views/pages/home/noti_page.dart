import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/colors.dart';
import '../../../components/common_time.dart';
import 'package:rxdart/rxdart.dart';  // Add this import

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser!.uid; // Lấy userId của người dùng hiện tại

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/images/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Thông báo",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: CombineLatestStream.combine2(
          firestore
              .collection("scheduledNotifications")
              .where("sent", isEqualTo: true)
              .where("userId", isEqualTo: userId)
              .orderBy("notificationTime", descending: true)
              .snapshots(),
          firestore
              .collection("scheduledDeadlineNotifications")
              .where("sent", isEqualTo: true)
              .where("userId", isEqualTo: userId)
              .orderBy("notificationTime", descending: true)
              .snapshots(),
              (snapshot1, snapshot2) => [snapshot1, snapshot2],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          final notifications1 = snapshot.data?[0].docs ?? [];
          final notifications2 = snapshot.data?[1].docs ?? [];

          final allNotifications = [...notifications1, ...notifications2];

          if (allNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/completed_task_view_image.png",
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Không có thông báo nào",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sắp xếp thông báo theo thời gian
          allNotifications.sort((a, b) {
            final timeA = (a.data() as Map<String, dynamic>)["notificationTime"] as Timestamp;
            final timeB = (b.data() as Map<String, dynamic>)["notificationTime"] as Timestamp;
            return timeB.compareTo(timeA); // So sánh để hiển thị theo thứ tự thời gian giảm dần
          });

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: allNotifications.length,
            itemBuilder: (context, index) {
              final notification = allNotifications[index].data() as Map<String, dynamic>;
              final title = notification["title"] ?? "No Title";
              final taskId = notification["taskId"] ?? "Unknown Task";
              final notificationTime = (notification["notificationTime"] as Timestamp).toDate();
              final notificationId = allNotifications[index].id;
              final isScheduledNotification = allNotifications[index].reference.path.contains("scheduledNotifications");
              final notificationType = isScheduledNotification
                  ? "Thông báo hoạt động"
                  : "Thông báo deadline";
              final backgroundColor = isScheduledNotification
                  ? Colors.lightBlue.withOpacity(0.1) // cho task
                  : Colors.orange.withOpacity(0.1); // cho deadline
              final iconColor = isScheduledNotification ? Colors.blue : Colors.orange;
              final textColor = isScheduledNotification ? Colors.blue : Colors.orange;
              return Dismissible(
                key: Key(notificationId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  if (isScheduledNotification) {
                    await firestore.collection("scheduledNotifications").doc(notificationId).delete();
                  } else {
                    await firestore.collection("scheduledDeadlineNotifications").doc(notificationId).delete();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thông báo đã được xóa')),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    //color: Colors.white,
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: AppColors.primaryColor1,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notificationType,
                              style: TextStyle(
                                //color: AppColors.primaryColor1,
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Đã thông báo lúc: ${dateToString(notificationTime, formatStr: "dd/MM/yyyy HH:mm")}",
                              style: TextStyle(
                                color: AppColors.primaryColor1,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




