import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject_model.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SubjectService {
  final CollectionReference _subjectsCollection = FirebaseFirestore.instance.collection('subjects');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addSubject(SubjectModel subject) async {
    try {
      await _subjectsCollection.doc(subject.id).set({
        ...subject.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to add subject: $e');
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _subjectsCollection.doc(subjectId).delete();
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }

  Future<void> updateSubject(SubjectModel subject) async {
    try {
      await _subjectsCollection.doc(subject.id).update({
        ...subject.toMap(),
        'userId': _currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to update subject: $e');
    }
  }

  Stream<List<SubjectModel>> getAllSubjects() {
    return _subjectsCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final subjects = snapshot.docs.map((doc) {
            return SubjectModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).toList();
          // Sort subjects by range start date and time
          subjects.sort((a, b) {
            // First sort by range start date
            final dateCompare = a.rangeStart.compareTo(b.rangeStart);
            if (dateCompare != 0) return dateCompare;
            // If dates are equal, sort by start time
            return a.timeStart.compareTo(b.timeStart);
          });
          return subjects;
        });
  }

  Stream<List<SubjectModel>> getSubjectsByDay(DateTime day) {
    // Convert DateTime to start and end of the day for query
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _subjectsCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final subjects = snapshot.docs.map((doc) {
            return SubjectModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }).where((subject) {
            // Check if the day falls within the subject's range and matches weekday
            return subject.rangeStart.compareTo(endOfDay) <= 0 && 
                   subject.rangeEnd.compareTo(startOfDay) >= 0 && 
                   subject.weekdays.contains(day.weekday);
          }).toList();
          
          // Sort subjects by time
          subjects.sort((a, b) => a.timeStart.compareTo(b.timeStart));
          return subjects;
        });
  }

  Future<List<SubjectModel>> getUpcomingSubjects({int limit = 3}) async {
    try {
      final snapshot = await _subjectsCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final now = DateTime.now();
      final upcomingSubjects = <SubjectModel>[];

      // Process each subject
      for (var doc in snapshot.docs) {
        final subject = SubjectModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });

        // Check if the subject's range includes current date
        if (subject.rangeEnd.isAfter(now)) {
          // Find the next occurrence of this subject
          DateTime current = now;
          while (current.isBefore(subject.rangeEnd)) {
            if (subject.weekdays.contains(current.weekday)) {
              final nextOccurrence = DateTime(
                current.year,
                current.month,
                current.day,
                subject.timeStart.hour,
                subject.timeStart.minute,
              );

              if (nextOccurrence.isAfter(now)) {
                // Create a copy of the subject with the next occurrence time
                final upcomingSubject = SubjectModel(
                  id: subject.id,
                  rangeStart: subject.rangeStart,
                  rangeEnd: subject.rangeEnd,
                  timeStart: nextOccurrence,
                  timeEnd: DateTime(
                    current.year,
                    current.month,
                    current.day,
                    subject.timeEnd.hour,
                    subject.timeEnd.minute,
                  ),
                  subject: subject.subject,
                  subjectColor: subject.subjectColor,
                  weekdays: subject.weekdays,
                );
                upcomingSubjects.add(upcomingSubject);
                break;
              }
            }
            current = current.add(Duration(days: 1));
          }
        }
      }

      // Sort by the next occurrence time
      upcomingSubjects.sort((a, b) => a.timeStart.compareTo(b.timeStart));

      return upcomingSubjects.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming subjects: $e');
    }
  }

  Future<String> exportTimetableToExcel(List<SubjectModel> subjects) async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Thời khóa biểu'];

      // Add headers with style
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#92A3FD',
        fontColorHex: '#FFFFFF',
      );

      _addCell(sheet, 0, 0, 'Môn học', headerStyle);
      _addCell(sheet, 0, 1, 'Thời gian', headerStyle);
      _addCell(sheet, 0, 2, 'Các ngày', headerStyle);
      _addCell(sheet, 0, 3, 'Từ ngày', headerStyle);
      _addCell(sheet, 0, 4, 'Đến ngày', headerStyle);

      // Add data
      int rowIndex = 1;
      for (var subject in subjects) {
        final weekdayNames = _getWeekdayNames(subject.weekdays);

        _addCell(sheet, rowIndex, 0, subject.subject);
        _addCell(sheet, rowIndex, 1, '${_formatTime(subject.timeStart)} - ${_formatTime(subject.timeEnd)}');
        _addCell(sheet, rowIndex, 2, weekdayNames);
        _addCell(sheet, rowIndex, 3, _formatDate(subject.rangeStart));
        _addCell(sheet, rowIndex, 4, _formatDate(subject.rangeEnd));

        rowIndex++;
      }

      // Auto-fit columns
      sheet.setColWidth(0, 30);
      sheet.setColWidth(1, 20);
      sheet.setColWidth(2, 35);
      sheet.setColWidth(3, 15);
      sheet.setColWidth(4, 15);

      // Save to Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final String path = '${directory.path}/thoikhoabieu.xlsx';
      final File file = File(path);
      await file.writeAsBytes(excel.encode()!);

      return path;
    } catch (e) {
      throw Exception('Lỗi khi xuất file Excel: $e');
    }
  }

  void _addCell(Sheet sheet, int row, int col, String value, [CellStyle? style]) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = value;
    if (style != null) {
      cell.cellStyle = style;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getWeekdayNames(List<int> weekdays) {
    final Map<int, String> weekdayMap = {
      1: 'Thứ 2',
      2: 'Thứ 3',
      3: 'Thứ 4',
      4: 'Thứ 5',
      5: 'Thứ 6',
      6: 'Thứ 7',
      7: 'Chủ nhật',
    };
    return weekdays.map((day) => weekdayMap[day] ?? '').join(', ');
  }
}