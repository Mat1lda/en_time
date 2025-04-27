import 'package:flutter/material.dart';
import 'package:en_time/components/colors.dart';
import 'package:en_time/database/models/task_model.dart';
import 'package:en_time/database/services/task_services.dart';
import 'package:en_time/components/common_time.dart';

class IncompleteTasksView extends StatelessWidget {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar:AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/images/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Công việc chưa đã hoàn thành",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getIncompletedTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final incompleteTasks = snapshot.data ?? [];

          if (incompleteTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/completed_task_view_image.png",
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Chưa có công việc nào cần hoàn thành",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: incompleteTasks.length,
            itemBuilder: (context, index) {
              final task = incompleteTasks[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateToString(task.day, formatStr: "dd/MM/yyyy") + " " + task.timeStart,
                            style: TextStyle(
                              color: AppColors.primaryColor1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            task.content,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            task.taskType,
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.priority.getColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority.toVietnamese(),
                              style: TextStyle(
                                color: task.priority.getColor(),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: task.isDone,
                      onChanged: (bool? value) {
                        if (value != null) {
                          _taskService.updateTask(
                            task.copyWith(isDone: value),
                          );
                        }
                      },
                      activeColor: AppColors.primaryColor1,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}