import 'package:flutter/material.dart';
import '../theme.dart';

class CircularVisualizer extends StatelessWidget {
  final double score;
  final String label;
  final String value;
  final Color color;

  const CircularVisualizer({
    super.key,
    required this.score,
    required this.label,
    required this.value,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 2,
                color: color,
                backgroundColor: color.withValues(alpha: 0.1),
              ),
            ),
            // Ambient glow effect
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
