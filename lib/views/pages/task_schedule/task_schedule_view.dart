import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';
import '../../widgets/task_card.dart';
import 'add_schedule_view.dart';
import 'completed_task_view.dart';

class TaskScheduleView extends StatefulWidget {
  const TaskScheduleView({super.key});

  @override
  State<TaskScheduleView> createState() => _TaskScheduleViewState();
}

class _TaskScheduleViewState extends State<TaskScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar = CalendarAgendaController();
  late DateTime _selectedDateAppBBar;
  final TaskService _taskService = TaskService();
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
  }

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

  // Add this helper method to parse time strings
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
    var media = MediaQuery.of(context).size;
    return Scaffold(
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
          "Thời gian biểu",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletedTaskView(),
                ),
              );
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
                "assets/images/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
              onPressed: () {},
              icon: Image.asset(
                "assets/images/ArrowLeft.png",
                width: 15,
                height: 15,
              ),
            ),
            training: IconButton(
              onPressed: () {},
              icon: Image.asset(
                "assets/images/ArrowRight.png",
                width: 15,
                height: 15,
              ),
            ),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'vi',
            initialDate: DateTime.now(),
            calendarEventColor: AppColors.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) {
              setState(() {
                _selectedDateAppBBar = date;
              });
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _taskService.getTasksByDay(_selectedDateAppBBar),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return Center(child: Text('Không có công việc nào trong ngày này'));
                }

                // Sort tasks by priority
                tasks.sort(_comparePriority);

                return SingleChildScrollView(
                  child: Column(
                    children: tasks.map((task) => _buildTaskItem(task)).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScheduleView(date: _selectedDateAppBBar),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor1,
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return TaskCard(
      task: task,
      onTap: () {
        //_showEditTaskDialog(task);
      },
      onCheckboxChanged: (bool? value) {
        _taskService.toggleTaskCompletion(task.id, task.isDone);
      },
      onDelete: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Xác nhận xóa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
    );
  }
}
