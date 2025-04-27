import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/colors.dart';
import '../../../components/common_time.dart';

import '../../../database/models/task_model.dart';
import '../../../database/services/task_services.dart';
import '../../widgets/round_button.dart';



class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _detailController = TextEditingController();
  bool _isPersonal = true;
  bool _isExtra = false;
  TaskPriority _selectedPriority = TaskPriority.medium;
  final TaskService _taskService = TaskService();


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              "assets/images/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Thêm công việc",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset("assets/images/date.png", width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                  dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                  style: TextStyle(color: AppColors.gray, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Thời gian",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SizedBox(
                height: media.width * 0.35,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (newDate) {
                    setState(() {
                      _selectedTime = newDate;
                    });
                  },
                  initialDateTime: _selectedTime,
                  use24hFormat: false,
                  minuteInterval: 1,
                  mode: CupertinoDatePickerMode.time,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildPrioritySelector(),
            const SizedBox(height: 20),
            Text(
              "Chi tiết công việc",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailController,
              decoration: InputDecoration(
                hintText: "Nhập nội dung công việc...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isPersonal,
                  onChanged: (value) {
                    setState(() {
                      _isPersonal = value!;
                      if (_isPersonal) _isExtra = false;
                    });
                  },
                ),
                Text("Hoạt động cá nhân"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isExtra,
                  onChanged: (value) {
                    setState(() {
                      _isExtra = value!;
                      if (_isExtra) _isPersonal = false;
                    });
                  },
                ),
                Text("Hoạt động ngoại khóa"),
              ],
            ),
            Spacer(),
            RoundButton(
              title: "Lưu",
              onPressed: () async {
                if (_detailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập nội dung công việc')),
                  );
                  return;
                }

                final taskType = _isPersonal ? "Hoạt động cá nhân" : "Hoạt động ngoại khóa";
                
                final newTask = TaskModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  day: widget.date,
                  timeStart: dateToString(_selectedTime, formatStr: "hh:mm a"),
                  content: _detailController.text,
                  isDone: false,
                  taskType: taskType,
                  priority: _selectedPriority,
                  userId: _taskService.currentUserId,
                );

                try {
                  await _taskService.addTask(newTask);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: Không thể thêm công việc')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mức độ ưu tiên",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<TaskPriority>(
            value: _selectedPriority,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: (TaskPriority? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPriority = newValue;
                });
              }
            },
            items: TaskPriority.values.map((TaskPriority priority) {
              return DropdownMenuItem<TaskPriority>(
                value: priority,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: priority.getColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(priority.toVietnamese()),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
