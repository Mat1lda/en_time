const { Firestore } = require("@google-cloud/firestore");
const { GoogleAuth } = require("google-auth-library");
const axios = require("axios");
const cron = require("node-cron");
const express = require("express");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
require("dotenv").config(); // đầu file

const app = express();
const PORT = 8000;
app.use(express.json()); // đảm bảo body JSON được đọc
const serviceAccount = require('./serviceAccount.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

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
    console.log("⏳ Không có thông báo task nào cần gửi.");
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
        token: fcmTokens[fcmTokens.length - 1], // Gửi đến token cuối cùng
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
  console.log("\n🎉 Tất cả thông báo của task đã được xử lý.");
}

async function sendScheduledDeadlineNotifications() {
  const now = new Date();
  console.log(`\n⏰ Thời điểm hiện tại: ${now.toISOString()}`);
  console.log("📥 Đang tìm các thông báo deadline chưa gửi...");

  const snapshot = await firestore
    .collection("scheduledDeadlineNotifications")
    .where("sent", "==", false)
    .where("notificationTime", "<=", now)
    .get();

  if (snapshot.empty) {
    console.log("⏳ Không có thông báo deadline nào cần gửi.");
    return;
  }

  console.log(`🔔 Có ${snapshot.size} thông báo cần gửi.`);

  const accessToken = await getAccessToken();

  const tasks = snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const { userId, deadlineId, title, subject, notificationTime } = data;

    console.log(`\n📌 Đang xử lý deadlineId: ${deadlineId}`);
    console.log(`👤 userId: ${userId}`);
    console.log(`📚 subject: ${subject}`);
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
          title: "Nhắc nhở Deadline",
          body: `Môn ${subject}: ${title} đang đến gần!`,
        },
        token: fcmTokens[fcmTokens.length - 1],
        data: {
          deadlineId: deadlineId,
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

      console.log(`✅ Gửi thành công cho deadline: ${deadlineId}`, res.data);
      await doc.ref.update({ sent: true });
      console.log("🗂️ Đã cập nhật trạng thái `sent: true`");
    } catch (error) {
      const errData = error.response?.data || error.message;
      console.error(`❌ Gửi thất bại cho deadline: ${deadlineId}`, errData);
    }
  });

  await Promise.all(tasks);
  console.log("\n🎉 Tất cả thông báo deadline đã được xử lý.");
}
async function sendAlarmNotifications() {
  const now = new Date();
  const currentHour = now.getHours();
  const currentMinute = now.getMinutes();
  const currentWeekDay = (now.getDay() + 6) % 7; // 0=Monday, 6=Sunday (match WeekDay enum)

  console.log(`\n⏰ Giờ hiện tại: ${currentHour}:${currentMinute}, Thứ: ${currentWeekDay}`);

  const snapshot = await firestore
    .collection("alarms")
    .where("isEnabled", "==", true)
    .get();

  if (snapshot.empty) {
    console.log("⏳ Không có alarm nào đang bật.");
    return;
  }

  console.log(`🔔 Có ${snapshot.size} alarm đang bật.`);

  const accessToken = await getAccessToken();

  const tasks = snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const { userId, alarmName, time, repeatDays } = data;

    const [alarmHour, alarmMinute] = time.split(":").map(Number);
    const isTodayEnabled = repeatDays?.[currentWeekDay.toString()] === true;

    // Check time match and repeat condition
    if (alarmHour !== currentHour || alarmMinute !== currentMinute || !isTodayEnabled) {
      console.log(`⏭️ Bỏ qua alarm '${alarmName}' - chưa đến giờ hoặc không lặp hôm nay.`);
      return;
    }

    console.log(`\n📌 Gửi alarm: ${alarmName} cho user: ${userId}`);

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

    const latestToken = fcmTokens[fcmTokens.length - 1];

    const message = {
      message: {
        notification: {
          title: "⏰ Báo thức",
          body: `Đến giờ: ${alarmName}`,
        },
        token: latestToken,
         android: {
              priority: "HIGH",
              notification: {
                channelId: "alarm_channel",  // trùng với tên đã tạo ở bước 2
                sound: "alarm_sound",        // không có .mp3, tên file trong /raw
              },
            },
        data: {
          alarmId: doc.id,
        },
      },
    };

    try {
      console.log(`🚀 Gửi notification tới token: ${latestToken.slice(0, 20)}...`);
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

      console.log(`✅ Gửi thành công alarm: ${alarmName}`, res.data);
    } catch (error) {
      const errData = error.response?.data || error.message;
      console.error(`❌ Gửi thất bại cho alarm: ${alarmName}`, errData);
    }
  });

  await Promise.all(tasks);
  console.log("\n🎉 Tất cả alarm đã được xử lý.");
}

 📅 Chạy cron job mỗi phút
cron.schedule("* * * * *", () => {
  console.log("🔁 Cron job chạy: kiểm tra notification");
  sendScheduledNotifications();
  sendScheduledDeadlineNotifications();
  sendAlarmNotifications();
});

app.post("/send-email-password", async (req, res) => {
  const { email, password } = req.body;
      console.log('da vao day')
  if (!email || !password) {
    return res.status(400).json({ message: "Thiếu email hoặc password!" });
  }
    const userRecord = await admin.auth().getUserByEmail(email);

    // Cập nhật mật khẩu trong Firebase Auth
    await admin.auth().updateUser(userRecord.uid, { password });

  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USERNAME, // từ .env
        pass: process.env.EMAIL_PASSWORD,
      },
    });

    const mailOptions = {
      from: `"EnTime" <${process.env.EMAIL_USERNAME}>`,
      to: email,
      subject: "🔐 Mật khẩu mới của bạn",
      html: `
        <p>Chào bạn,</p>
        <p>Mật khẩu mới của bạn là:</p>
        <h2 style="color:#333;">${password}</h2>
        <p>Hãy đăng nhập và thay đổi mật khẩu ngay nhé.</p>
        <br/>
        <p>Thân mến,<br/>Đội ngũ EnTime</p>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ Đã gửi email chứa password tới ${email}`);
    res.status(200).json({ message: "Email đã được gửi." });
  } catch (error) {
    console.error("❌ Lỗi gửi email:", error);
    res.status(500).json({ message: "Gửi email thất bại.", error: error.toString() });
  }
});


// 🚀 Start server
app.get("/", (req, res) => {
  res.send("✅ FCM Notification Service đang chạy!");
});

app.listen(PORT, () => {
  console.log(`🌐 Server đang chạy tại http://localhost:${PORT}`);
});
