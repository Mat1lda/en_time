import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký tài khoản và lưu vào Firestore
  Future<String?> signUpWithEmail(
      String fullName,
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        // Dùng model để lưu dữ liệu vào Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          fullName: fullName,
          email: email,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection("users")
            .doc(user.uid)
            .set(newUser.toJson());

        return "Đăng ký thành công";
      }
      return "Không thể đăng ký, vui lòng thử lại!";
    } on FirebaseAuthException catch (e) {
      return e.message; // Lỗi Firebase
    } catch (e) {
      return "Có lỗi xảy ra. Vui lòng thử lại!";
    }
  }

  // Lấy thông tin user từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Lỗi khi tải dữ liệu người dùng: $e");
      return null;
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      print("📩 Đăng nhập với Email: $email");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Đăng nhập thành công: ${userCredential.user?.email}");
      return "Đăng nhập thành công";
    } on FirebaseAuthException catch (e) {
      print("❌ Lỗi Firebase: ${e.code} - ${e.message}");
      return e.message;
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      return "Có lỗi xảy ra!";
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}