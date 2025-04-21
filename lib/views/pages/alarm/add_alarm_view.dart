import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../database/models/alarm_model.dart';
import '../../../database/services/alarm_services.dart';

class AddAlarmView extends StatefulWidget {
  const AddAlarmView({super.key});

  @override
  _AddAlarmViewState createState() => _AddAlarmViewState();
}

class _AddAlarmViewState extends State<AddAlarmView> {
  final _alarmService = AlarmService();
  final _nameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final Map<WeekDay, bool> _selectedDays = AlarmModel.createDefaultRepeatDays();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
          'Thêm báo thức',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: Text(
              'LƯU',
              style: TextStyle(
                color: Color(0xFFE293F5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showTimePicker,
              child: Container(
                width: double.infinity,//chiếm hết không gian widget cha
                padding: EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE293F5),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nhấn để chọn thời gian',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên báo thức',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE293F5)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Lặp lại',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            _buildWeekDaySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WeekDay.values.map((day) {
        final isSelected = _selectedDays[day] ?? false;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDays[day] = !isSelected;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Color(0xFFE293F5) : Colors.transparent,
              border: Border.all(
                color: isSelected ? Color(0xFFE293F5) : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                _getDayLabel(day),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDayLabel(WeekDay day) {
    switch (day) {
      case WeekDay.monday: return 'T2';
      case WeekDay.tuesday: return 'T3';
      case WeekDay.wednesday: return 'T4';
      case WeekDay.thursday: return 'T5';
      case WeekDay.friday: return 'T6';
      case WeekDay.saturday: return 'T7';
      case WeekDay.sunday: return 'CN';
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveAlarm() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên báo thức')),
      );
      return;
    }

    await _alarmService.createAlarm(
      _nameController.text,
      _selectedTime,
      _selectedDays,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}