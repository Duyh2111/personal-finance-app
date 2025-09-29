import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/theme/theme_extensions.dart';

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
            size: AppSizes.iconLg,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            l10n.about,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'A comprehensive personal finance management application built with Flutter and FastAPI.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Icon(
                Icons.copyright,
                size: AppSizes.iconSm,
                color: Theme.of(context).colorScheme.textSecondary,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                '2024 Personal Finance App',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AppAboutDialog(),
    );
  }
}