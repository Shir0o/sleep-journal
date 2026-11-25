import 'package:flutter/material.dart';

/// One evening lifestyle factor the user can cycle through.
class _LogFactor {
  const _LogFactor({
    required this.icon,
    required this.label,
    required this.values,
  });

  final IconData icon;
  final String label;
  final List<String> values;
}

/// The evening factors mirrored from the dashboard's lifestyle correlations.
const List<_LogFactor> _factors = <_LogFactor>[
  _LogFactor(
    icon: Icons.devices,
    label: 'Screen Time',
    values: <String>['< 1 h', '1-2 h', '2+ h'],
  ),
  _LogFactor(
    icon: Icons.medication,
    label: 'Magnesium',
    values: <String>['Taken', 'Skipped'],
  ),
  _LogFactor(
    icon: Icons.local_cafe,
    label: 'Late Caffeine',
    values: <String>['None', 'After 2 PM'],
  ),
  _LogFactor(
    icon: Icons.dinner_dining,
    label: 'Dinner Timing',
    values: <String>['3+ h before bed', '< 3 h before bed'],
  ),
];

/// Calm, editorial log for tonight's evening habits.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final List<int> _selection = List<int>.filled(_factors.length, 0);
  bool _saved = false;

  void _cycleFactor(int index) {
    setState(() {
      _selection[index] =
          (_selection[index] + 1) % _factors[index].values.length;
      _saved = false;
    });
  }

  void _save() {
    setState(() {
      _saved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('LOG', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              "Log tonight's evening habits to refine your sleep correlations.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'EVENING HABITS',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            for (int index = 0; index < _factors.length; index++)
              _buildFactorRow(context, index),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                child: Text(_saved ? 'Update Evening Log' : 'Save Evening Log'),
              ),
            ),
            if (_saved) ...<Widget>[
              const SizedBox(height: 12),
              _buildConfirmation(context),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(BuildContext context, int index) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final _LogFactor factor = _factors[index];
    final String value = factor.values[_selection[index]];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        container: true,
        button: true,
        label: '${factor.label}: $value',
        hint: 'Tap to change',
        excludeSemantics: true,
        child: Material(
          color: colors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: InkWell(
            onTap: () => _cycleFactor(index),
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(factor.icon, color: colors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(factor.label, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                color: colors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  value,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.check_circle, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Saved for tonight', style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
