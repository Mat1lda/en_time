
import 'package:en_time/views/pages/auth/signup_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../components/colors.dart';
import '../../../database/services/Auth_Service.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/basic_app_buttons.dart';
import '../home/home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userName = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();

  bool isLoading = false;

  final AuthService authService =  AuthService();

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    String? result = await authService.signInWithEmail(
      email.text.trim(),
      password.text.trim(),
    );
    setState(() {
      isLoading = false;
    });

    if (result == "Đăng nhập thành công") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Có lỗi xảy ra!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: signUpText(context),
      appBar: BasicAppbar(
        title: Image.asset(
          "assets/images/appLogo.png",
          height: 130,
          width: 180,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery
              .of(context)
              .size
              .height * 0.01,
          horizontal: MediaQuery
              .of(context)
              .size
              .width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            signInText(),
            const SizedBox(height: 10),
            const Text(
              "Đăng nhập để quản lý thời gian của bạn",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 50),
            emailField(context),
            const SizedBox(height: 20),
            passwordField(context),
            const SizedBox(height: 50),
            BasicAppButton(onPressed: () {
              _login();
            }, title: "Đăng Nhập"),
          ],
        ),
      ),
    );
  }

  Widget signInText() {
    return const Text(
      "Đăng nhập",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget fullNameField(BuildContext context) {
    return TextField(
      controller: userName,
      decoration: const InputDecoration(
        hintText: "Tên tài khoản",
      ).applyDefaults(Theme
          .of(context)
          .inputDecorationTheme),
    );
  }

  Widget emailField(BuildContext context) {
    return TextField(
      controller: email,
      decoration: const InputDecoration(
        hintText: "Email",
      ).applyDefaults(Theme
          .of(context)
          .inputDecorationTheme),
    );
  }

  Widget passwordField(BuildContext context) {
    return TextField(
      controller: password,
      decoration: const InputDecoration(
        hintText: "Mật Khẩu",
      ).applyDefaults(Theme
          .of(context)
          .inputDecorationTheme),
    );
  }

  Widget signUpText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Đã có tài khoản? ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignupPage(),
                ),
              );
            },
            child: const Text(
              'Đăng ký',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}