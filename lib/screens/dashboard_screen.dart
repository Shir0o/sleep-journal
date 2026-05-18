import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/circular_visualizer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THURSDAY, OCT 12',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 48),
          const CircularVisualizer(
            score: 84,
            label: 'SLEEP SCORE',
            value: '84',
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '91',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'STABILITY',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildInsightCard(context),
          const SizedBox(height: 48),
          _buildLifestyleCorrelations(context),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.secondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your deep sleep was restored tonight, likely aided by finishing dinner 3 hours before bed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCorrelations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIFESTYLE CORRELATIONS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildCorrelationItem(context, Icons.devices, 'Screen Time', '< 1h'),
        _buildCorrelationItem(context, Icons.medication, 'Magnesium', 'Taken'),
        _buildCorrelationItem(context, Icons.local_cafe, 'Late Caffeine', 'None'),
        const SizedBox(height: 16),
        Center(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: AppTheme.onSurfaceMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
