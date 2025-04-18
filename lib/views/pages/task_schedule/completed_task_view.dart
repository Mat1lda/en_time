import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../components/common_time.dart';

import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';
import '../../widgets/round_button.dart';

class CompletedTaskView extends StatefulWidget {
  const CompletedTaskView({super.key});

  @override
  State<CompletedTaskView> createState() => _CompletedTaskViewState();
}

class _CompletedTaskViewState extends State<CompletedTaskView> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
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
          "Công việc đã hoàn thành",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final completedTasks = (snapshot.data ?? []).where((task) => task.isDone).toList();

          if (completedTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/completed_task_view_image.png",
                    //width: MediaQuery.of(context).width * 0.75,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Chưa có công việc nào hoàn thành hôm nay",
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
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
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
                              decoration: TextDecoration.lineThrough,
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
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc chắn muốn xóa công việc này?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _taskService.deleteTask(task.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã xóa nhiệm vụ'),
                                      backgroundColor: Colors.grey,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                child: Text('Xóa'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
