import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en_time/database/services/Auth_Service.dart';
import 'package:en_time/views/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../components/colors.dart';
import '../../widgets/basic_app_buttons.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // 🔐 Tạo mật khẩu ngẫu nhiên
  String generateRandomPassword({int length = 8}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%^&*!';
    Random rnd = Random.secure();
    return List.generate(length, (index) => chars[rnd.nextInt(chars.length)]).join();
  }

  // 📧 Gửi mật khẩu mới qua API Node.js
  Future<void> sendEmailWithNewPassword(String email, String password) async {
    final baseUrl = kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000"; // cho emulator
    final url = Uri.parse("$baseUrl/send-email-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gửi email thất bại: ${response.body}");
    }
  }

  // 🔁 Reset mật khẩu
  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập email")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔍 Tìm user theo email
      final userDoc = await AuthService().getUserByEmail(email);
      if (userDoc == null) throw Exception("Không tìm thấy tài khoản với email đã nhập.");

      final newPassword = generateRandomPassword();
      final uid = userDoc.id;

      // 🔄 Cập nhật mật khẩu tạm thời vào Firestore
      await _firestore.collection("users").doc(uid).update({
        "newPasswordRequested": true,
        "tempPassword": newPassword,
        "resetAt": DateTime.now(),
        "password": newPassword, // 👈 thêm dòng này nếu bạn lưu mật khẩu dạng plain-text (hoặc hash)
      });


      // 📧 Gửi email
      await sendEmailWithNewPassword(email, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔐 Mật khẩu mới đã được gửi đến email của bạn")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Text("Đổi mật khẩu", style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Nhập email để đặt lại mật khẩu mới", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : BasicAppButton(
              onPressed: resetPassword,
              title: "Xác nhận",
            ),
          ],
        ),
      ),
    );
  }
}
