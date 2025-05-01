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
import '../../../database/services/calendar_services.dart';

class CustomTimetableScreem extends StatefulWidget {
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
  //final CalendarService _calendarService = CalendarService();

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
      List<Appointment> allAppointments = [];

      // Convert each subject to its recurring appointments
      for (var subject in subjects) {
        allAppointments.addAll(subject.toAppointments());
      }

      setState(() {
        _dataSource.appointments!.clear();
        _dataSource.appointments!.addAll(allAppointments);
        _dataSource.notifyListeners(CalendarDataSourceAction.reset, _dataSource.appointments!);
      });
    }, onError: (error) {
      print("Error loading subjects: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Lịch học',
          style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => _exportToExcel(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMenu();
        },
        child: const Icon(Icons.add),
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
              color: Colors.black.withOpacity(0.7),
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
    DateTime rangeStart = isEdit ? startTime : DateTime.now();
    DateTime rangeEnd = isEdit ? startTime.add(Duration(days: 7)) : DateTime.now().add(Duration(days: 7));
    List<bool> selectedDays = List.generate(7, (index) => false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            isEdit ? 'Chỉnh sửa lịch môn học' : 'Thêm lịch môn học',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(labelText: 'Tiêu đề'),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100), //hạn chế chọn đến năm 2100 :))
                            initialDateRange: DateTimeRange(
                              start: rangeStart,
                              end: rangeEnd,
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              rangeStart = picked.start;
                              rangeEnd = picked.end;
                            });
                          }
                        },
                        child: Text('Chọn khoảng thời gian'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Chọn các ngày trong tuần:'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 0; i < 7; i++)
                      FilterChip(
                        label: Text(['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i]),
                        selected: selectedDays[i],
                        onSelected: (bool selected) {
                          setState(() {
                            selectedDays[i] = selected;
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: 16),
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
                              startTime = DateTime(
                                startTime.year,
                                startTime.month,
                                startTime.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              endTime = startTime.add(Duration(hours: 1));
                            });
                          }
                        },
                        child: Text('Bắt đầu: ${TimeOfDay.fromDateTime(startTime).format(context)}'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              endTime = DateTime(
                                endTime.year,
                                endTime.month,
                                endTime.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            if (isEdit)
              TextButton(
                onPressed: () {
                  // Convert selected days to weekday numbers (1-7)
                  List<int> weekdays = [];
                  for (int i = 0; i < 7; i++) {
                    if (selectedDays[i]) {
                      weekdays.add(i + 1); // Adding 1 because weekdays are 1-7
                    }
                  }

                  SubjectModel subject = SubjectModel(
                    id: appointment!.id.toString(),
                    rangeStart: rangeStart,
                    rangeEnd: rangeEnd,
                    timeStart: startTime,
                    timeEnd: endTime,
                    subject: subjectController.text,
                    subjectColor: selectedColor,
                    weekdays: weekdays,
                  );
                  Navigator.pop(context);
                  //_showExportDialog(subject);
                },
                child: Text('Xuất lịch'),
              ),
            TextButton(
              onPressed: () {
                if (subjectController.text.isEmpty) return;

                // Convert selected days to weekday numbers (1-7)
                List<int> weekdays = [];
                for (int i = 0; i < 7; i++) {
                  if (selectedDays[i]) {
                    weekdays.add(i + 1); // Adding 1 because weekdays are 1-7
                  }
                }

                if (weekdays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng chọn ít nhất một ngày trong tuần')),
                  );
                  return;
                }

                SubjectModel subject = SubjectModel(
                  id: isEdit ? appointment!.id.toString() : DateTime.now().millisecondsSinceEpoch.toString(),
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  timeStart: startTime,
                  timeEnd: endTime,
                  subject: subjectController.text,
                  subjectColor: selectedColor,
                  weekdays: weekdays,
                );

                if (isEdit) {
                  _subjectService.updateSubject(subject).then((_) {
                    _loadAppointments();
                  });
                } else {
                  _subjectService.addSubject(subject).then((_) {
                    _loadAppointments();
                  });
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Xác nhận xóa',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
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
        title: Text(
          'Chỉnh sửa Deadline',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Tên môn học', hintText: "Nhập tên môn học"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(labelText: 'Tên deadline', hintText: 'Nhập tên deadline'),
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
                      selectedDate.minute,
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
                //timeStart: selectedDate,
                timeEnd: selectedDate,
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

  // void _showDeadlineDialog() {
  //   TextEditingController deadlineController = TextEditingController();
  //   DateTime selectedDate = DateTime.now();
  //   Color selectedColor = _colorCollection[Random().nextInt(_colorCollection.length)];
  //   String? selectedSubjectId;
  //   String? selectedSubjectName;
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.white,
  //       title: Text(
  //         'Thêm Deadline',
  //         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
  //         textAlign: TextAlign.center,
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           StreamBuilder<List<SubjectModel>>(
  //             stream: _subjectService.getAllSubjects(),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return CircularProgressIndicator();
  //               }
  //
  //               final subjects = snapshot.data ?? [];
  //               if (subjects.isEmpty) {
  //                 return Text('Chưa có môn học nào. Vui lòng thêm môn học trước.');
  //               }
  //
  //               return DropdownButtonFormField<String>(
  //                 decoration: InputDecoration(
  //                   labelText: 'Tên môn học',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 value: selectedSubjectId,
  //                 items: subjects.map((subject) {
  //                   return DropdownMenuItem<String>(
  //                     value: subject.id,
  //                     child: Text(subject.subject),
  //                   );
  //                 }).toList(),
  //                 onChanged: (value) {
  //                   setState(() {
  //                     selectedSubjectId = value;
  //                     selectedSubjectName = subjects.firstWhere((s) => s.id == value).subject;
  //                   });
  //                 },
  //               );
  //             },
  //           ),
  //           SizedBox(height: 16),
  //           TextField(
  //             controller: deadlineController,
  //             decoration: InputDecoration(
  //               labelText: 'Tên deadline',
  //               hintText: 'Nhập tên deadline',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: () async {
  //               DateTime? pickedDate = await showDatePicker(
  //                 context: context,
  //                 initialDate: selectedDate,
  //                 firstDate: DateTime.now(),
  //                 lastDate: DateTime(2100),
  //               );
  //               if (pickedDate != null) {
  //                 setState(() {
  //                   selectedDate = DateTime(
  //                     pickedDate.year,
  //                     pickedDate.month,
  //                     pickedDate.day,
  //                     selectedDate.hour,
  //                     selectedDate.minute,
  //                   );
  //                 });
  //               }
  //             },
  //             child: Text('Chọn ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
  //           ),
  //           SizedBox(height: 8),
  //           ElevatedButton(
  //             onPressed: () async {
  //               TimeOfDay? pickedTime = await showTimePicker(
  //                 context: context,
  //                 initialTime: TimeOfDay.fromDateTime(selectedDate),
  //               );
  //               if (pickedTime != null) {
  //                 setState(() {
  //                   selectedDate = DateTime(
  //                     selectedDate.year,
  //                     selectedDate.month,
  //                     selectedDate.day,
  //                     pickedTime.hour,
  //                     pickedTime.minute,
  //                   );
  //                 });
  //               }
  //             },
  //             child: Text('Chọn giờ: ${TimeOfDay.fromDateTime(selectedDate).format(context)}'),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Hủy'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (selectedSubjectId == null || deadlineController.text.isEmpty) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
  //               );
  //               return;
  //             }
  //             DeadlineModel newDeadline = DeadlineModel(
  //               id: DateTime.now().millisecondsSinceEpoch.toString(),
  //               day: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
  //               timeStart: selectedDate,
  //               timeEnd: selectedDate.add(Duration(hours: 1)),
  //               subject: selectedSubjectName!,
  //               deadlineName: deadlineController.text,
  //               deadlineColor: selectedColor,
  //             );
  //             _deadlineService.addDeadline(newDeadline).then((_) {
  //               Navigator.pop(context);
  //             });
  //           },
  //           child: Text('Thêm'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
        title: Text(
          'Thêm Deadline',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chọn môn học
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
                // Nhập tên deadline
                TextField(
                  controller: deadlineController,
                  decoration: InputDecoration(
                    labelText: 'Tên deadline',
                    hintText: 'Nhập tên deadline',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Chọn ngày
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
                          selectedDate.minute,
                        );
                      });
                    }
                  },
                  child: Text(
                    'Chọn ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                ),
                SizedBox(height: 8),
                // Chọn giờ
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
            );
          },
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

              // Create deadline in Firebase
              DeadlineModel newDeadline = DeadlineModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                day: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                //timeStart: selectedDate,
                timeEnd: selectedDate,
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

  // void _showExportDialog(SubjectModel subject) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Xuất lịch'),
  //       content: Text('Bạn muốn xuất "${subject.subject}" sang ứng dụng Lịch?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Hủy'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             try {
  //               await _calendarService.exportSubjectToCalendar(subject);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Đã xuất lịch thành công')),
  //               );
  //             } catch (e) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Lỗi: ${e.toString()}')),
  //               );
  //             }
  //           },
  //           child: Text('Xuất'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _exportToExcel() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get all subjects
      final subjects = await _subjectService.getAllSubjects().first;

      // Export to Excel
      final filePath = await _subjectService.exportTimetableToExcel(subjects);

      // Hide loading dialog
      Navigator.pop(context);

      // Show success message with file location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đã xuất thời khóa biểu thành công'),
          Text('Lưu tại: $filePath', style: TextStyle(fontSize: 12)),
            ],
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      Text('Lưu tại: $filePath', style: TextStyle(fontSize: 12));
    } catch (e) {
      // Hide loading dialog if error occurs
      Navigator.pop(context);

      // Show error message
      print(Text('Lỗi khi xuất file: ${e.toString()}'));
    }
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