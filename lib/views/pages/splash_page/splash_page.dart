import 'package:en_time/components/colors.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../welcome_page/welcomePage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryG)
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset("assets/images/Group 18.png"),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset("assets/images/enTime.png"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const WelcomePage()));
  }
}
