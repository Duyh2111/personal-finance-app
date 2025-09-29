import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/theme/theme_extensions.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _transactionNotifications = true;
  bool _budgetAlerts = true;
  bool _monthlyReports = false;
  bool _securityAlerts = true;
  bool _appUpdates = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          _NotificationSection(
            title: 'Financial Notifications',
            items: [
              _NotificationItem(
                title: 'Transaction Alerts',
                subtitle: 'Get notified when transactions are processed',
                value: _transactionNotifications,
                onChanged: (value) => setState(() => _transactionNotifications = value),
              ),
              _NotificationItem(
                title: 'Budget Alerts',
                subtitle: 'Alerts when approaching budget limits',
                value: _budgetAlerts,
                onChanged: (value) => setState(() => _budgetAlerts = value),
              ),
              _NotificationItem(
                title: 'Monthly Reports',
                subtitle: 'Monthly financial summary reports',
                value: _monthlyReports,
                onChanged: (value) => setState(() => _monthlyReports = value),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _NotificationSection(
            title: 'Security & App',
            items: [
              _NotificationItem(
                title: 'Security Alerts',
                subtitle: 'Important security and login notifications',
                value: _securityAlerts,
                onChanged: (value) => setState(() => _securityAlerts = value),
              ),
              _NotificationItem(
                title: 'App Updates',
                subtitle: 'Notifications about new app features',
                value: _appUpdates,
                onChanged: (value) => setState(() => _appUpdates = value),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _NotificationSection(
            title: 'Marketing',
            items: [
              _NotificationItem(
                title: 'Promotional Emails',
                subtitle: 'Special offers and tips',
                value: _marketingEmails,
                onChanged: (value) => setState(() => _marketingEmails = value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  final String title;
  final List<_NotificationItem> items;

  const _NotificationSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      indent: AppSizes.md,
                      endIndent: AppSizes.md,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}