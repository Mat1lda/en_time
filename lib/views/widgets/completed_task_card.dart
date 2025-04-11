import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../components/colors.dart';
import '../../database/models/task_model.dart';
import '../../components/common_time.dart';

class CompletedTaskCard extends StatelessWidget {
  final TaskModel task;
  const CompletedTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          children: [
            ClipRRect(
              child: Image.asset(
                task.taskType == "Hoạt động cá nhân" 
                  ? "assets/images/personal-activity.png"
                  : "assets/images/extracurricular-activities.png",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.content,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Bắt đầu: ${task.timeStart} ${dateToString(task.day, formatStr: "dd/MM/yyyy")}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}