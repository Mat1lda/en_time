import 'package:en_time/views/pages/task_schedule/completed_task_view.dart';
import 'package:en_time/views/pages/task_schedule/incomplete_tasks_view.dart';
import 'package:en_time/views/pages/task_schedule/overdue_task_view.dart';
import 'package:en_time/views/pages/task_schedule/personal_task_view.dart';
import 'package:en_time/views/pages/task_schedule/remind_task_view.dart';
import 'package:en_time/views/pages/task_schedule/task_schedule_view.dart';
import 'package:en_time/views/pages/task_schedule/noti_task_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/colors.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';
import 'extra_task_view.dart';
import 'focus_timer_mode_page.dart';

class HomeTaskView extends StatefulWidget {
  @override
  State<HomeTaskView> createState() => _HomeTaskViewState();
}

class _HomeTaskViewState extends State<HomeTaskView> {
  final TaskService _taskService = TaskService();
  bool _isFocusMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getVietnameseFormattedDate(DateTime.now()),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Quản lý công việc",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: ElevatedButton.icon(
                            icon: Icon(
                              _isFocusMode ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              _isFocusMode ? " Ưu tiên" : "Thường",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              setState(() {
                                _isFocusMode = !_isFocusMode;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationTaskPage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.notifications_active, color: AppColors.primaryColor1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isFocusMode)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: StreamBuilder<List<TaskModel>>(
                    stream: _taskService.getUpcomingTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final allTasks = snapshot.data ?? [];
                      final highPriorityTasks = allTasks.where((task) =>
                          task.priority == TaskPriority.critical ||
                          task.priority == TaskPriority.high).toList()
                        ..sort((a, b) => a.priority == TaskPriority.critical ? -1 : 1);

                      if (highPriorityTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/completed_task_view_image.png",
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Không có công việc ưu tiên",
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
                        shrinkWrap: true,
                        //physics: NeverScrollableScrollPhysics(),
                        itemCount: highPriorityTasks.length,
                        itemBuilder: (context, index) {
                          final task = highPriorityTasks[index];
                          return _buildFocusTaskItem(task);
                        },
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              ontap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FocusTimerPage(),
                                  ),
                                );
                              },
                              title: "Công việc hôm nay",
                              value: StreamBuilder<List<TaskModel>>(
                                stream: _taskService.getTasksByDay(DateTime.now()),
                                builder: (context, snapshot) {
                                  final int taskCount = snapshot.data?.length ?? 0;
                                  return Text(
                                    "$taskCount",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor1,
                                    ),
                                  );
                                },
                              ),
                              icon: Icons.today,
                              color: AppColors.primaryColor1,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildOverviewCard(
                              ontap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompletedTaskView(),
                                  ),
                                );
                              },
                              title: "Đã hoàn thành hôm nay",
                              value: StreamBuilder<List<TaskModel>>(
                                stream: _taskService.getTasksByDay(DateTime.now()),
                                builder: (context, snapshot) {
                                  final completedCount = snapshot.data?.where((task) => task.isDone).length ?? 0;
                                  return Text(
                                    "$completedCount",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  );
                                },
                              ),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor1.withOpacity(0.9),
                              AppColors.primaryColor2.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor1.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quản lý công việc",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  icon: Icons.add_task,
                                  label: "Thêm mới",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => TaskScheduleView()),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.timer_off_outlined,
                                  label: "Quá hạn",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => OverdueTaskView()),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.notifications,
                                  label: "Nhắc nhở",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RemindTaskView(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncompleteTasksView(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
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
                                    "Tiến độ công việc",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor1.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Tuần này",
                                      style: TextStyle(
                                        color: AppColors.primaryColor1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              StreamBuilder<List<TaskModel>>(
                                stream: _taskService.getAllTasks(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }

                                  final allTasks = snapshot.data ?? [];
                                  final completedCount = allTasks.where((task) => task.isDone).length;
                                  final totalCount = allTasks.length;
                                  final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Đã hoàn thành",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            "$completedCount/$totalCount nhiệm vụ",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryColor1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Công việc sắp tới",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RemindTaskView(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: StreamBuilder<List<TaskModel>>(
                            stream: _taskService.getUpcomingTasks(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              final upcomingTasks = snapshot.data ?? [];
                              if (upcomingTasks.isEmpty) {
                                return Column(
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Không có công việc sắp tới',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: upcomingTasks.take(3).map((task) => _buildTaskItem(task)).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Danh sách công việc",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 150,
                          child: StreamBuilder<List<TaskModel>>(
                            stream: _taskService.getAllTasks(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              final allTasks = snapshot.data ?? [];
                              final personalCount = allTasks.where((task) =>
                                  task.taskType == "Hoạt động cá nhân" && !task.isDone).length;
                              final extraCount = allTasks.where((task) =>
                                  task.taskType == "Hoạt động ngoại khóa" && !task.isDone).length;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PersonalTasksView()),
                                        );
                                      },
                                      child: _buildCategoryItem(
                                        imagePath: "assets/images/personal-activity.png",
                                        title: "Hoạt động cá nhân",
                                        count: "$personalCount",
                                        color: AppColors.primaryColor1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ExtracurricularTasksView()),
                                        );
                                      },
                                      child: _buildCategoryItem(
                                        imagePath: "assets/images/extracurricular-activities.png",
                                        title: "Hoạt động ngoại khóa",
                                        count: "$extraCount",
                                        color: AppColors.secondaryColor1,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
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
                                  "Tổng quan tuần",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor1.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "7 ngày gần nhất",
                                    style: TextStyle(
                                      color: AppColors.primaryColor1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) => _buildDayProgress(index)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required Widget value,
    required IconData icon,
    required Color color,
    required VoidCallback ontap,
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(height: 10),
            value,
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    String getVietnameseFormattedDate(DateTime date) {
      return '${_getVietnameseWeekday(date)}, ${date.day} tháng ${date.month} ${date.year}';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.schedule,
              color: AppColors.primaryColor1,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.content,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      getVietnameseFormattedDate(task.day),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      task.timeStart,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String imagePath,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              imagePath,
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayProgress(int index) {
    final day = DateTime.now().subtract(Duration(days: 6 - index));
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return Container(
      width: 40,
      child: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getTasksByDay(day),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final dayTasks = snapshot.data ?? [];
          final completedCount = dayTasks.where((task) => task.isDone).length;
          final totalCount = dayTasks.length;
          final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

          return Column(
            children: [
              Text(
                _getVietnameseWeekday(day),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 30,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 60 * progress,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor1.withOpacity(0.8),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                "$completedCount/$totalCount",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getVietnameseWeekday(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  String _getVietnameseFormattedDate(DateTime date) {
    return '${_getVietnameseWeekday(date)}, ${date.day} tháng ${date.month} năm ${date.year}';
  }

  Widget _buildFocusTaskItem(TaskModel task) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(task.day),
                style: TextStyle(
                  color: AppColors.primaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
