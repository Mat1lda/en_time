const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");
const { DateTime } = require("luxon"); // 📦 Xử lý ngày giờ mạnh mẽ

initializeApp();

// 🔔 Khi task mới được tạo, lưu thông báo vào Firestore
exports.scheduleTaskNotification = onDocumentCreated("tasks/{taskId}", async (event) => {
  const snap = event.data;
  const context = event.params;

  if (!snap) {
    logger.warn("No snapshot data found.");
    return;
  }

  const task = snap.data();
  const taskId = context.taskId;
  const userId = task.userId;

  try {
    const dayString = task.day;           // e.g. "2025-04-09T16:52:17.006457"
    const timeStart = task.timeStart;     // e.g. "04:07 PM"

    if (!dayString || !timeStart) {
      logger.error("❌ Thiếu thông tin ngày hoặc thời gian bắt đầu:", task);
      return;
    }

    // Parse ISO string và tách giờ/phút từ timeStart (AM/PM)
    const baseDate = DateTime.fromISO(dayString, { zone: "Asia/Ho_Chi_Minh" });
    const match = timeStart.match(/(\d+):(\d+)\s*(AM|PM)/i);

    if (!match) {
      logger.error("❌ Định dạng giờ không hợp lệ:", timeStart);
      return;
    }

    let [_, hour, minute, ampm] = match;
    hour = parseInt(hour, 10);
    minute = parseInt(minute, 10);

    if (ampm.toUpperCase() === "PM" && hour !== 12) hour += 12;
    if (ampm.toUpperCase() === "AM" && hour === 12) hour = 0;

    const taskStartTime = baseDate.set({ hour, minute, second: 0 });

    if (!taskStartTime.isValid) {
      logger.error("❌ Không thể tạo thời điểm taskStartTime:", taskStartTime.invalidExplanation);
      return;
    }

    const notificationTime = taskStartTime.minus({ minutes: 10 }).toJSDate();

    await getFirestore().collection("scheduledNotifications").add({
      taskId,
      userId,
      title: task.content,
      notificationTime: Timestamp.fromDate(notificationTime),
      sent: false,
    });

    logger.info(`✅ Đã lưu scheduled notification cho task: ${taskId}`);
  } catch (error) {
    logger.error("❌ Lỗi khi xử lý scheduleTaskNotification:", error);
  }
});

// 🕐 Gửi thông báo mỗi phút
exports.sendScheduledNotifications = onSchedule("every 1 minutes", async () => {
  const db = getFirestore();
  const now = Timestamp.now();

  try {
    const snapshot = await db.collection("scheduledNotifications")
      .where("sent", "==", false)
      .where("notificationTime", "<=", now)
      .get();

    if (snapshot.empty) {
      logger.info("⏳ Không có thông báo nào cần gửi lúc này.");
      return;
    }

    const batch = db.batch();

    const sendPromises = snapshot.docs.map(async (doc) => {
      const notificationId = doc.id;
      const data = doc.data();
      const { userId, taskId, title } = data;

      try {
        const userDoc = await db.collection("users").doc(userId).get();
        const fcmTokens = userDoc.data()?.fcmTokens || [];

        if (fcmTokens.length === 0) {
          logger.info("⚠️ Không có FCM token cho user:", userId);
          return;
        }
        // ✅ Gửi bằng sendMulticast để tránh lỗi `/batch`
        const response = await getMessaging().sendMulticast({
          tokens: fcmTokens,
          notification: {
            title: "Nhắc nhở",
            body: `Nhiệm vụ "${title}" sẽ bắt đầu sau 10 phút!`,
          },
          data: {
            taskId: taskId,
          },
        });
over
        logger.info(`🔔 Gửi ${response.successCount}/${fcmTokens.length} thông báo thành công cho task: ${taskId}`);

        batch.update(doc.ref, { sent: true });

        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            logger.warn(`❌ Token lỗi (user ${userId}): ${fcmTokens[idx]}`, resp.error);
          }
        });

      } catch (error) {
        logger.error(`❌ Lỗi khi gửi notification [${notificationId}] cho task ${taskId}:`, error);
      }
    });

    for (const sendPromise of sendPromises) {
      await sendPromise;
    }

    await batch.commit();
    logger.info("✅ Đã xử lý và cập nhật tất cả các thông báo cần gửi.");

  } catch (error) {
    logger.error("🔥 Lỗi trong hàm sendScheduledNotifications:", error);
  }
});
