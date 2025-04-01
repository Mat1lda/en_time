
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
  bool _isPasswordVisible = false;
  bool isLoading = false;

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
      decoration: const InputDecoration(
        hintText: "nhập tên tài khoản",
        labelText: "Tên tài khoản",
        prefixIcon: const Icon(Icons.person, color: Colors.grey),
        filled: true,
        errorStyle: const TextStyle(color: Colors.redAccent),
        //contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        fillColor: Colors.white,
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