import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final String? fcmToken;
  final DateTime? birthday; // Ngày sinh
  final String? gender;     // Giới tính

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.fcmToken, //
    this.birthday,
    this.gender,
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
    };
  }
}
