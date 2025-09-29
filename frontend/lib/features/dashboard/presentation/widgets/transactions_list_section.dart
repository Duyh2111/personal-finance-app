import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/utils/transaction_icon_utils.dart';
import '../../../../shared/widgets/transaction_item.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionsListSection extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback? onViewAll;

  const TransactionsListSection({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionItem(
              title: transaction.title,
              category: transaction.category,
              amount: transaction.amount,
              date: transaction.date,
              icon: TransactionIconUtils.getIconForCategory(transaction.category),
              onTap: () {
                // TODO: Navigate to transaction detail
              },
            );
          },
        ),
        if (onViewAll != null) ...[
          const SizedBox(height: AppSizes.lg),
          Center(
            child: OutlinedButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.list),
              label: const Text('View All Transactions'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.md,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Add your first transaction to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}