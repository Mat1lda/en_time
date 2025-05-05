import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/colors.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';

class OverdueTaskView extends StatelessWidget {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Công việc quá hạn",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
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
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data ?? [];
          final overdueTasks = allTasks.where((task) =>
            !task.isDone && task.getStatus() == TaskStatus.overdue
          ).toList();

          // Sort
          overdueTasks.sort((a, b) {
            // dao ngay de ma sort
            int dateComparison = b.day.compareTo(a.day);
            if (dateComparison != 0) return dateComparison;
            // ngay siong thi so priority
            return b.priority.index.compareTo(a.priority.index);
          });

          if (overdueTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/completed_task_view_image.png",
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Không có công việc quá hạn",
                    style: TextStyle(
                      color: Colors.black,
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
            itemCount: overdueTasks.length,
            itemBuilder: (context, index) {
              return _buildOverdueTaskItem(overdueTasks[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOverdueTaskItem(TaskModel task) {
    final daysOverdue = DateTime.now().difference(task.day).inDays;// inDays trả về số nguyên ngày làm tròn xuống

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(task.day),
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Quá hạn ${daysOverdue} ngày',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            task.content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: 5),
              Text(
                task.timeStart,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 15),
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
          SizedBox(height: 5),
          Text(
            task.taskType,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}