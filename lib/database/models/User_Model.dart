import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final String? fcmToken;
  final DateTime? birthday; // Ngày sinh
  final String? gender;     // Giới tính
  final String? avatarUrl; // 👈 Thêm dòng này

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.fcmToken, //
    this.birthday,
    this.gender,
    this.avatarUrl, // 👈 Thêm trong constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      fullName: json['fullName'],
      email: json['email'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      fcmToken: json['fcmToken'], // map từ JSON
      birthday: json['birthday'] != null
          ? (json['birthday'] as Timestamp).toDate()
          : null,
      gender: json['gender'],
      avatarUrl: json['avatarUrl'], // 👈 Thêm dòng map từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt,
      'fcmToken': fcmToken, // ghi vào Firestore
      'birthday': birthday,
      'gender': gender,
      'avatarUrl': avatarUrl, // 👈 Thêm khi ghi Firestore
    };
  }
}
