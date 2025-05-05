import 'package:flutter/material.dart';
import 'package:en_time/database/services/subject_services.dart';
import 'package:en_time/database/models/subject_model.dart';
import 'package:intl/intl.dart';
import 'package:en_time/components/colors.dart';

import 'custom_timetable_screen.dart';

class SubjectOverviewView extends StatefulWidget {
  @override
  _SubjectOverviewViewState createState() => _SubjectOverviewViewState();
}

class _SubjectOverviewViewState extends State<SubjectOverviewView> {
  final SubjectService _subjectService = SubjectService();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tổng quan môn học',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor1),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: AppColors.primaryColor1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomTimetableScreem(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null && _endDate != null)
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: AppColors.primaryColor1),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Từ ${DateFormat('dd/MM/yyyy').format(_startDate!)} đến ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                      style: TextStyle(color: AppColors.primaryColor1),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryColor1),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<SubjectModel>>(
              stream: _subjectService.getAllSubjects(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Đã xảy ra lỗi: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                    color: AppColors.primaryColor1,
                  ));
                }

                List<SubjectModel> subjects = snapshot.data ?? [];

                if (_startDate != null && _endDate != null) {
                  subjects = subjects.where((subject) {
                    return subject.rangeStart.isBefore(_endDate!.add(Duration(days: 1))) &&
                           subject.rangeEnd.isAfter(_startDate!.subtract(Duration(days: 1)));
                  }).toList();
                }

                if (subjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, 
                          size: 64, 
                          color: AppColors.primaryColor1
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có môn học nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: subjects.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: subject.subjectColor,
                          radius: 25,
                          child: Text(
                            subject.subject.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          subject.subject,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '${_formatTime(subject.timeStart)} - ${_formatTime(subject.timeEnd)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  _getWeekdayNames(subject.weekdays),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '${DateFormat('dd/MM/yyyy').format(subject.rangeStart)} - ${DateFormat('dd/MM/yyyy').format(subject.rangeEnd)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getWeekdayNames(List<int> weekdays) {
    final Map<int, String> weekdayMap = {
      1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN',
    };
    return weekdays.map((day) => weekdayMap[day] ?? '').join(', ');
  }

  void _showFilterDialog() async {
    DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor1,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
  }
}