import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/add_transaction_dialog.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.add,
                label: 'Add Transaction',
                onPressed: () => _showAddTransactionDialog(context),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.analytics,
                label: 'View Analytics',
                onPressed: () {
                  // TODO: Navigate to analytics
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Manage Budget',
                onPressed: () {
                  // TODO: Navigate to budget
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;
    List<Map<String, dynamic>>? categories;

    if (dashboardState is DashboardLoaded) {
      categories = dashboardState.categories;
    }

    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        categories: categories,
        onTransactionAdded: (transactionData) {
          context.read<DashboardBloc>().add(DashboardRefreshRequested());
        },
      ),
    );
  }
}