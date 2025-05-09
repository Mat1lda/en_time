import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/models/deadline_model.dart';
import '../../../database/models/subject_model.dart';
import '../../../database/services/deadline_services.dart';
import '../../../database/services/subject_services.dart';
import '../../../components/colors.dart';
import 'package:en_time/views/pages/home/noti_deadline_page.dart';

class DeadlinePage extends StatefulWidget {
  @override
  State<DeadlinePage> createState() => _DeadlinePageState();
}

class _DeadlinePageState extends State<DeadlinePage> {
  final DeadlineService _deadlineService = DeadlineService();
  final SubjectService _subjectService = SubjectService();
  final List<Color> _colorCollection = <Color>[];

  @override
  void initState() {
    super.initState();
    _getColorCollection();
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

  String _getVietnameseFormattedDate(DateTime date) {
    String getVietnameseWeekday(int weekday) {
      switch (weekday) {
        case DateTime.monday:
          return 'Thứ hai';
        case DateTime.tuesday:
          return 'Thứ ba';
        case DateTime.wednesday:
          return 'Thứ tư';
        case DateTime.thursday:
          return 'Thứ năm';
        case DateTime.friday:
          return 'Thứ sáu';
        case DateTime.saturday:
          return 'Thứ bảy';
        case DateTime.sunday:
          return 'Chủ nhật';
        default:
          return '';
      }
    }
    return '${getVietnameseWeekday(date.weekday)}, ${date.day} tháng ${date.month} ${date.year}';
  }
  String _formatDate(DateTime date) {
    String getVietnameseWeekday(int weekday) {
      switch (weekday) {
        case DateTime.monday: return 'T2';
        case DateTime.tuesday: return 'T3';
        case DateTime.wednesday: return 'T4';
        case DateTime.thursday: return 'T5';
        case DateTime.friday: return 'T6';
        case DateTime.saturday: return 'T7';
        case DateTime.sunday: return 'CN';
        default: return '';
      }
    }

    return '${getVietnameseWeekday(date.weekday)}, ${date.day}/${date.month}';
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Hàm xử lý sự kiện khi bấm vào icon thông báo
  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDeadlinePage(), // Màn hình thông báo deadline
      ),
    );
  }

  void _showAddDeadlineDialog() {
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
                idSubject: selectedSubjectId!,
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

  void _showDeadlineDetails(DeadlineModel deadline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          deadline.deadlineName,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: deadline.deadlineColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  deadline.subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  "Ngày hết hạn: " + _formatDate(deadline.day),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  _formatTime(deadline.timeEnd),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (deadline.isDone)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Đã hoàn thành',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          if (!deadline.isDone)
            TextButton(
              onPressed: () {
                DeadlineModel updatedDeadline = DeadlineModel(
                  id: deadline.id,
                  day: deadline.day,
                  //timeStart: deadline.timeStart,
                  timeEnd: deadline.timeEnd,
                  subject: deadline.subject,
                  idSubject: deadline.idSubject,
                  deadlineName: deadline.deadlineName,
                  deadlineColor: deadline.deadlineColor,
                  isDone: true,
                );
                _deadlineService.updateDeadline(updatedDeadline).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đánh dấu deadline hoàn thành'),
                      action: SnackBarAction(
                        label: 'Hoàn tác',
                        textColor: Colors.white,
                        onPressed: () {
                          DeadlineModel undoDeadline = DeadlineModel(
                            id: deadline.id,
                            day: deadline.day,
                            //timeStart: deadline.timeStart,
                            timeEnd: deadline.timeEnd,
                            subject: deadline.subject,
                            idSubject: deadline.idSubject,
                            deadlineName: deadline.deadlineName,
                            deadlineColor: deadline.deadlineColor,
                            isDone: false,
                          );
                          _deadlineService.updateDeadline(undoDeadline).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã hoàn tác')),
                            );
                          });
                        },
                      ),
                    ),
                  );
                });
              },
              child: Text('Đánh dấu hoàn thành'),
            ),
          if (deadline.isDone)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    DeadlineModel updatedDeadline = DeadlineModel(
                      id: deadline.id,
                      day: deadline.day,
                      //timeStart: deadline.timeStart,
                      timeEnd: deadline.timeEnd,
                      subject: deadline.subject,
                      idSubject: deadline.idSubject,
                      deadlineName: deadline.deadlineName,
                      deadlineColor: deadline.deadlineColor,
                      isDone: false,
                    );
                    _deadlineService.updateDeadline(updatedDeadline).then((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã hoàn tác')),
                      );
                    });
                  },
                  child: Text('Hoàn tác'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(deadline);
                    },
                  child: Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DeadlineModel deadline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Xác nhận xóa',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Text('Bạn có chắc muốn xóa deadline "${deadline.deadlineName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _deadlineService.deleteDeadline(deadline.id).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa deadline'),
                    backgroundColor: Colors.grey,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(16),
                  ),
                );
              });
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDeadlineDialog();
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey[50],
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
          "Quản lý deadline",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child:
            IconButton(
              onPressed: () => _navigateToNotifications(context), // Sự kiện bấm vào icon thông báo
              icon: Icon(Icons.notifications_active, color: AppColors.primaryColor1),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getVietnameseFormattedDate(DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewCard(
                            title: "Deadline hôm nay",
                            value: StreamBuilder<List<DeadlineModel>>(
                              stream: _deadlineService.getDeadlinesByDay(DateTime.now()),
                              builder: (context, snapshot) {
                                final int deadlineCount = snapshot.data?.length ?? 0;
                                return Text(
                                  "$deadlineCount",
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
                            title: "Sắp tới",
                            value: StreamBuilder<List<DeadlineModel>>(
                              stream: _deadlineService.getUpcomingDeadlines(),
                              builder: (context, snapshot) {
                                final upcomingCount = snapshot.data?.length ?? 0;
                                return Text(
                                  "$upcomingCount",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                );
                              },
                            ),
                            icon: Icons.upcoming,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    // Deadlines List
                    Text(
                      "Danh sách deadline",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 15),
                    StreamBuilder<List<DeadlineModel>>(
                      stream: _deadlineService.getAllDeadlines(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final deadlines = snapshot.data ?? [];

                        if (deadlines.isEmpty) {
                          return Container(
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
                              children: [
                                Icon(Icons.event_busy, size: 50, color: Colors.grey[400]),
                                SizedBox(height: 10),
                                Text(
                                  'Không có deadline nào',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: deadlines.length,
                          itemBuilder: (context, index) {
                            final deadline = deadlines[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => _showDeadlineDetails(deadline),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: deadline.deadlineColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        deadline.isDone ? Icons.check_circle : Icons.event,
                                        color: deadline.deadlineColor,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            deadline.deadlineName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              decoration: deadline.isDone ? TextDecoration.lineThrough : null,
                                              color: deadline.isDone ? Colors.grey[600] : Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            deadline.subject,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              decoration: deadline.isDone ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(
                                                'Hạn: ${_formatTime(deadline.timeEnd)}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  decoration: deadline.isDone ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatDate(deadline.day),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        decoration: deadline.isDone ? TextDecoration.lineThrough : null,
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
  }) {
    return Container(
      padding: EdgeInsets.all(15),
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
          ),
        ],
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


}