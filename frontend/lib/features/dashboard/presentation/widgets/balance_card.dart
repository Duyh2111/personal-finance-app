import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/theme/theme_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/balance_entity.dart';

class BalanceCard extends StatelessWidget {
  final BalanceEntity balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: Theme.of(context).colorScheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).totalBalance,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.visibility_outlined,
                    color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () {
                  // TODO: Toggle balance visibility
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            formatter.format(balance.totalBalance),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: AppLocalizations.of(context).income,
                  amount: formatter.format(balance.income),
                  icon: Icons.trending_up,
                  color: Theme.of(context).colorScheme.income,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _BalanceItem(
                  label: AppLocalizations.of(context).expenses,
                  amount: formatter.format(balance.expenses),
                  icon: Icons.trending_down,
                  color: Theme.of(context).colorScheme.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          AppButton.secondary(
            text: AppLocalizations.of(context).viewDetails,
            size: AppButtonSize.small,
            onPressed: () {
              // TODO: Navigate to detailed balance view
            },
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconSm),
              const SizedBox(width: AppSizes.xs),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            amount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
