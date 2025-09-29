import 'package:flutter/material.dart';

import 'package:rectran/features/recording/application/recording_controller.dart';

class RecordActionButtons extends StatelessWidget {
  const RecordActionButtons({
    required this.controller,
    super.key,
  });

  final RecordingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: controller.isProcessing ? null : controller.toggleRecording,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                controller.isRecording ? Icons.pause : Icons.mic,
                color: colorScheme.onPrimary,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.isRecording
              ? 'Tap to pause'
              : controller.isPaused
                  ? 'Tap to resume'
                  : 'Tap to record',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SecondaryActionButton(
              icon: Icons.delete_outline,
              label: 'Reset',
              onPressed: controller.isRecording
                  ? null
                  : () {
                      controller.clearHistory();
                    },
            ),
            const SizedBox(width: 24),
            _SecondaryActionButton(
              icon: Icons.stop_circle_outlined,
              label: 'Stop',
              onPressed: controller.isRecording || controller.isPaused
                  ? () {
                      controller.stopRecording();
                    }
                  : null,
              highlightColor: colorScheme.error,
            ),
            const SizedBox(width: 24),
            _SecondaryActionButton(
              icon: Icons.flag_outlined,
              label: 'Bookmark',
              onPressed: controller.isRecording ? () {} : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlightColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor:
                highlightColor?.withValues(alpha: isEnabled ? 0.15 : 0.05),
            foregroundColor: highlightColor ?? colorScheme.primary,
            minimumSize: const Size.square(56),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
