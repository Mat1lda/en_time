import 'package:en_time/views/pages/home/deadline_page.dart';
import 'package:en_time/views/pages/task_schedule/home_task_view.dart';
import 'package:en_time/views/pages/task_schedule/remind_task_view.dart';
import 'package:en_time/views/pages/time_table/custom_timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

        final deadlines = snapshot.data![0] as List<DeadlineModel>;
        final subjects = snapshot.data![1] as List;
        
        final upcomingDeadlines = deadlines.where((deadline) => 
          deadline.day.isAfter(DateTime.now())).length;
        
        final attendedSubjects = subjects.length;
        final completedTasks = tasks.where((t) => t.isDone).length;
        final totalTasks = tasks.length;

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
                    value: "$upcomingDeadlines/${deadlines.length} sắp tới",
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
                    value: "$attendedSubjects/5",
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
                  _buildLateRateDonutChart(tasks),
                  SizedBox(height: 20),
                  _buildFocusTimeHeatmap(tasks),
                  SizedBox(height: 20),
                  _buildWeeklyChartWidget(tasks),
                  SizedBox(height: 20),
                  _buildCompletionChartWidget(tasks),
                  SizedBox(height: 20),
                  _buildTaskTypeChart(tasks),
                  SizedBox(height: 20),
                  _buildSuggestions(tasks),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  //ty le tre han
  Widget _buildLateRateDonutChart(List<TaskModel> tasks) {
    int totalTasks = tasks.length;
    int lateTasks = tasks.where((task) => 
      !task.isDone && task.day.isBefore(DateTime.now())).length;
    double lateRate = totalTasks > 0 ? lateTasks / totalTasks : 0;

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
            'Tỉ lệ trễ hạn các nhiệm vụ',
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

  Widget _buildSuggestions(List<TaskModel> tasks) {
    return Container(
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
            'Gợi ý cải thiện',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bạn hay trễ thứ 5, hãy chuẩn bị từ thứ 4.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bạn học tốt lúc 9-11h, nên đặt task chính vào khung giờ đó.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
    );
  }

  Widget _buildFocusTimeHeatmap(List<TaskModel> tasks) {
    // Placeholder for focus time heatmap implementation
    return Container(
      height: 200,
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
      child: Center(
        child: Text(
          'đói content',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTypeChart(List<TaskModel> tasks) {
    // Placeholder for task type chart implementation
    return Container(
      height: 200,
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
      child: Center(
        child: Text(
          'đói content 2',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}