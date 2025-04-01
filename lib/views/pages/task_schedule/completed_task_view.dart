import 'package:en_time/views/pages/task_schedule/task_schedule_view.dart';
import 'package:flutter/material.dart';

import '../../../components/colors.dart';
import '../../widgets/round_button.dart';


class CompletedTaskView extends StatefulWidget {
  const CompletedTaskView({super.key});

  @override
  State<CompletedTaskView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<CompletedTaskView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: media.width * 0.1),
              Image.asset(
                "assets/images/completed_task_view_image.png",
                width: media.width * 0.75,
                //fit: BoxFit.cover,
              ),
              SizedBox(height: media.width * 0.1),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Chúc mừng bạn đã xong công việc",
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Thời hạn không phải là tùy chọn, chúng là cam kết. Thành công đến với những ai tôn trọng chúng.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "-Jack LaLane-",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gray, fontSize: 12),
              ),
              const Spacer(),

              RoundButton(
                title: "Trở về",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScheduleView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
