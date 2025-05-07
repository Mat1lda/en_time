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
  console.log("\n🎉 Tất cả thông báo của task -10 đã được xử lý.");
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

// Thêm hàm này để gửi email cho các task khẩn cấp

async function sendCriticalTaskStartEmail() {
  const now = new Date();
  console.log(`\n⏰ Thời điểm hiện tại: ${now.toISOString()}`);
  console.log("📥 Đang tìm thông báo task khẩn cấp...");

  // Tìm các thông báo scheduledNotifications chưa gửi và đến thời gian thông báo
  const snapshot = await firestore
    .collection("scheduledNotifications")
    .where("sent", "==", false)
    .where("notificationTime", "<=", now)
    .get();

  if (snapshot.empty) {
    console.log("⏳ Không có thông báo task khẩn cấp nào cần kiểm tra.");
    return;
  }

  const tasks = snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const { userId, taskId, title, notificationTime } = data;

    // Lấy thông tin task để kiểm tra xem nó có phải là task khẩn cấp không
    const taskDoc = await firestore.collection("tasks").doc(taskId).get();
    if (!taskDoc.exists) {
      console.warn(`⚠️ Không tìm thấy task: ${taskId}`);
      return;
    }

    const taskData = taskDoc.data();
    // Kiểm tra xem task có phải là mức độ ưu tiên khẩn cấp (priority = 0) không
    // Trong TaskModel, TaskPriority.critical có index là 0
    if (taskData.priority !== 0) {  // 0 là giá trị của TaskPriority.critical
      console.log(`⏭️ Task ${taskId} không phải là task khẩn cấp.`);
      return;
    }

    console.log(`\n📌 Đang xử lý task KHẨN CẤP: ${taskId}`);
    console.log(`👤 userId: ${userId}`);
    console.log(`🕒 notificationTime: ${notificationTime.toDate().toLocaleString()}`);
    console.log(`📝 title: ${title}`);
    console.log(`🔥 priority: ${taskData.priority} (Khẩn cấp)`);
    
    // Lấy thông tin user để lấy email
    const userDoc = await firestore.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.warn(`⚠️ Không tìm thấy user: ${userId}`);
      return;
    }

    const userData = userDoc.data();
    const email = userData.email;

    if (!email) {
      console.warn(`⚠️ User ${userId} không có email.`);
      return;
    }

    // Kiểm tra xem email này đã được gửi chưa
    const emailLogSnapshot = await firestore
      .collection("criticalTaskEmailLogs")
      .where("taskId", "==", taskId)
      .get();

    if (!emailLogSnapshot.empty) {
      console.log(`⏭️ Đã gửi email trước đó cho task khẩn cấp: ${taskId}`);
      return;
    }

    console.log(`📧 Chuẩn bị gửi email cho task khẩn cấp tới: ${email}`);

    // Format ngày và giờ
    const taskDate = taskData.day ? new Date(taskData.day) : new Date();
    const formattedDate = taskDate.toLocaleDateString('vi-VN');
    
    try {
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USERNAME,
          pass: process.env.EMAIL_PASSWORD,
        },
      });
      const mailOptions = {
        from: `"EnTime" <${process.env.EMAIL_USERNAME}>`,
        to: email,
        subject: "🚨 CẢNH BÁO: Nhiệm vụ KHẨN CẤP sắp bắt đầu!",
        html: `
          <div style="background-color: #f5f5f5; padding: 20px; font-family: Arial, sans-serif;">
            <div style="background-color: #ffffff; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
              <h2 style="color:#e53935; margin-top: 0;">⚠️ NHIỆM VỤ KHẨN CẤP SẮP BẮT ĐẦU</h2>
              <p>Chào bạn,</p>
              <p>Bạn có một nhiệm vụ <strong style="color: red;">KHẨN CẤP</strong> sắp bắt đầu trong 10 phút nữa:</p>
              <div style="background-color: #ffebee; padding: 15px; border-left: 4px solid #e53935; margin: 15px 0;">
                <p style="margin: 0; font-size: 16px;"><strong>${title}</strong></p>
                <p style="margin: 5px 0 0;">⏰ Ngày: ${formattedDate} - Thời gian: ${taskData.timeStart}</p>
              </div>
              <p>Vui lòng chuẩn bị để thực hiện nhiệm vụ này. Đây là nhiệm vụ với mức độ ưu tiên cao nhất.</p>
              <p>Mở ứng dụng EnTime để xem chi tiết và quản lý nhiệm vụ của bạn!</p>
              <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="color: #757575; font-size: 13px;">Đây là email tự động. Vui lòng không trả lời email này.</p>
              <p style="color: #757575; font-size: 13px;">Thân mến,<br/>Đội ngũ EnTime</p>
            </div>
          </div>
        `,
      };

      await transporter.sendMail(mailOptions);
      console.log(`✅ Đã gửi email về task khẩn cấp tới ${email}`);

      // Lưu lại thông tin đã gửi email để tránh gửi lại nhiều lần
      await firestore.collection("criticalTaskEmailLogs").add({
        taskId: taskId,
        userId: userId,
        email: email,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
    } catch (error) {
      console.error(`❌ Lỗi gửi email về task khẩn cấp cho ${email}:`, error);
    }
  });

  await Promise.all(tasks);
  console.log("\n🎉 Tất cả email về task khẩn cấp đã được xử lý.");
}

// Thêm vào cron job đã có
cron.schedule("* * * * *", () => {
  console.log("🔁 Cron job chạy: kiểm tra notification");
  sendScheduledNotifications();
  sendScheduledDeadlineNotifications();
  sendAlarmNotifications();
  sendCriticalTaskStartEmail(); // Thêm dòng này
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