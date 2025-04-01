import 'dart:math';

import 'package:en_time/views/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomTimetableScreem extends StatefulWidget{
  @override
  State<CustomTimetableScreem> createState() => _CustomTimetableScreemState();
}

class _CustomTimetableScreemState extends State<CustomTimetableScreem> {
  final CalendarDataSource _dataSource = _DataSource(<Appointment>[]);
  final List<String> _subjectCollection = <String>[];//danh sach tieu de
  final List<DateTime> _startTimeCollection = <DateTime>[];
  final List<DateTime> _endTimeCollection = <DateTime>[];
  final List<Color> _colorCollection = <Color>[]; 
  List<TimeRegion> _specialTimeRegion = <TimeRegion>[];
  CalendarView _selectedView = CalendarView.week; 
  // final Map<CalendarView, String> _viewNames = {
  //   CalendarView.day: "Ngày",
  //   CalendarView.week: "Tuần",
  //   CalendarView.workWeek: "Tuần làm việc",
  //   CalendarView.month: "Tháng",
  //   CalendarView.timelineDay: "Dòng thời gian ngày",
  //   CalendarView.timelineWeek: "Dòng thời gian tuần",
  //   CalendarView.schedule: "Lịch trình",
  // };
  @override
  void initState() {
    _getSubjectCollection();
    _getStartTimeCollection();
    _getEndTimeCollection();
    _getColorCollection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: BasicAppbar(
          backgroundColor: Colors.white,
          hideBack: true,
          title: Text('Lịch học', style: TextStyle(fontWeight: FontWeight.w700,),),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDeadlineDialog();
          },
          child: Icon(Icons.add),
        ),
        // appBar: AppBar(
        //   title: Text('Lịch biểu'),
        //   actions: [
        //     DropdownButton<CalendarView>(
        //       value: _selectedView,
        //       icon: Icon(Icons.calendar_view_day),
        //       onChanged: (CalendarView? newValue) {
        //         if (newValue != null) {
        //           setState(() {
        //             _selectedView = newValue;
        //             _dataSource.notifyListeners(CalendarDataSourceAction.reset, _dataSource.appointments!);
        //           });
        //         }
        //       },
        //       items: _viewNames.entries.map((entry) {
        //         return DropdownMenuItem<CalendarView>(
        //           value: entry.key,
        //           child: Text(entry.value),
        //         );
        //       }).toList(),
        //     ),
        //   ],
        // ),
        body: SafeArea(
          child: SfCalendar(
            dataSource: _dataSource,
            view: _selectedView,
            allowedViews: const [
              CalendarView.day,
              CalendarView.week,
              CalendarView.workWeek,
              CalendarView.month,
              CalendarView.timelineDay,
              CalendarView.timelineWeek,
              CalendarView.timelineWorkWeek,
              CalendarView.timelineMonth,
              CalendarView.schedule
            ],
            // monthViewSettings: MonthViewSettings(
            //   appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            // ),
            onTap: _onCalendarTapped,
            onLongPress: _onCalendarLongPressed,
            specialRegions: _specialTimeRegion,
            onViewChanged: viewChanged,
          ),
        ),
      ),
    );
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> visibleDates = viewChangedDetails.visibleDates;
    List<TimeRegion> timeRegion = <TimeRegion>[];
    List<Appointment> appointments = <Appointment>[];
    _dataSource.appointments!.clear();

    for (int i = 0; i < visibleDates.length; i++) {
      if (visibleDates[i].weekday == 6 || visibleDates[i].weekday == 7) {
        continue;
      }
      timeRegion.add(TimeRegion(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month,
              visibleDates[i].day, 13, 0, 0),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month,
              visibleDates[i].day, 14, 0, 0),
          text: 'Break',
          enablePointerInteraction: false));
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _specialTimeRegion = timeRegion;
        });
      });
      for (int j = 0; j < _startTimeCollection.length; j++) {
        DateTime startTime = DateTime(
            visibleDates[i].year,
            visibleDates[i].month,
            visibleDates[i].day,
            _startTimeCollection[j].hour,
            _startTimeCollection[j].minute,
            _startTimeCollection[j].second);
        DateTime endTime = DateTime(
            visibleDates[i].year,
            visibleDates[i].month,
            visibleDates[i].day,
            _endTimeCollection[j].hour,
            _endTimeCollection[j].minute,
            _endTimeCollection[j].second);
        Random random = Random();
        appointments.add(Appointment(
            startTime: startTime,
            endTime: endTime,
            subject: _subjectCollection[random.nextInt(9)],
            color: _colorCollection[random.nextInt(9)]));
      }
    }
    for (int i = 0; i < appointments.length; i++) {
      _dataSource.appointments!.add(appointments[i]);
    }
    _dataSource.notifyListeners(
        CalendarDataSourceAction.reset, _dataSource.appointments!);
  }
  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
      Appointment selectedAppointment = details.appointments!.first;
      _showAppointmentDialog(isEdit: true, appointment: selectedAppointment);
    } else {
      _showAppointmentDialog(isEdit: false, selectedDate: details.date);
    }
  }
  void _onCalendarLongPressed(CalendarLongPressDetails details) {
    if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
      Appointment selectedAppointment = details.appointments!.first;
      _showDeleteConfirmation(selectedAppointment);
    }
  }

  void _showAppointmentDialog({required bool isEdit, Appointment? appointment, DateTime? selectedDate}) {
    TextEditingController subjectController = TextEditingController(text: isEdit ? appointment!.subject : '');
    Color selectedColor = isEdit ? appointment!.color : Colors.blue;
    DateTime startTime = isEdit ? appointment!.startTime : selectedDate ?? DateTime.now();
    DateTime endTime = isEdit ? appointment!.endTime : startTime.add(Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isEdit ? 'Chỉnh sửa cuộc hẹn' : 'Thêm cuộc hẹn', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: startTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    startTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, startTime.hour, startTime.minute);
                    endTime = startTime.add(Duration(hours: 1));
                  });
                }
              },
              child: Text('Chọn ngày'),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          startTime = DateTime(startTime.year, startTime.month, startTime.day, pickedTime.hour, pickedTime.minute);
                          endTime = startTime.add(Duration(hours: 1));
                        });
                      }
                    },
                    child: Text('Bắt đầu: ${TimeOfDay.fromDateTime(startTime).format(context)}'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          endTime = DateTime(startTime.year, startTime.month, startTime.day, pickedTime.hour, pickedTime.minute);
                        });
                      }
                    },
                    child: Text('Kết thúc: ${TimeOfDay.fromDateTime(endTime).format(context)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (subjectController.text.isEmpty) return;

              setState(() {
                if (isEdit) {
                  appointment!.subject = subjectController.text;
                  appointment.startTime = startTime;
                  appointment.endTime = endTime;
                } else {
                  _dataSource.appointments!.add(
                    Appointment(
                      startTime: startTime,
                      endTime: endTime,
                      subject: subjectController.text,
                      color: selectedColor,
                    ),
                  );
                }
                _dataSource.notifyListeners(CalendarDataSourceAction.reset, _dataSource.appointments!);
              });
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: Colors.white,
        title: Text('Xác nhận xóa', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        content: Text('Bạn có chắc muốn xóa cuộc hẹn "${appointment.subject}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dataSource.appointments!.remove(appointment);
                _dataSource.notifyListeners(CalendarDataSourceAction.remove, [appointment]);
              });
              Navigator.pop(context);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _getSubjectCollection() {
    _subjectCollection.add('đói');
    _subjectCollection.add('Plan Execution');
    _subjectCollection.add('Project Plan');
    _subjectCollection.add('Consulting');
    _subjectCollection.add('Support');
    _subjectCollection.add('Development Meeting');
    _subjectCollection.add('Scrum');
    _subjectCollection.add('Project Completion');
    _subjectCollection.add('Release updates');
    _subjectCollection.add('Performance Check');
  }

  void _getStartTimeCollection() {
    var currentDateTime = DateTime.now();

    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 9, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 10, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 11, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 12, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 14, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 15, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 16, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 17, 0, 0));
    _startTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 18, 0, 0));
  }

  void _getEndTimeCollection() {
    var currentDateTime = DateTime.now();
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 10, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 11, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 12, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 13, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 15, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 16, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 17, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 18, 0, 0));
    _endTimeCollection.add(DateTime(currentDateTime.year,
        currentDateTime.month, currentDateTime.day, 19, 0, 0));
  }

  void _getColorCollection() {
    _colorCollection.add(const Color(0xff92A3FD));
    _colorCollection.add(const Color(0xff9DCEFF));
    _colorCollection.add(const Color(0xffC58BF2));
    _colorCollection.add(const Color(0xffEEA4CE));
    _colorCollection.add(const Color(0xff0da3a3));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }

  void _showDeadlineDialog() {
    TextEditingController subjectController = TextEditingController();
    TextEditingController deadlineController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Thêm Deadline cho môn học', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Tên môn học',
                hintText: "Nhập tên môn học"
                //border: OutlineInputBorder(
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: 'Tên deadline',
                hintText: 'Nhập tên deadline'
                //border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  selectedDate = pickedDate;
                }
              },
              child: Text('Chọn ngày'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                );
                if (pickedTime != null) {
                  selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                }
              },
              child: Text('Chọn giờ: ${TimeOfDay.fromDateTime(selectedDate).format(context)}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (subjectController.text.isEmpty || deadlineController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              setState(() {
                // _dataSource.appointments!.add(
                //   Appointment(
                //     startTime: selectedDate,
                //     endTime: selectedDate.add(Duration(hours: 1)),
                //     subject: '${subjectController.text} - ${deadlineController.text}',
                //     color: _colorCollection[Random().nextInt(_colorCollection.length)],
                //   ),
                // );
                // _dataSource.notifyListeners(CalendarDataSourceAction.reset, _dataSource.appointments!);
              });
              Navigator.pop(context);
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }

  void addAppointment(Appointment appointment) {
    appointments!.add(appointment);
    notifyListeners(CalendarDataSourceAction.add, [appointment]);
  }


  void removeAppointment(Appointment appointment) {
    appointments!.remove(appointment);
    notifyListeners(CalendarDataSourceAction.remove, [appointment]);
  }


  void updateAppointment(Appointment oldAppointment, Appointment newAppointment) {
    final int index = appointments!.indexOf(oldAppointment);
    if (index >= 0) {
      appointments![index] = newAppointment;
      notifyListeners(CalendarDataSourceAction.reset, appointments!);
    }
  }
}