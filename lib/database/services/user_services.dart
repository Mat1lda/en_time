import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../models/User_Model.dart'; // Import UserModel nếu bạn để ở models/

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  /// Cập nhật toàn bộ thông tin người dùng
  Future<void> updateUser({
    String? fullName,
    String? email,
    DateTime? birthday,
    String? gender,
    String? fcmToken,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> updatedData = {};

      if (fullName != null) updatedData['fullName'] = fullName;
      if (email != null) updatedData['email'] = email;
      if (birthday != null) updatedData['birthday'] = birthday;
      if (gender != null) updatedData['gender'] = gender;
      if (fcmToken != null) updatedData['fcmToken'] = fcmToken;

      if (updatedData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updatedData);
      }
    }
  }

  /// Cập nhật từng trường riêng biệt nếu cần
  Future<void> updateFullName(String fullName) async {
    await updateUser(fullName: fullName);
  }

  Future<void> updateBirthday(DateTime birthday) async {
    await updateUser(birthday: birthday);
  }

  Future<void> updateGender(String gender) async {
    await updateUser(gender: gender);
  }

  Future<void> updateEmail(String email) async {
    await updateUser(email: email);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await updateUser(fcmToken: fcmToken);
  }
}
