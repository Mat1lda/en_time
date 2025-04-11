const { Firestore } = require("@google-cloud/firestore");
const { GoogleAuth } = require("google-auth-library");
const axios = require("axios");
const cron = require("node-cron");
const express = require("express");

const app = express();
const PORT = 8000;

// 🔑 Khởi tạo Firestore với Service Account
const firestore = new Firestore({
  keyFilename: "serviceAccount.json",
  projectId: "entime-7d0c6",
});

// 🔐 Lấy access token để gọi FCM REST API
async function getAccessToken() {
  console.log("🔐 Đang lấy access token từ GoogleAuth...");
  const auth = new GoogleAuth({
    keyFile: "serviceAccount.json",
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });

  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  console.log("✅ Lấy access token thành công.");
  return tokenResponse.token;
}

// 🚀 Gửi notification cho các scheduledNotifications đến giờ
async function sendScheduledNotifications() {
  const now = new Date();
  console.log(`\n⏰ Thời điểm hiện tại: ${now.toISOString()}`);
  console.log("📥 Đang tìm các thông báo chưa gửi...");

  const snapshot = await firestore
      .collection("scheduledNotifications")
      .where("sent", "==", false)
      .where("notificationTime", "<=", now)
      .get();

  if (snapshot.empty) {
    console.log("⏳ Không có thông báo nào cần gửi.");
    return;
  }

  console.log(`🔔 Có ${snapshot.size} thông báo cần gửi.`);

  const accessToken = await getAccessToken();

  const tasks = snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const { userId, taskId, title, notificationTime } = data;

    console.log(`\n📌 Đang xử lý taskId: ${taskId}`);
    console.log(`👤 userId: ${userId}`);
    console.log(`🕒 notificationTime: ${notificationTime.toDate().toLocaleString()}`);
    console.log(`📝 title: ${title}`);

    const userDoc = await firestore.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      console.warn(`⚠️ Không tìm thấy user: ${userId}`);
      return;
    }

    const fcmTokens = userDoc.data()?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      console.warn(`⚠️ User ${userId} không có FCM token.`);
      return;
    }

    console.log(`📨 Số lượng FCM token: ${fcmTokens.length}`);

    const message = {
      message: {
        notification: {
          title: "Nhắc nhở",
          body: `Nhiệm vụ "${title}" sẽ bắt đầu sau 10 phút!`,
        },
        token: fcmTokens[0], // Gửi token đầu tiên
        data: {
          taskId: taskId,
        },
      },
    };

    try {
      console.log(`🚀 Gửi notification tới token: ${fcmTokens[0].slice(0, 20)}...`);
      const res = await axios.post(
          `https://fcm.googleapis.com/v1/projects/entime-7d0c6/messages:send`,
          message,
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
          }
      );

      console.log(`✅ Gửi thành công cho task: ${taskId}`, res.data);
      await doc.ref.update({ sent: true });
      console.log("🗂️ Đã cập nhật trạng thái `sent: true`");
    } catch (error) {
      const errData = error.response?.data || error.message;
      console.error(`❌ Gửi thất bại cho task: ${taskId}`, errData);
    }
  });

  await Promise.all(tasks);
  console.log("\n🎉 Tất cả thông báo đã được xử lý.");
}

// 📅 Chạy cron job mỗi phút
cron.schedule("* * * * *", () => {
  console.log("🔁 Cron job chạy: kiểm tra notification");
  sendScheduledNotifications();
});

// 🚀 Start server
app.get("/", (req, res) => {
  res.send("✅ FCM Notification Service đang chạy!");
});

app.listen(PORT, () => {
  console.log(`🌐 Server đang chạy tại http://localhost:${PORT}`);
});
