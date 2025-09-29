import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/theme_extensions.dart';
import '../../../../core/constants/app_sizes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.textPrimary,
              ),
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: AppLocalizations.of(context).addIncome,
                icon: Icons.add_circle,
                color: Theme.of(context).colorScheme.income,
                onTap: () {
                  // TODO: Navigate to add income
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _QuickActionCard(
                title: AppLocalizations.of(context).addExpense,
                icon: Icons.remove_circle,
                color: Theme.of(context).colorScheme.expense,
                onTap: () {
                  // TODO: Navigate to add expense
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: AppLocalizations.of(context).transfer,
                icon: Icons.swap_horiz,
                color: Theme.of(context).colorScheme.info,
                onTap: () {
                  // TODO: Navigate to transfer
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _QuickActionCard(
                title: AppLocalizations.of(context).viewReports,
                icon: Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  context.goNamed('analytics');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppSizes.iconLg,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
