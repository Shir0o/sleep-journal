import 'package:flutter/material.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SETTINGS',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          _buildSectionHeader(context, 'INTEGRATIONS'),
          _buildSettingsItem(context, 'Oura Ring', status: 'Connected', isConnected: true),
          _buildSettingsItem(context, 'Apple Health', status: 'Disconnected', isConnected: false),
          const SizedBox(height: 48),
          _buildSectionHeader(context, 'PREFERENCES'),
          _buildSettingsItem(context, 'Notifications'),
          _buildSettingsItem(context, 'Privacy'),
          const SizedBox(height: 64),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Log Out',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.tertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, {String? status, bool? isConnected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (status != null) ...[
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isConnected == true ? AppTheme.primary : AppTheme.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right, color: AppTheme.onSurfaceMuted, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
        ],
      ),
    );
  }
}
