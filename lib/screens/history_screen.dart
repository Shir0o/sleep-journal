import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORY',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your circadian rhythm logs and atmospheric transitions over time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 48),
          _buildHistoryItem(
            context,
            'OCT 11',
            75,
            'Restorative period. The transition from ambient alertness to rest was smooth, indicating a synchronized circadian rhythm. Deep atmospheric phases were sustained without interruption.',
          ),
          _buildHistoryItem(
            context,
            'OCT 10',
            42,
            'Late dinner. Restless sleep. Elevated luminance detected during intended dark phases, disrupting the natural restorative cycle.',
          ),
          _buildHistoryItem(
            context,
            'OCT 09',
            61,
            'Moderate alignment. Initial onset of rest was delayed, but the core dark phase remained relatively stable with minor shifts in luminance.',
          ),
          _buildHistoryItem(
            context,
            'OCT 08',
            82,
            'Optimal atmospheric immersion. Perfect adherence to anticipated light/dark boundaries resulting in profound restoration.',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String date, int score, String description) {
    Color scoreColor = score > 80 
        ? AppTheme.secondary 
        : (score > 60 ? AppTheme.primary : AppTheme.tertiary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2.0,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stability Score',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
        ],
      ),
    );
  }
}
