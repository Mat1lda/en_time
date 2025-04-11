import 'dart:math';

import 'package:en_time/components/colors.dart';
import 'package:en_time/views/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:en_time/database/models/subject_model.dart';
import 'package:en_time/database/models/deadline_model.dart';
import 'package:en_time/database/services/subject_services.dart';
import 'package:en_time/database/services/deadline_services.dart';

class CustomTimetableScreem extends StatefulWidget{
  @override
  State<CustomTimetableScreem> createState() => _CustomTimetableScreemState();
}

class _CustomTimetableScreemState extends State<CustomTimetableScreem> {
  final CalendarDataSource _dataSource = _DataSource(<Appointment>[]);
  final List<Color> _colorCollection = <Color>[]; 
  List<TimeRegion> _specialTimeRegion = <TimeRegion>[];
  CalendarView _selectedView = CalendarView.week; 
  final SubjectService _subjectService = SubjectService();
  final DeadlineService _deadlineService = DeadlineService();

  @override
  void initState() {
    _getColorCollection();
    _loadAppointments();
    super.initState();
  }
  void _loadAppointments() {
    print("Loading appointments...");
    _subjectService.getAllSubjects().listen((subjects) {
      print("Loaded ${subjects.length} subjects");
      final subjectAppointments = subjects.map((subject) {
        try {
          return subject.toAppointment();
        } catch (e) {
          print("Error converting subject to appointment: $e");
          print("Subject data: ${subject.toMap()}");
          return null;
        }
      }).where((appointment) => appointment != null).cast<Appointment>().toList();
      
      // Only use subject appointments, ignore deadlines
      print("Total appointments: ${subjectAppointments.length}");
      
      setState(() {
        _dataSource.appointments!.clear();
        _dataSource.appointments!.addAll(subjectAppointments);
        _dataSource.notifyListeners(CalendarDataSourceAction.reset, _dataSource.appointments!);
      });
    }, onError: (error) {
      print("Error loading subjects: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: BasicAppbar(
            backgroundColor: Colors.white,
            hideBack: true,
            title: Text('Lịch học', style: TextStyle(fontWeight: FontWeight.w700,),),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddMenu();
            },
            child: Icon(Icons.add),
          ),
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
              minDate: DateTime(DateTime.now().year, 1, 1),
              maxDate: DateTime(DateTime.now().year + 1, 12, 31),
              headerHeight: 50,
              viewHeaderHeight: 60,
              firstDayOfWeek: 1,
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 7,
                endHour: 21,
                timeFormat: 'HH:mm',
                nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
                timeIntervalHeight: 60,
                timeTextStyle: TextStyle(
                  fontWeight: FontWeight.w500, 
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.7)
                ),
                dayFormat: 'EEE',
              ),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true,
              ),
              todayHighlightColor: Theme.of(context).primaryColor,
              cellBorderColor: Colors.grey.withOpacity(0.2),
              onTap: _onCalendarTapped,
              onLongPress: _onCalendarLongPressed,
              specialRegions: _specialTimeRegion,
              onViewChanged: viewChanged,
            ),
          ),
        ),
      ),
    );
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> visibleDates = viewChangedDetails.visibleDates;
    List<TimeRegion> timeRegion = <TimeRegion>[];
    
    for (int i = 0; i < visibleDates.length; i++) {
      if (visibleDates[i].weekday == 7) {
        continue;
      }
      timeRegion.add(TimeRegion(
          startTime: DateTime(visibleDates[i].year, visibleDates[i].month,
              visibleDates[i].day, 12, 0, 0),
          endTime: DateTime(visibleDates[i].year, visibleDates[i].month,
              visibleDates[i].day, 13, 0, 0),
          text: 'Nghỉ',
          color: Colors.grey.withOpacity(0.1),
          enablePointerInteraction: false));
    }
    
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _specialTimeRegion = timeRegion;
      });
    });
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
      Appointment selectedAppointment = details.appointments!.first;
      // Check if it's a deadline or a subject based on notes field
      if (selectedAppointment.notes == 'deadline') {
        _showDeadlineEditDialog(selectedAppointment);
      } else {
        _showAppointmentDialog(isEdit: true, appointment: selectedAppointment);
      }
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
    Color selectedColor = isEdit ? appointment!.color : _colorCollection[Random().nextInt(_colorCollection.length)];
    DateTime startTime = isEdit ? appointment!.startTime : selectedDate ?? DateTime.now();
    DateTime endTime = isEdit ? appointment!.endTime : (selectedDate ?? DateTime.now()).add(Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isEdit ? 'Chỉnh sửa lịch môn học' : 'Thêm lịch môn học', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), ),
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

              if (isEdit && appointment != null) {
                String appointmentId = appointment.id.toString();
                // Check if it's a subject (no notes field or notes is not 'deadline')
                if (appointment.notes == null || appointment.notes != 'deadline') {
                  // Update subject in Firebase
                  SubjectModel updatedSubject = SubjectModel(
                    id: appointmentId,
                    day: DateTime(startTime.year, startTime.month, startTime.day),
                    timeStart: startTime,
                    timeEnd: endTime,
                    subject: subjectController.text,
                    subjectColor: selectedColor,
                  );
                  _subjectService.updateSubject(updatedSubject).then((_) {
                    // Reload appointments after update
                    _loadAppointments();
                  });
                }
              } else {
                // Add new subject to Firebase
                SubjectModel newSubject = SubjectModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  day: DateTime(startTime.year, startTime.month, startTime.day),
                  timeStart: startTime,
                  timeEnd: endTime,
                  subject: subjectController.text,
                  subjectColor: selectedColor,
                );
                _subjectService.addSubject(newSubject).then((_) {
                  // Reload appointments after add
                  _loadAppointments();
                });
              }
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
        backgroundColor: Colors.white,
        title: Text('Xác nhận xóa', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        content: Text('Bạn có chắc muốn xóa lịch môn học "${appointment.subject}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              String appointmentId = appointment.id.toString();
              
              // Check if it's a deadline or subject
              if (appointment.notes == 'deadline') {
                _deadlineService.deleteDeadline(appointmentId).then((_) {
                  // Reload appointments after delete
                  _loadAppointments();
                });
              } else {
                _subjectService.deleteSubject(appointmentId).then((_) {
                  // Reload appointments after delete
                  _loadAppointments();
                });
              }
              
              Navigator.pop(context);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeadlineEditDialog(Appointment appointment) {
    // Extract subject and deadline name from combined subject field
    List<String> parts = appointment.subject.split(' - ');
    String subject = parts[0];
    String deadlineName = parts.length > 1 ? parts[1] : '';
    
    TextEditingController subjectController = TextEditingController(text: subject);
    TextEditingController deadlineController = TextEditingController(text: deadlineName);
    DateTime selectedDate = appointment.startTime;
    Color selectedColor = appointment.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Chỉnh sửa Deadline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Tên môn học',
                hintText: "Nhập tên môn học"
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: 'Tên deadline',
                hintText: 'Nhập tên deadline'
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
                  setState(() {
                    selectedDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      selectedDate.hour,
                      selectedDate.minute
                    );
                  });
                }
              },
              child: Text('Chọn ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
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

              // Update deadline in Firebase
              DeadlineModel updatedDeadline = DeadlineModel(
                id: appointment.id.toString(),
                day: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                timeStart: selectedDate,
                timeEnd: selectedDate.add(Duration(hours: 1)),
                subject: subjectController.text,
                deadlineName: deadlineController.text,
                deadlineColor: selectedColor,
              );
              
              _deadlineService.updateDeadline(updatedDeadline).then((_) {
                // Reload appointments after update
                _loadAppointments();
              });
              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeadlineDialog() {
    TextEditingController deadlineController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    Color selectedColor = _colorCollection[Random().nextInt(_colorCollection.length)];
    String? selectedSubjectId;
    String? selectedSubjectName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Thêm Deadline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<List<SubjectModel>>(
              stream: _subjectService.getAllSubjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final subjects = snapshot.data ?? [];
                if (subjects.isEmpty) {
                  return Text('Chưa có môn học nào. Vui lòng thêm môn học trước.');
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tên môn học',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedSubjectId,
                  items: subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject.id,
                      child: Text(subject.subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubjectId = value;
                      selectedSubjectName = subjects.firstWhere((s) => s.id == value).subject;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: 'Tên deadline',
                hintText: 'Nhập tên deadline',
                border: OutlineInputBorder(),
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
                  setState(() {
                    selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        selectedDate.hour,
                        selectedDate.minute
                    );
                  });
                }
              },
              child: Text('Chọn ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
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
              if (selectedSubjectId == null || deadlineController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }
              DeadlineModel newDeadline = DeadlineModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                day: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                timeStart: selectedDate,
                timeEnd: selectedDate.add(Duration(hours: 1)),
                subject: selectedSubjectName!,
                deadlineName: deadlineController.text,
                deadlineColor: selectedColor,
              );
              _deadlineService.addDeadline(newDeadline).then((_) {
                Navigator.pop(context);
              });
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.school, color: AppColors.primaryColor1),
                title: Text('Thêm lịch môn học'),
                onTap: () {
                  Navigator.pop(context);
                  _showAppointmentDialog(isEdit: false, selectedDate: DateTime.now());
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment_late, color: AppColors.primaryColor1),
                title: Text('Thêm deadline cho môn học'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeadlineDialog();
                },
              ),
            ],
          ),
        );
      },
    );
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