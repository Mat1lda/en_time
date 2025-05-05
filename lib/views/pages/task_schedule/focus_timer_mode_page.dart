import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../database/services/timer_services.dart';

class FocusTimerPage extends StatefulWidget {
  @override
  _FocusTimerPageState createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  final TimerService _timerService = TimerService();
  int _timeLeft = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  void _startTimer(int minutes) {
    setState(() => _isRunning = true);

    _timerService.startTimer(
      minutes,
          (timeLeft) {
        setState(() => _timeLeft = timeLeft);
      },
          () {
        setState(() => _isRunning = false);
      },
    );
  }

  void _stopTimer() {
    _timerService.stopTimer();
    setState(() {
      _isRunning = false;
      _timeLeft = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bộ đếm thời gian",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor1.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRunning)
                  Text(
                    _formatTime(_timeLeft),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            if (!_isRunning) ...[//spread op
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildTimeButton(1, "1 phút"),
                  _buildTimeButton(5, "5 phút"),
                  _buildTimeButton(10, "10 phút"),
                  _buildTimeButton(15, "15 phút"),
                  _buildTimeButton(20, "20 phút"),
                  _buildTimeButton(25, "25 phút"),
                  _buildTimeButton(45, "45 phút"),
                  _buildTimeButton(60, "60 phút"),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Chọn thời gian tập trung",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ] else
              ElevatedButton(
                onPressed: _stopTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Dừng",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes, String label) {
    return ElevatedButton(
      onPressed: () => _startTimer(minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor1,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}