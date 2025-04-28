import 'package:en_time/views/pages/auth/login_page.dart';
import 'package:en_time/views/pages/profile_page/privacy_policy_page.dart';
import 'package:en_time/views/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:en_time/components/colors.dart';
import 'package:en_time/database/services/Auth_Service.dart';

import 'change_password_page.dart';
import 'contact_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  final AuthService authService = AuthService();

  void _logout() async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryColor1,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: BasicAppbar(
        hideBack: true,
        title: Text(
          "Hồ sơ",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'matilda',
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          StreamBuilder<String>(
                            stream: authService.getCurrentUserName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  "Đang tải...",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }

                              final name = snapshot.data ?? "Người dùng";
                              return Text(
                                name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF92A3FD).withOpacity(0.6),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                        child: Text(
                          'Chỉnh sửa',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader('Tài khoản'),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      },
                    ),
                    _buildListTile(
                      icon: Icons.history,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                        );
                      },
                    ),
                    // _buildListTile(
                    //   icon: Icons.language,
                    //   title: 'Ngôn ngữ',
                    //   onTap: () {},
                    // ),
                    // _buildListTile(
                    //   icon: Icons.remove_red_eye_outlined,
                    //   title: 'Chế độ giao diện',
                    //   onTap: () {},
                    // ),
                  ],
                ),
              ),
              // _buildSectionHeader('Thông báo'),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20),
              //     color: Colors.white,
              //   ),
              //   child: _buildListTile(
              //     icon: Icons.notifications_none,
              //     title: 'Bật thông báo',
              //     trailing: Switch(
              //       value: _notificationsEnabled,
              //       onChanged: (value) {
              //         setState(() {
              //           _notificationsEnabled = value;
              //         });
              //       },
              //       activeColor: AppColors.secondaryColor1,
              //       activeTrackColor: AppColors.secondaryColor1.withOpacity(0.5),
              //     ),
              //   ),
              // ),
              _buildSectionHeader('Khác'),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.mail_outline,
                      title: 'Liên hệ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ContactPage()),
                        );
                      },
                    ),
                    _buildListTile(
                      icon: Icons.security,
                      title: 'Chính sách bảo mật',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                        );
                      },
                    ),
                    // _buildListTile(
                    //   icon: Icons.settings,
                    //   title: 'Cài đặt',
                    //   onTap: () {},
                    // ),
                  ],
                ),
              ),

              // 👉 Nút đăng xuất
              SizedBox(height: 30),
              Center(
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    "Đăng xuất",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
