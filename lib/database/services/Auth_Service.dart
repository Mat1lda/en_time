import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      print("🔍 Tìm email: $normalizedEmail");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("✅ Tìm thấy user: ${querySnapshot.docs.first.id}");
        return querySnapshot.docs.first;
      } else {
        print("⚠️ Không tìm thấy user với email: $normalizedEmail");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi khi tìm user theo email: $e");
      return null;
    }
  }

  Future<void> printAllUserEmails() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users')
        .get();
    for (var doc in querySnapshot.docs) {
      print("📧 User email: ${doc.get('email')}");
    }
  }

  // Đăng ký tài khoản và lưu vào Firestore
  Future<String?> signUpWithEmail(String fullName,
      String email,
      String password,) async {
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
          email: email.trim().toLowerCase(), // 👈 Bắt buộc chuẩn hóa khi lưu
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

// Future<String?> _getDisplayName() async {
//   final user = FirebaseAuth.instance.currentUser;
//   return user?.displayName;
// }

  Future<String> _getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await AuthService().getUserData(user.uid);
      return userData?.fullName ?? "Người dùng";
    }
    return "Khách";
    }
//
}