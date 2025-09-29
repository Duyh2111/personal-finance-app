import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/theme_extensions.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../shared/widgets/transaction_item.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).recentTransactions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.textPrimary,
                  ),
            ),
            TextButton(
              onPressed: () {
                context.goNamed('transactions');
              },
              child: Text(AppLocalizations.of(context).viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        // Dynamic transaction list or empty state
        if (transactions.isEmpty)
          _EmptyTransactionsState()
        else
          ...transactions
              .map((transaction) => TransactionItem(
                    title: transaction.title,
                    category: transaction.category,
                    amount: transaction.amount,
                    date: transaction.date,
                    icon: IconHelper.getIconFromString(
                      transaction is TransactionModel
                          ? (transaction).iconName
                          : transaction.icon,
                    ),
                    onTap: () {
                      // TODO: Navigate to transaction details
                    },
                  ))
              .toList(),
      ],
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Start tracking your finances by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          FilledButton.icon(
            onPressed: () {
              context.goNamed('transactions');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
