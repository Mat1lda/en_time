import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/colors.dart';
import '../../../database/services/Auth_Service.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/basic_app_buttons.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget{

  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController fullName = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();

  final AuthService _authService = AuthService();
  bool isLoading = false;

  void _signUp() async {
    setState(() {
      isLoading = true;
    });

    String? result = await _authService.signUpWithEmail(
      fullName.text.trim(),
      email.text.trim(),
      password.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (result == "Đăng ký thành công") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Có lỗi xảy ra!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: signInText(context),
      appBar: BasicAppbar(
        title: Image.asset(
          "assets/images/appLogo.png",
          height: 130,
          width: 180,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            registerText(),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Đăng ký để quản lý thời gian của bạn",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            fullNameField(context),
            const SizedBox(
              height: 20,
            ),
            emailField(context),
            const SizedBox(
              height: 20,
            ),
            passwordField(context),
            const SizedBox(
              height: 50,
            ),
            isLoading? const CircularProgressIndicator():
            BasicAppButton(
                onPressed: () {
                  _signUp();
                  // async {
                  //   var result = await sl<SignupUseCase>().call(
                  //       params: CreateUserReq(
                  //         fullName: fullName.text.toString(),
                  //         email: email.text.toString(),
                  //         password: password.text.toString(),
                  //       ));
                  //   result.fold((l) {
                  //     var snackbar = SnackBar(
                  //       content: Text(l),
                  //       behavior: SnackBarBehavior.floating,
                  //     );
                  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  //   }, (r) {
                  //     var snackbar = SnackBar(
                  //       content: Text(r),
                  //       behavior: SnackBarBehavior.floating,
                  //     );
                  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  //     Navigator.pushAndRemoveUntil(
                  //         context,
                  //         MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (route) => false
                  //     );
                  //   });
                },
                title: "Đăng Ký"),
            const SizedBox(
              height: 60,
            ),
            //sigInText(context)
          ],
        ),
      ),
    );
  }

  Widget registerText() {
    return const Text(
      "Đăng Ký",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget fullNameField(BuildContext context) {
    return TextField(
      controller: fullName,
      decoration: const InputDecoration(hintText: "Tên tài khoản")
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget emailField(BuildContext context) {
    return TextField(
      controller: email,
      decoration: const InputDecoration(hintText: "Email")
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget passwordField(BuildContext context) {
    return TextField(
      controller: password,
      decoration: const InputDecoration(hintText: "Mật khẩu")
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget signInText(BuildContext context) {
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
                      builder: (BuildContext context) => LoginPage()));
            },
            child: const Text('Đăng Nhập', style: TextStyle(color: AppColors.primary),),)
        ],
      ),
    );
  }
}