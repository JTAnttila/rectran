import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/recording/domain/recording_status.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecordingController>();
    final isRecording = controller.status == RecordingStatus.recording;
    final isPaused = controller.status == RecordingStatus.paused;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer display
                  Text(
                    _formatElapsed(controller.elapsed),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quality indicator
                  Text(
                    _getQualityLabel(controller),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  // Waveform (only visible when recording)
                  if (isRecording) ...[
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 100,
                      child: _MinimalistWaveform(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Bottom controls
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flag button (left)
                  _ControlButton(
                    icon: Icons.flag_outlined,
                    size: 48,
                    onPressed: () {
                      // Add flag/marker functionality
                    },
                  ),
                  
                  // Main record/pause button (center)
                  GestureDetector(
                    onTap: () {
                      controller.toggleRecording();
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF4757),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording || isPaused ? Icons.pause : Icons.fiber_manual_record,
                        color: Colors.white,
                        size: isRecording || isPaused ? 40 : 32,
                      ),
                    ),
                  ),
                  
                  // Save/Stop button (right)
                  _ControlButton(
                    icon: isRecording || isPaused ? Icons.stop : Icons.save_outlined,
                    size: 48,
                    onPressed: () async {
                      if (isRecording || isPaused) {
                        await controller.stopRecording();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getQualityLabel(RecordingController controller) {
    // You can customize this based on actual recording settings
    return 'Standard quality';
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white70),
      iconSize: 28,
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        shape: const CircleBorder(),
      ),
    );
  }
}

class _MinimalistWaveform extends StatefulWidget {
  @override
  State<_MinimalistWaveform> createState() => _MinimalistWaveformState();
}

class _MinimalistWaveformState extends State<_MinimalistWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = List.generate(60, (i) => 0.3 + (i % 7) * 0.1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() {
        setState(() {
          // Update bar heights to simulate audio visualization
          for (int i = 0; i < _barHeights.length; i++) {
            // Create wave-like animation with varying heights
            final baseHeight = 0.2 + (i % 5) * 0.15;
            final variation = (DateTime.now().millisecondsSinceEpoch / 100 + i) % 10 / 10;
            _barHeights[i] = baseHeight + variation * 0.4;
          }
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveformPainter(_barHeights),
      size: const Size(double.infinity, 100),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;

  _WaveformPainter(this.barHeights);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = barHeights.length;
    final barWidth = 2.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final heightFactor = barHeights[i].clamp(0.0, 1.0);
      final barHeight = size.height * heightFactor;
      final y1 = (size.height - barHeight) / 2;
      final y2 = y1 + barHeight;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}
