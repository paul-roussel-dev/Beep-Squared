import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alarm.dart';
import '../services/audio_preview_service.dart';

/// Screen displayed when an alarm is triggered
/// 
/// This screen appears over the lock screen and provides options to
/// dismiss or snooze the alarm. It includes a slide-to-dismiss gesture
/// and plays the alarm sound in a loop.
class AlarmScreen extends StatefulWidget {
  final Alarm alarm;
  final VoidCallback onDismiss;
  final VoidCallback onSnooze;

  const AlarmScreen({
    super.key,
    required this.alarm,
    required this.onDismiss,
    required this.onSnooze,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  
  final AudioPreviewService _audioService = AudioPreviewService.instance;
  double _dismissThreshold = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAlarmSound();
    _preventScreenTimeout();
  }

  void _initializeAnimations() {
    // Pulse animation for the alarm icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for dismiss gesture
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
  }

  void _startAlarmSound() async {
    if (widget.alarm.soundPath.isNotEmpty) {
      await _audioService.playAlarmLoop(widget.alarm.soundPath);
    }
  }

  void _stopAlarmSound() async {
    await _audioService.stopPreview();
  }

  void _preventScreenTimeout() {
    // Keep screen on while alarm is active
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _restoreScreenTimeout() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _stopAlarmSound();
    _restoreScreenTimeout();
    super.dispose();
  }

  void _handleDismiss() {
    _stopAlarmSound();
    widget.onDismiss();
  }

  void _handleSnooze() {
    _stopAlarmSound();
    widget.onSnooze();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo.shade900,
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Time display
                _buildTimeDisplay(),
                
                // Alarm info
                _buildAlarmInfo(),
                
                // Pulsing alarm icon
                _buildAlarmIcon(),
                
                // Dismiss slider
                _buildDismissSlider(),
                
                // Snooze button
                _buildSnoozeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return Column(
      children: [
        Text(
          timeString,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          _formatDate(now),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.alarm,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            widget.alarm.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scheduled for ${widget.alarm.formattedTime}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.alarm,
              color: Colors.white,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Slide to dismiss',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dismissThreshold = (details.localPosition.dx / context.size!.width).clamp(0.0, 1.0);
              });
            },
            onPanEnd: (details) {
              if (_dismissThreshold > 0.7) {
                _handleDismiss();
              } else {
                setState(() {
                  _dismissThreshold = 0.0;
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Progress indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: (MediaQuery.of(context).size.width - 48) * _dismissThreshold,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  // Slider thumb
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    left: (MediaQuery.of(context).size.width - 48 - 52) * _dismissThreshold,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _dismissThreshold > 0.7 ? Icons.check : Icons.keyboard_arrow_right,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Center text
                  if (_dismissThreshold < 0.3)
                    const Center(
                      child: Text(
                        'Dismiss Alarm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _handleSnooze,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.snooze),
            const SizedBox(width: 8),
            Text('Snooze ${widget.alarm.snoozeMinutes} min'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
