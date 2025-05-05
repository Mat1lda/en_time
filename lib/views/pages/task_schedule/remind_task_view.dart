import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/colors.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';

class RemindTaskView extends StatefulWidget {
  const RemindTaskView({Key? key}) : super(key: key);

  @override
  State<RemindTaskView> createState() => _RemindTaskViewState();
}

class _RemindTaskViewState extends State<RemindTaskView> {
  final TaskService _taskService = TaskService();

  int _comparePriority(TaskModel a, TaskModel b) {
    // Explicit numeric values for each priority level
    int getPriorityValue(TaskPriority priority) {
      switch (priority) {
        case TaskPriority.critical:
          return 4;  // Highest priority (Khẩn cấp)
        case TaskPriority.high:
          return 3;
        case TaskPriority.medium:
          return 2;
        case TaskPriority.low:
          return 1;
        default:
          return 0;
      }
    }

    // Compare priorities first
    final priorityComparison = getPriorityValue(b.priority).compareTo(getPriorityValue(a.priority));

    // If priorities are different, return priority comparison
    if (priorityComparison != 0) {
      return priorityComparison;
    }

    // If priorities are equal, compare by time
    try {
      final timeA = _parseTimeString(a.timeStart);
      final timeB = _parseTimeString(b.timeStart);
      return timeA.compareTo(timeB);
    } catch (e) {
      return 0;
    }
  }

  DateTime _parseTimeString(String timeStr) {
    final now = DateTime.now();
    final lowercaseTime = timeStr.toLowerCase();

    try {
      if (lowercaseTime.contains('am') || lowercaseTime.contains('pm')) {
        // Handle 12-hour format
        final time = lowercaseTime.replaceAll(RegExp(r'[ap]m'), '').trim().split(':');
        var hour = int.parse(time[0]);
        final minute = int.parse(time[1]);

        if (lowercaseTime.contains('pm') && hour != 12) {
          hour += 12;
        }
        if (lowercaseTime.contains('am') && hour == 12) {
          hour = 0;
        }

        return DateTime(now.year, now.month, now.day, hour, minute);
      } else {
        // Handle 24-hour format
        final time = timeStr.split(':');
        return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(time[0]),
            int.parse(time[1])
        );
      }
    } catch (e) {
      return now;
    }
  }
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
          "Lời nhắc",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getUpcomingTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];
          // Sort tasks by priority and time
          tasks.sort(_comparePriority);

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/completed_task_view_image.png",
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Không có lời nhắc nào",
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
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(task);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
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
                  DateFormat('dd/MM/yyyy').format(task.day),
                  style: TextStyle(
                    color: AppColors.primaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  task.timeStart,
                  style: TextStyle(
                    color: AppColors.primaryColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  task.content,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
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
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    'Xác nhận xóa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn xóa?',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        _taskService.deleteTask(task.id);
                        Navigator.pop(context);
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
  }
}