import 'package:en_time/database/models/subject_model.dart';
import 'package:en_time/views/pages/home/deadline_page.dart';
import 'package:en_time/views/pages/task_schedule/home_task_view.dart';
import 'package:en_time/views/pages/task_schedule/remind_task_view.dart';
import 'package:en_time/views/pages/time_table/custom_timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../components/colors.dart';
import '../../../database/models/deadline_model.dart';
import '../../../database/services/task_services.dart';
import '../../../database/models/task_model.dart';
import '../../../database/services/deadline_services.dart';
import '../../../database/services/subject_services.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final TaskService _taskService = TaskService();
  final DeadlineService _deadlineService = DeadlineService();
  final SubjectService _subjectService = SubjectService();


  List<String> getImprovementSuggestions({
    required List<TaskModel> tasks,
    required List<DeadlineModel> deadlines,
    required List<SubjectModel> subjects,
  }) {
    List<String> suggestions = [];

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = monday.add(Duration(days: 7));

    final weekTasks = tasks.where((task) =>
    task.day.isAfter(monday.subtract(const Duration(days: 1))) &&
        task.day.isBefore(endOfWeek)).toList();

    final studyTasks = weekTasks.where((t) => t.taskType == 'Học').toList();
    final completedTasks = weekTasks.where((t) => t.isDone).toList();

    DateTime? _parseTime(String timeStr) {
      try {
        return DateFormat.Hm().parse(timeStr);
      } catch (_) {
        return null;
      }
    }

    // 1. Học quá ít
    if (studyTasks.length < 3) {
      suggestions.add("Tuần qua bạn học rất ít. Hãy đặt mục tiêu tối thiểu 1 môn/ngày để duy trì tiến độ nhé!");
    }

    // 2. Học ít vào khung giờ hiệu quả (20h-23h)
    final nightStudy = studyTasks.where((t) {
      final time = _parseTime(t.timeStart);
      return time != null && time.hour >= 20 && time.hour <= 23;
    }).length;
    if (studyTasks.isNotEmpty && nightStudy < studyTasks.length * 0.3) {
      suggestions.add("Bạn học hiệu quả nhất trong khung 8–11h tối. Hãy lên lịch học chính vào giờ này!");
    }

    // 3. Học quá muộn (sau 23h hoặc trước 7h)
    final lateOrEarly = studyTasks.where((t) {
      final time = _parseTime(t.timeStart);
      return time != null && (time.hour > 23 || time.hour < 7);
    }).length;
    if (lateOrEarly >= 3) {
      suggestions.add("Bạn hay học/làm việc quá khuya hoặc quá sớm. Hãy điều chỉnh lại giờ giấc để đảm bảo sức khỏe.");
    }

    // 4. Trễ deadline
    final missedDeadlines = deadlines.where((d) =>
    d.timeEnd.isBefore(now) && !d.isDone).length;
    if (missedDeadlines >= 2) {
      suggestions.add("Bạn trễ hạn nhiều deadline. Hãy đặt nhắc nhở sớm hơn 1–2 ngày nhé!");
    }

    // 5. Có ngày không học
    Map<int, List<TaskModel>> dayMap = {
      for (int i = 1; i <= 7; i++) i: [],
    };
    for (var task in weekTasks) {
      dayMap[task.day.weekday]?.add(task);
    }
    final emptyDays = dayMap.values.where((tasks) => tasks.isEmpty).length;
    if (emptyDays > 2) {
      suggestions.add("Lịch học của bạn chưa đều. Hãy cố gắng duy trì thói quen học hằng ngày để tiến bộ nhanh hơn.");
    }

    // 6. Tỷ lệ hoàn thành thấp
    if (weekTasks.isNotEmpty && completedTasks.length / weekTasks.length < 0.5) {
      suggestions.add("Bạn hoàn thành chưa đến 50% task tuần qua. Hãy chia nhỏ task và đặt mục tiêu thực tế hơn.");
    }

    // 7. Có môn học nhưng không đặt task
    if (subjects.isNotEmpty && studyTasks.isEmpty) {
      suggestions.add("Bạn có môn học sắp tới nhưng chưa đặt task. Hãy thêm vào lịch để không bỏ sót bài học.");
    }

    // 8. Có task chưa đánh dấu hoàn thành
    final unmarkedDone = studyTasks.where((t) => !t.isDone).length;
    if (unmarkedDone >= 3) {
      suggestions.add("Bạn có nhiều task chưa đánh dấu hoàn thành. Hãy cập nhật tiến độ để theo dõi hiệu quả hơn.");
    }

    // 9. Quá nhiều task trong 1 ngày
    final overloadDays = dayMap.entries.where((e) => e.value.length >= 6).length;
    if (overloadDays >= 2) {
      suggestions.add("Bạn đặt quá nhiều task trong một ngày. Cân nhắc phân bổ hợp lý để tránh quá tải.");
    }

    // 10. Thiếu task thực hành
    final hasPractice = weekTasks.any((t) =>
    t.content.toLowerCase().contains('luyện') ||
        t.content.toLowerCase().contains('bài tập'));
    if (!hasPractice) {
      suggestions.add("Bạn chưa có task luyện tập/bài tập. Hãy thêm các hoạt động thực hành để hiểu bài sâu hơn.");
    }

    // 11. Không học vào cuối tuần
    final weekendTasks = weekTasks.where((t) => t.day.weekday == 6 || t.day.weekday == 7).toList();
    if (weekendTasks.isEmpty) {
      suggestions.add("Bạn không học vào cuối tuần. Cuối tuần là thời gian tốt để ôn lại kiến thức.");
    }

    // 12. Không có task ôn tập/môn đã học
    final hasReview = weekTasks.any((t) =>
    t.content.toLowerCase().contains('ôn') ||
        t.content.toLowerCase().contains('tổng hợp'));
    if (!hasReview) {
      suggestions.add("Bạn chưa có task ôn tập. Hãy thêm task tổng hợp lại kiến thức để ghi nhớ lâu hơn.");
    }

    // 13. Học dồn vào cuối tuần
    if (weekendTasks.length >= weekTasks.length * 0.5) {
      suggestions.add("Bạn học dồn vào cuối tuần. Cố gắng phân bố đều lịch học để giảm áp lực.");
    }

    // 14. Task bị trùng giờ
    final timeMap = <String, int>{};
    for (var t in weekTasks) {
      final key = '${t.day.day}-${t.timeStart}';
      timeMap[key] = (timeMap[key] ?? 0) + 1;
    }
    final hasConflict = timeMap.values.any((count) => count > 1);
    if (hasConflict) {
      suggestions.add("Có nhiều task trùng giờ. Hãy kiểm tra lại lịch để tránh xung đột.");
    }

    // 15. Task nhưng không có mô tả rõ ràng
    final unclearTasks = weekTasks.where((t) => t.content.trim().length < 10).length;
    if (unclearTasks >= 3) {
      suggestions.add("Một số task không có nội dung rõ ràng. Hãy viết chi tiết hơn để dễ thực hiện.");
    }

    return suggestions;
  }

  List<BarChartGroupData> _processWeeklyData(List<TaskModel> tasks) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    List<BarChartGroupData> weeklyData = [];
    
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayTasks = tasks.where((task) {
        return task.day.year == day.year && 
               task.day.month == day.month && 
               task.day.day == day.day;
      }).toList();

      final studyTasks = dayTasks.where((task) => 
        task.taskType == 'Hoạt động ngoại khóa' && task.isDone).length.toDouble();
      final personalTasks = dayTasks.where((task) => 
        task.taskType == 'Hoạt động cá nhân' && task.isDone).length.toDouble();

      weeklyData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: studyTasks,
            color: Colors.blue.withOpacity(0.7),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: personalTasks,
            color: Colors.purple.withOpacity(0.7),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }
    return weeklyData;
  }

  List<FlSpot> _processCompletionData(List<TaskModel> tasks) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    List<FlSpot> spots = [];
    double lastValidValue = 0;

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayTasks = tasks.where((task) {
        return task.day.year == day.year && 
               task.day.month == day.month && 
               task.day.day == day.day;
      }).toList();

      if (dayTasks.isEmpty) {
        spots.add(FlSpot(i.toDouble(), 0));
      } else {
        final completedTasks = dayTasks.where((task) => task.isDone).length;
        final completionRate = completedTasks / dayTasks.length;
        lastValidValue = completionRate;
        spots.add(FlSpot(i.toDouble(), completionRate));
      }
    } 
    return spots;
  }
  //card dau tien
  Widget _buildPerformanceCards(List<TaskModel> tasks) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _deadlineService.getAllDeadlines().first,
        _subjectService.getAllSubjects().first,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // final deadlines = snapshot.data![0] as List<DeadlineModel>;
        // final subjects = snapshot.data![1] as List;
        //
        // final upcomingDeadlines = deadlines.where((deadline) =>
        //   deadline.day.isAfter(DateTime.now())).length;
        //
        // final attendedSubjects = subjects.length;
        // final completedTasks = tasks.where((t) => t.isDone).length;
        // final totalTasks = tasks.length;

        // Điều kiện lọc theo tuần
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0); // Lấy thứ Hai (Monday) của tuần hiện tại

        final sunday = monday.add(Duration(days: 6)).copyWith(hour: 23, minute: 59, second: 59, millisecond: 999); // Lấy Chủ Nhật (Sunday) của tuần hiện tại
        // Lọc Task
        final weeklyTasks = tasks.where((task) =>
        task.day.isAfter(monday.subtract(const Duration(days: 1))) &&
            task.day.isBefore(sunday)).toList();
        final completedTasks = weeklyTasks.where((t) => t.isDone).length;
        final totalTasks = weeklyTasks.length;

        // Lọc Deadline
        final deadlines = snapshot.data![0] as List<DeadlineModel>;
        final weeklyDeadlines = deadlines.where((d) =>
        d.day.isAfter(monday.subtract(const Duration(days: 1))) &&
            d.day.isBefore(sunday)).toList();
        final completedDeadlines = weeklyDeadlines.where((d) => d.isDone).length;
        final totalDeadlines = weeklyDeadlines.length;

        // Lọc môn học
        // final subjects = snapshot.data![1] as List;
        // final weeklySubject = subjects.where((d) =>
        // d.timeEnd.isAfter(monday.subtract(const Duration(days: 1))) &&
        //     d.timeEnd.isBefore(sunday)).toList();
        // final completedSub = weeklySubject.where((d) => d.timeEnd.isBefore(now)).length;

        final subjects = snapshot.data![1] as List;
        final subjectOccurrencesThisWeek = subjects.expand((subject) { // expand() để chuyển mỗi subject thành nhiều buổi học (dạng Map) diễn ra trong tuần hiện tại.
          final List<DateTime> occurrences = [];
          DateTime current = monday;
          while (current.isBefore(sunday.add(Duration(days: 1)))) { //  Duyệt từng ngày trong tuần hiện tại, từ thứ Hai (monday) đến Chủ Nhật (sunday).
            if (subject.rangeStart.isAfter(current) || subject.rangeEnd.isBefore(current)) {
              // Bỏ qua những ngày không nằm trong phạm vi học của môn (không nằm giữa rangeStart và rangeEnd).
              current = current.add(Duration(days: 1));
              continue;
            }
            if (subject.weekdays.contains(current.weekday)) {
              // Nếu ngày đó đúng thứ mà môn học có trong subject.weekdays (VD: [2, 4, 6] tức là T2, T4, T6), thì thêm vào danh sách buổi học.
              occurrences.add(current);
            }
            current = current.add(Duration(days: 1));
          }
          return occurrences.map((date) => {
            //Kết quả cuối cùng là danh sách các buổi học cụ thể trong tuần hiện tại (đã ghép ngày + giờ kết thúc).
            'date': date,
            'timeEnd': DateTime(date.year, date.month, date.day, subject.timeEnd.hour, subject.timeEnd.minute),
          });
        }).toList();

        final totalSubjectsThisWeek = subjectOccurrencesThisWeek.length;
        final attendedSubjects = subjectOccurrencesThisWeek.where((occurrence) =>
            occurrence['timeEnd']!.isBefore(now)
        ).length;

        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RemindTaskView(),));
                  },
                  child: _buildPerformanceCard(
                    icon: Icons.task_alt,
                    title: "Task",
                    value: "$completedTasks/$totalTasks",
                    color: AppColors.primaryColor1,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DeadlinePage(),));
                  },
                  child: _buildPerformanceCard(
                    icon: Icons.alarm,
                    title: "Deadline",
                    value: "$completedDeadlines/$totalDeadlines",
                    color: Colors.orange,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomTimetableScreem(),));
                  },
                  child: _buildPerformanceCard(
                    icon: Icons.school,
                    title: "Lớp học",
                    value: "$attendedSubjects/$totalSubjectsThisWeek",
                    //value: "$completedSub/${weeklySubject.length}",
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getAllTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Thống kê hiệu suất',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerformanceCards(tasks),
                  Text(
                    'Biểu đồ hiệu suất học tập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildLateRateTaskChart(tasks),
                  SizedBox(height: 20),
                  _buildWeeklyChartWidget(tasks),
                  SizedBox(height: 20),
                  _buildCompletionChartWidget(tasks),
                  SizedBox(height: 20),
                  _buildLateDeadlineChart(),
                  SizedBox(height: 20),
                  _buildDeadlineCompletionChartWidget(),
                  SizedBox(height: 20),
                  _buildSuggestionsWidget(tasks),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tỷ lệ trễ hạn các Task
  Widget _buildLateRateTaskChart(List<TaskModel> tasks) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(Duration(days: 7));

    // Lọc các task trong tuần hiện tại
    final weeklyTasks = tasks.where((task) =>
    task.day.isAfter(monday.subtract(const Duration(days: 1))) &&
        task.day.isBefore(sunday)
    ).toList();

    // Đếm số task trễ hạn trong tuần
    final lateTasks = weeklyTasks.where((task) =>
    !task.isDone).length;

    final totalTasks = weeklyTasks.length;
    final lateRate = totalTasks > 0 ? lateTasks / totalTasks : 0.0;

    return Container(
      height: 250,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tỉ lệ các hoạt động chưa hoàn thàn trong tuần này',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.red,
                    value: lateRate * 100,
                    title: '${(lateRate * 100).toInt()}%',
                    radius: 40,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.grey[200],
                    value: 100 - (lateRate * 100),
                    radius: 40,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Biểu đồ cột thống kê các hoạt động trong tuần này
  Widget _buildWeeklyChartWidget(List<TaskModel> tasks) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Số lượng các hoạt động đã hoàn thành theo ngày",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ngoại khóa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Cá nhân',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barGroups: _processWeeklyData(tasks),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rodIndex == 0 ? "Ngoại khóa" : "Cá nhân"}\n${rod.toY.toInt()} nhiệm vụ',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Biểu đồ đường thống kê tỷ lệ hoàn thành các Task theo ngày
  Widget _buildCompletionChartWidget(List<TaskModel> tasks) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tỷ lệ hoàn thành các hoạt động theo ngày",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _processCompletionData(tasks),
                      isCurved: false,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor1,
                          AppColors.primaryColor1.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.primaryColor1,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryColor1.withOpacity(0.2),
                            AppColors.primaryColor1.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: EdgeInsets.all(8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Hoàn thành\n${(spot.y * 100).toInt()}%',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
    );
  }

  // Tỷ lệ trễ hạn các Deadline
  Widget _buildLateDeadlineChart() {
    return FutureBuilder<List<DeadlineModel>>(
      future: _deadlineService.getAllDeadlines().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(Duration(days: 7));

        final weeklyDeadlines = snapshot.data!.where((d) =>
        d.timeEnd.isAfter(monday.subtract(const Duration(days: 1))) &&
            d.timeEnd.isBefore(sunday)).toList();

        final lateDeadlines = weeklyDeadlines
            .where((d) => !d.isDone && d.timeEnd.isBefore(now))
            .length;

        final totalDeadlines = weeklyDeadlines.length;
        final lateRate = totalDeadlines > 0 ? lateDeadlines / totalDeadlines : 0.0;

        return Container(
          height: 250,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tỉ lệ trễ hạn deadline tuần này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: lateRate * 100,
                        title: '${(lateRate * 100).toInt()}%',
                        radius: 40,
                        titleStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.grey[300],
                        value: 100 - (lateRate * 100),
                        radius: 40,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Biểu đồ đường thống kê tỷ lệ hoàn thành các Deadline theo ngày
  Widget _buildDeadlineCompletionChartWidget() {
    return FutureBuilder<List<DeadlineModel>>(
      future: _deadlineService.getAllDeadlines().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final deadlines = snapshot.data!;
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));

        List<FlSpot> spots = [];

        for (int i = 0; i < 7; i++) {
          final day = monday.add(Duration(days: i));
          final dailyDeadlines = deadlines.where((d) =>
          d.timeEnd.year == day.year &&
              d.timeEnd.month == day.month &&
              d.timeEnd.day == day.day
          ).toList();

          if (dailyDeadlines.isEmpty) {
            spots.add(FlSpot(i.toDouble(), 0));
          } else {
            final completed = dailyDeadlines.where((d) => d.isDone).length;
            final completionRate = completed / dailyDeadlines.length;
            spots.add(FlSpot(i.toDouble(), completionRate));
          }
        }

        return Container(
          height: 250,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tỷ lệ hoàn thành các Deadline theo ngày",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange,
                            Colors.orange.withOpacity(0.5),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Colors.orange,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.orange.withOpacity(0.2),
                              Colors.orange.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipPadding: EdgeInsets.all(8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Hoàn thành deadline\n${(spot.y * 100).toInt()}%',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        );
      },
    );
  }

  // Gợi ý
  Widget _buildSuggestionsWidget(List<TaskModel> tasks) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _deadlineService.getAllDeadlines().first,
        _subjectService.getAllSubjects().first,
      ]).then((data) {
        final deadlines = data[0] as List<DeadlineModel>;
        final subjects = data[1] as List<SubjectModel>;

        return getImprovementSuggestions(
          tasks: tasks,
          deadlines: deadlines,
          subjects: subjects,
        );
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi khi lấy gợi ý: ${snapshot.error}"));
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return Text("Hiện tại không có gợi ý nào. Bạn đang làm rất tốt!");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gợi ý cải thiện hiệu suất",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(child: Text(s)),
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}