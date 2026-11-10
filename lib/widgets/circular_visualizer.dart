import 'package:flutter/material.dart';

class CircularVisualizer extends StatelessWidget {
  final double score;
  final String label;
  final String value;
  final Color? color;

  const CircularVisualizer({
    super.key,
    required this.score,
    required this.label,
    required this.value,
    this.color,
  });

  /// Diameter of the progress arc. The inner text must stay inside it.
  static const double _diameter = 200;

  /// Gap between the text block and the arc, in logical pixels.
  static const double _textInset = 28;

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(
          width: _diameter,
          height: _diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 2,
                  color: accent,
                  backgroundColor: accent.withValues(alpha: 0.1),
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
                      accent.withValues(alpha: 0.15),
                      accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // The label and score grow with the user's text scale, so clamp
              // the scale and shrink-to-fit inside the arc. Without this the
              // score collides with the fixed 200px progress indicator at
              // large text scales.
              Padding(
                padding: const EdgeInsets.all(_textInset),
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.25,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          value,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 64),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
