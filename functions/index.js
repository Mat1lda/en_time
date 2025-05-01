const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");
const { DateTime } = require("luxon"); // 📦 Xử lý ngày giờ mạnh mẽ
const { onDocumentDeleted } = require('firebase-functions/v2/firestore');

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

exports.deadlineNotification = onDocumentCreated("deadlines/{deadlineId}", async (event) => {
  const snap = event.data;
  const context = event.params;

  if (!snap) {
    logger.warn("No snapshot data found.");
    return;
  }

  const deadline = snap.data();
  const deadlineId = context.deadlineId;
  const userId = deadline.userId;

  try {
    const timeEndRaw = deadline.timeEnd;
    const dayRaw = deadline.day;
    const deadlineName = deadline.deadlineName || "Deadline";

    // ✅ Bỏ qua nếu deadline đã hoàn thành
    if (deadline.isDone === true) {
      logger.info(`⛔ Bỏ qua: Deadline ${deadlineId} đã hoàn thành (isDone = true)`);
      return;
    }

    if (!timeEndRaw || !dayRaw) {
      logger.error("❌ Thiếu timeEnd hoặc day:", deadline);
      return;
    }

    const timeEnd = DateTime.fromISO(timeEndRaw, { zone: "Asia/Ho_Chi_Minh" });
    const day = DateTime.fromISO(dayRaw, { zone: "Asia/Ho_Chi_Minh" });

    if (!timeEnd.isValid || !day.isValid) {
      logger.error("❌ Không thể phân tích timeEnd hoặc day:", { timeEndRaw, dayRaw });
      return;
    }

    const notifyAt = timeEnd.minus({ hours: 12 });
    const now = DateTime.now().setZone("Asia/Ho_Chi_Minh");

    // ✅ Nếu notification time đã trôi qua, không lưu
    if (notifyAt < now) {
      logger.info(`⏩ Bỏ qua: notificationTime (${notifyAt.toISO()}) đã qua hiện tại (${now.toISO()})`);
      return;
    }

    await getFirestore().collection("scheduledDeadlineNotifications").add({
      deadlineId,
      userId,
      title: `Sắp đến hạn: ${deadlineName}`,
      subject: deadline.subject || "Chưa rõ môn",
      notificationTime: Timestamp.fromDate(notifyAt.toJSDate()),
      sent: false,
      type: "deadline",
    });

    logger.info(`✅ Đã lưu scheduled notification cho deadline: ${deadlineId}`);
  } catch (error) {
    logger.error("❌ Lỗi khi xử lý deadlineNotification:", error);
  }
});

// Lắng nghe sự kiện xóa deadline
exports.onDeadlineDeleted = onDocumentDeleted("deadlines/{deadlineId}", async (event) => {
  const context = event.params;
  const deadlineId = context.deadlineId;

  try {
    // Tìm các bản ghi trong "scheduledDeadlineNotifications" có deadlineId trùng với deadlineId đã xóa
    const notificationsSnapshot = await getFirestore()
      .collection("scheduledDeadlineNotifications")
      .where("deadlineId", "==", deadlineId)
      .get();

    // Nếu có các thông báo liên quan, xóa chúng
    if (!notificationsSnapshot.empty) {
      const batch = getFirestore().batch();

      // Duyệt qua tất cả các thông báo và xóa
      notificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Commit tất cả các thay đổi xóa trong batch
      await batch.commit();
      logger.info(`✅ Đã xóa tất cả các scheduledDeadlineNotifications có deadlineId: ${deadlineId}`);
    } else {
      logger.info(`⛔ Không tìm thấy scheduledDeadlineNotifications có deadlineId: ${deadlineId}`);
    }
  } catch (error) {
    logger.error("❌ Lỗi khi xử lý xóa scheduledDeadlineNotifications:", error);
  }
});
