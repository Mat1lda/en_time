import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/colors.dart';
import '../../../components/common_time.dart';
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
  bool _isPublic = false;
  bool _isExtra = false;

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
                FocusScope.of(context).unfocus(); // Bỏ focus khi nhấn ra ngoài
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
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value!;
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
                    });
                  },
                ),
                Text("Hoạt động ngoại khóa"),
              ],
            ),
            Spacer(),
            RoundButton(
              title: "Lưu",
              onPressed: () {
                Navigator.pop(context);
                // Map<String, dynamic> newSchedule = {
                //   "name": _detailController.text,
                //   //"date": widget.date,
                //   "start_time": dateToString(_selectedTime, formatStr: "dd/MM/yyyy hh:mm a"),
                //   //"isPublic": _isPublic,
                //   //"isExtra": _isExtra,
                //widget.onSave(newSchedule);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
