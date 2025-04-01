
import 'package:en_time/views/pages/auth/signup_page.dart';
import 'package:en_time/views/pages/main_tab/tab_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../components/colors.dart';
import '../../../database/services/Auth_Service.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/basic_app_buttons.dart';



class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading = false;

  final AuthService authService =  AuthService();

  bool isValidEmail(String email) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  FormFieldValidator<String> validateEmail = (value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    } else if (!RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  };

  FormFieldValidator<String> validatePassword = (value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  };

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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Đăng nhập thành công!")),
      // );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainTabView()),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
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
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: "nhập Email",
        labelText: "Email",
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        filled: true,
        errorStyle: const TextStyle(color: Colors.redAccent),
        //contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        fillColor: Colors.white,
      ),
      validator: validateEmail,
    );
  }

  Widget passwordField(BuildContext context) {
    return TextFormField(
      controller: password,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: " Nhập mật khẩu",
        labelText: 'Mật khẩu',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: validatePassword,
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