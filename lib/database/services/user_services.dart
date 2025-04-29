import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


import '../models/User_Model.dart'; // Import UserModel nếu bạn để ở models/

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> updatedData = {};

      if (fullName != null) updatedData['fullName'] = fullName;
      if (email != null) updatedData['email'] = email;
      if (birthday != null) updatedData['birthday'] = birthday;
      if (gender != null) updatedData['gender'] = gender;
      if (fcmToken != null) updatedData['fcmToken'] = fcmToken;
      if (avatarUrl != null) updatedData['avatarUrl'] = avatarUrl;

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

  Future<String?> pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Chọn ảnh và giảm dung lượng
      if (pickedFile == null) return null;

      File file = File(pickedFile.path);
      String uid = _auth.currentUser!.uid;

      // Upload file lên Firebase Storage
      final ref = _storage.ref().child('avatars').child('$uid.jpg');
      await ref.putFile(file);

      // Lấy URL của ảnh
      final avatarUrl = await ref.getDownloadURL();

      // Cập nhật Firestore user profile
      await _firestore.collection('users').doc(uid).update({
        'avatarUrl': avatarUrl,
      });

      return avatarUrl; // Trả về URL avatar mới
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // Upload avatar lên Firebase Storage
  Future<String?> uploadAvatar(File avatarFile) async {
    try {
      // Lấy userId từ FirebaseAuth (ID người dùng hiện tại)
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Tạo đường dẫn lưu trữ ảnh trong Firebase Storage
      String filePath = 'avatars/$userId.jpg';

      // Tạo tham chiếu đến file trong Firebase Storage
      final storageRef = _storage.ref().child(filePath);

      // Upload ảnh lên Firebase Storage
      await storageRef.putFile(avatarFile);

      // Lấy URL của ảnh đã upload
      String avatarUrl = await storageRef.getDownloadURL();

      return avatarUrl; // Trả về URL ảnh
    } catch (e) {
      print('Error uploading avatar: $e');
      return null; // Trả về null nếu gặp lỗi
    }
  }

  /// Hàm tải thông tin người dùng từ Firestore
  Future<Map<String, dynamic>> loadUserData(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data() ?? {};
  }

  /// Cập nhật thông tin người dùng và ảnh đại diện
  Future<void> saveProfile(
      String newName,
      DateTime? newBirthday,
      String? newGender,
      File? newAvatarFile) async {
    String? avatarUrl;

    if (newAvatarFile != null) {
      // Upload avatar mới lên Firebase Storage
      avatarUrl = await uploadAvatar(newAvatarFile);
    }

    await updateUser(
      fullName: newName,
      birthday: newBirthday,
      gender: newGender,
      avatarUrl: avatarUrl, // Chỉ cập nhật avatarUrl nếu có thay đổi
    );
  }
}
