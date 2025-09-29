import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveformPlaceholder extends StatelessWidget {
  const WaveformPlaceholder({
    required this.isActive,
    required this.color,
    super.key,
  });

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
  final random = math.Random();
  const barCount = 32;

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(barCount, (index) {
          final heightFactor = isActive
              ? 0.4 + random.nextDouble() * 0.6
              : 0.2 + random.nextDouble() * 0.2;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: 100 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
