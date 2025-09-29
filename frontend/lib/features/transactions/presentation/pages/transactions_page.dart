import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/add_transaction_dialog.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/filter_indicator.dart';
import '../widgets/transaction_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardLoaded) {
          context.read<TransactionsBloc>().updateTransactions(state.recentTransactions);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context, l10n),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return ErrorState(failure: state.failure);
            }

            if (state is DashboardLoaded) {
              // Ensure TransactionsBloc is updated when DashboardLoaded is emitted
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<TransactionsBloc>().updateTransactions(state.recentTransactions);
              });
              return _buildTransactionsList(context, l10n);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          return state.showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchTransactions,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  onChanged: (value) {
                    context.read<TransactionsBloc>().add(TransactionsSearchChanged(value));
                  },
                )
              : Text(l10n.transactions);
        },
      ),
      automaticallyImplyLeading: false,
      actions: [
        BlocBuilder<TransactionsBloc, TransactionsState>(
          builder: (context, state) {
            if (!state.showSearch) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.read<TransactionsBloc>().add(TransactionsSearchToggled());
                    },
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  context.read<TransactionsBloc>().add(TransactionsSearchToggled());
                  _searchController.clear();
                  context.read<TransactionsBloc>().add(const TransactionsSearchChanged(''));
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        // If we have transactions but no filtered ones, show empty state
        if (state.filteredTransactions.isEmpty) {
          // If we have allTransactions but no filtered ones, it means filters are applied
          if (state.allTransactions.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'No transactions match your filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Try adjusting your search or filter criteria',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            );
          }
          return const EmptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.allTransactions} (${state.filteredTransactions.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const FilterIndicator(),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: state.filteredTransactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final transaction = state.filteredTransactions[index];
                    return TransactionCard(transaction: transaction);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddTransactionDialog(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;
    List<Map<String, dynamic>>? categories;

    if (dashboardState is DashboardLoaded) {
      categories = dashboardState.categories;
    }

    showDialog(
      context: context,
      builder: (context) => FilterDialog(categories: categories),
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
