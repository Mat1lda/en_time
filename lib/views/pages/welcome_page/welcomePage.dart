
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../components/colors.dart';
import '../../widgets/basic_app_buttons.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: signinText(context),
      body: Stack(
        children: [
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          //   decoration: const BoxDecoration(
          //       image: DecorationImage(
          //           fit: BoxFit.fill,
          //           image: AssetImage(
          //             "assets/images/bgImage.jpg",
          //           ))),
          // ),
          // Container(
          //   color: Colors.black.withOpacity(0.15),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset("assets/images/appLogo.png"),
                ),
                Spacer(),
                const Padding(
                  padding: EdgeInsets.all(1),
                  child: Text(
                    'Giữ vững tiến độ cùng EnTime',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 21,
                ),
                const Text(
                  'Hãy quản lý thời gian hiệu quả, giảm căng thẳng, nâng cao năng suất, sắp xếp công việc thông minh, làm chủ lịch trình mỗi ngày',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                      fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 100,
                ),
                BasicAppButton(
                    height: 70,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => LoginPage()));
                    },
                    title: 'Đăng Nhập'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chưa có tài khoản',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
              onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage(),));
              },
              child: const Text(
                "Đăng ký ngay",
                style: TextStyle(color: AppColors.primary),
              ))
        ],
      ),
    );
  }
}
