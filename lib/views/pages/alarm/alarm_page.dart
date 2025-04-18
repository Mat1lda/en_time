import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../database/models/alarm_model.dart';
import '../../../database/services/alarm_services.dart';
import 'add_alarm_view.dart';

class AlarmPage extends StatelessWidget {
  final AlarmService _alarmService = AlarmService();

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
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
          'Báo thức',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AlarmModel>>(
        stream: _alarmService.getAlarms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE293F5)),
            ));
          }

          final alarms = snapshot.data!;
          
          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có báo thức nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return GestureDetector(
                onLongPress: () => _showDeleteDialog(context, alarm),
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE293F5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            alarm.alarmName.toLowerCase().contains('bedtime') 
                                ? Icons.bed
                                : Icons.alarm,
                            color: Color(0xFFE293F5),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          _formatTime(alarm.time),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          alarm.alarmName,
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Switch(
                          value: alarm.isEnabled,
                          onChanged: (value) {
                            _alarmService.toggleAlarmState(alarm.id!, value);
                          },
                          activeColor: Color(0xFFE293F5),
                        ),
                      ),
                      if (_hasActiveRepeatDays(alarm.repeatDays))
                        Padding(
                          padding: EdgeInsets.only(left: 72, right: 16, bottom: 16),
                          child: Row(
                            children: _buildRepeatDayChips(alarm.repeatDays),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddAlarmView()),
        ),
        child: Icon(Icons.add),
        //elevation: 4,
      ),
    );
  }

  bool _hasActiveRepeatDays(Map<WeekDay, bool> repeatDays) {
    return repeatDays.values.any((isActive) => isActive);
  }

  List<Widget> _buildRepeatDayChips(Map<WeekDay, bool> repeatDays) {
    return repeatDays.entries
        .where((entry) => entry.value)
        .map((entry) => Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFE293F5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getDayLabel(entry.key),
                style: TextStyle(
                  color: Color(0xFFE293F5),
                  fontSize: 12,
                ),
              ),
            ))
        .toList();
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

  Future<void> _showDeleteDialog(BuildContext context, AlarmModel alarm) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Xóa báo thức', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),
          content: Text('Bạn có chắc chắn muốn xóa báo thức "${alarm.alarmName}" không?', textAlign: TextAlign.center,),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'HỦY',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _alarmService.deleteAlarm(alarm.id!);
                  Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa báo thức'),
                        backgroundColor: Colors.grey,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể xóa báo thức. Vui lòng thử lại.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                }
              },
              child: Text(
                'XÓA',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}