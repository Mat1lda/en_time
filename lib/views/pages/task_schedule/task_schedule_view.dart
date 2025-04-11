import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';
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
    return GestureDetector(
      onTap: () {
        //_showEditTaskDialog(task);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
            ),
            Column(
              children: [
                Checkbox(
                  value: task.isDone,
                  onChanged: (bool? value) {
                    _taskService.toggleTaskCompletion(task.id, task.isDone);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text('Xác nhận xóa', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
                        content: Text('Bạn có chắc chắn muốn xóa?', textAlign: TextAlign.center,),
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
          ],
        ),
      ),
    );
  }

//   void _showEditTaskDialog(TaskModel task) {
//     TextEditingController contentController = TextEditingController(text: task.content);
//     TextEditingController timeController = TextEditingController(text: task.timeStart);
//
//     // Define the list of available task types
//     final List<String> taskTypes = ['Học tập', 'Công việc', 'Hoạt động cá nhân', 'Khác'];
//
//     // Ensure the selected type is in the list, otherwise default to the first item
//     String selectedTaskType = taskTypes.contains(task.taskType) ? task.taskType : taskTypes[0];
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         title: Text('Chỉnh sửa công việc', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: contentController,
//               decoration: InputDecoration(
//                 labelText: 'Nội dung công việc',
//                 hintText: 'Nhập nội dung công việc',
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: timeController,
//               decoration: InputDecoration(
//                 labelText: 'Thời gian',
//                 hintText: 'Nhập thời gian (VD: 08:00)',
//               ),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: selectedTaskType,
//               decoration: InputDecoration(
//                 labelText: 'Loại công việc',
//               ),
//               items: taskTypes.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   selectedTaskType = newValue;
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Hủy'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (contentController.text.isEmpty || timeController.text.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
//                 );
//                 return;
//               }
//
//               // Update task in Firebase
//               TaskModel updatedTask = TaskModel(
//                 day: task.day,
//                 id: task.id,
//                 content: contentController.text,
//                 timeStart: timeController.text,
//                 taskType: selectedTaskType,
//                 isDone: task.isDone,
//               );
//
//               _taskService.updateTask(updatedTask);
//               Navigator.pop(context);
//             },
//             child: Text('Lưu'),
//           ),
//         ],
//       ),
//     );
//   }
 }
