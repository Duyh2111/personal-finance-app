import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/auth_error_handler.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/theme/theme_extensions.dart';
import '../../../../shared/widgets/add_transaction_dialog.dart';
import '../../../../shared/widgets/connectivity_wrapper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/balance_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_ui_bloc.dart';

class EnhancedDashboardPage extends StatelessWidget {
  const EnhancedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => getIt<DashboardBloc>()..add(DashboardInitialLoadRequested()),
        ),
        BlocProvider<DashboardUIBloc>(
          create: (context) => DashboardUIBloc(),
        ),
      ],
      child: const EnhancedDashboardView(),
    );
  }
}

class EnhancedDashboardView extends StatelessWidget {
  const EnhancedDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (KeyEvent event) => _handleKeyEvent(context, event),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: _buildAppBar(context),
          body: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) {
              // Only rebuild when state type changes or data changes
              return previous.runtimeType != current.runtimeType ||
                  (previous is DashboardLoaded &&
                      current is DashboardLoaded &&
                      (previous.balance != current.balance ||
                          previous.recentTransactions != current.recentTransactions)) ||
                  (previous is DashboardRefreshing &&
                      current is DashboardRefreshing &&
                      (previous.balance != current.balance ||
                          previous.recentTransactions != current.recentTransactions));
            },
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DashboardError) {
                // Check if this is an authentication error
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (AuthErrorHandler.isAuthenticationError(state.failure)) {
                    context.read<AuthBloc>().add(AuthTokenExpired());
                  }
                });

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                          child: Text(
                            'Error loading dashboard: ${state.failure.message}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DashboardBloc>().add(DashboardRefreshRequested());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          minWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          children: [
                            // Quick Actions Section
                            Container(
                              width: double.infinity,
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              padding: const EdgeInsets.all(AppSizes.lg),
                              child: _buildQuickActions(context),
                            ),

                            // Main Content
                            Padding(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Financial Overview Section
                                  if (state is DashboardLoaded || state is DashboardRefreshing)
                                    _buildFinancialOverview(
                                      context,
                                      balance: state is DashboardLoaded
                                          ? state.balance
                                          : (state as DashboardRefreshing).balance,
                                      transactions: state is DashboardLoaded
                                          ? state.recentTransactions
                                          : (state as DashboardRefreshing).recentTransactions,
                                    ),
                                  const SizedBox(height: AppSizes.xl),

                                  // Recent Transactions Header
                                  _buildSectionHeader(
                                    context,
                                    title: 'Recent Transactions',
                                    subtitle: 'Your latest financial activity',
                                    onViewAll: () {
                                      _showAllTransactionsDialog(context);
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.lg),

                                  // Removed search and filters - only in transactions screen

                                  // Transactions List
                                  if (state is DashboardLoaded || state is DashboardRefreshing)
                                    _buildTransactionsListSection(
                                      context,
                                      transactions: state is DashboardLoaded
                                          ? state.recentTransactions
                                          : (state as DashboardRefreshing).recentTransactions,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);

      // Handle Ctrl combinations
      if (isCtrlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.slash) {
          _showKeyboardShortcutsDialog(context);
        } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
          context.read<DashboardBloc>().add(DashboardRefreshRequested());
        } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
          FocusScope.of(context).requestFocus(FocusNode());
        } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Subscription feature coming soon!')),
          );
        } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
          _showExportDialog(context);
        } else if (event.logicalKey == LogicalKeyboardKey.keyO) {
          _showTableOptionsDialog(context);
        }
      } else {
        // Handle single key shortcuts with BLoC
        final uiBloc = context.read<DashboardUIBloc>();
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          uiBloc.add(const SearchQueryChanged(''));
        } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
          uiBloc.add(const TimeFilterChanged('Overdue'));
        } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
          uiBloc.add(const TimeFilterChanged('Today'));
        } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
          uiBloc.add(const TimeFilterChanged('Upcoming'));
        } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
          uiBloc.add(const TimeFilterChanged('This Week'));
        } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
          uiBloc.add(const TimeFilterChanged('This Month'));
        } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
          uiBloc.add(const TimeFilterChanged('All'));
        }
      }
    }
  }

  void _showTableOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TableOptionsDialog(),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ExportDialog(),
    );
  }

  void _showKeyboardShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _KeyboardShortcutsDialog(),
    );
  }

  // New UI Builder Methods

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userName = 'User';
          String userEmail = '';

          if (authState is AuthAuthenticated) {
            userName = authState.user.fullName;
            userEmail = authState.user.email;
          }

          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.textSecondary,
                          ),
                    ),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showUserProfileDialog(context);
          },
          icon: Stack(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: Theme.of(context).colorScheme.textPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.add_circle_outline,
            title: 'Add Transaction',
            subtitle: 'Quick entry',
            onTap: () {
              _showAddTransactionDialog(context);
            },
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.analytics_outlined,
            title: 'View Reports',
            subtitle: 'Insights & trends',
            onTap: () {
              _showReportsDialog(context);
            },
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.account_balance_outlined,
            title: 'Budgets',
            subtitle: 'Manage spending',
            onTap: () {
              _showBudgetsDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(
    BuildContext context, {
    required BalanceEntity balance,
    required List<TransactionEntity> transactions,
  }) {
    final income = transactions.where((t) => t.amount > 0).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions.where((t) => t.amount < 0).fold(0.0, (sum, t) => sum + t.amount.abs());

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      CurrencyFormatter.format(balance.totalBalance),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetricCard(
                  context,
                  title: 'Income',
                  value: CurrencyFormatter.format(income),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildMiniMetricCard(
                  context,
                  title: 'Expenses',
                  value: CurrencyFormatter.format(expenses),
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildSimplifiedFilters(BuildContext context) {
    return BlocBuilder<DashboardUIBloc, DashboardUIState>(
      buildWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery || previous.timeFilter != current.timeFilter,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    context.read<DashboardUIBloc>().add(SearchQueryChanged(value));
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              const SizedBox(width: AppSizes.sm),
              PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      state.timeFilter,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                onSelected: (value) {
                  context.read<DashboardUIBloc>().add(TimeFilterChanged(value));
                },
                itemBuilder: (context) => [
                  'All',
                  'This Month',
                  'Last Month',
                  'This Year',
                ]
                    .map((filter) => PopupMenuItem(
                          value: filter,
                          child: Text(filter),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsListSection(
    BuildContext context, {
    required List<TransactionEntity> transactions,
  }) {
    if (transactions.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'No transactions found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Add your first transaction to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Show limited transactions (e.g., first 5) to avoid infinite height
    final displayTransactions = transactions.take(5).toList();

    return Column(
      children: [
        ...displayTransactions
            .asMap()
            .entries
            .expand((entry) => [
                  _buildTransactionCard(context, entry.value),
                  if (entry.key < displayTransactions.length - 1) const SizedBox(height: AppSizes.sm),
                ])
            .toList(),
        if (transactions.length > 5) ...[
          const SizedBox(height: AppSizes.lg),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to full transactions list
              },
              icon: const Icon(Icons.list_alt),
              label: Text('View All ${transactions.length} Transactions'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionsList(
    BuildContext context, {
    required List<TransactionEntity> transactions,
  }) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Add your first transaction to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.textSecondary.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(context, transaction);
      },
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionEntity transaction) {
    final isExpense = transaction.amount < 0;
    final amount = transaction.amount.abs();

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              _getTransactionIcon(transaction.category),
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.textPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                      ),
                      child: Text(
                        transaction.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      _formatTransactionDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}${CurrencyFormatter.format(amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Monthly',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'salary':
        return Icons.work;
      default:
        return Icons.payment;
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
          // Transaction refresh is handled automatically by the BLoC
          // No need for additional refresh here
        },
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.md),
            const Text('Financial Reports'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Spending by Category'),
              subtitle: const Text('View your spending breakdown'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category report coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Monthly Trends'),
              subtitle: const Text('Track income and expenses over time'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trends report coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Financial Summary'),
              subtitle: const Text('Overall financial health overview'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Summary report coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBudgetsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.md),
            const Text('Budget Management'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create Budget'),
              subtitle: const Text('Set spending limits for categories'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create budget coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('View Budgets'),
              subtitle: const Text('See all your active budgets'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View budgets coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_outlined),
              title: const Text('Budget Alerts'),
              subtitle: const Text('Manage spending notifications'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget alerts coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllTransactionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    'All Transactions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Filters
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search transactions...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                        ),
                        onChanged: (value) {
                          // Implement search functionality
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: AppSizes.sm),
                    PopupMenuButton<String>(
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            'All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      onSelected: (value) {
                        // Implement filter functionality
                      },
                      itemBuilder: (context) => [
                        'All',
                        'Income',
                        'Expenses',
                        'This Month',
                        'Last Month',
                        'This Year',
                      ]
                          .map((filter) => PopupMenuItem(
                                value: filter,
                                child: Text(filter),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Transactions List
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoaded) {
                      return _buildFullTransactionsList(context, state.recentTransactions);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullTransactionsList(BuildContext context, List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No transactions found',
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
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(context, transaction);
      },
    );
  }

  void _showUserProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userName = 'User';
          String userEmail = '';

          if (authState is AuthAuthenticated) {
            userName = authState.user.fullName;
            userEmail = authState.user.email;
          }

          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                const Text('User Profile'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Full Name'),
                  subtitle: Text(userName),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(userEmail),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
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
        },
      ),
    );
  }
}

// New BLoC-based sections
class _SearchAndFiltersSection extends StatelessWidget {
  const _SearchAndFiltersSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardUIBloc, DashboardUIState>(
      buildWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery ||
          previous.timeFilter != current.timeFilter ||
          previous.categoryFilter != current.categoryFilter ||
          previous.statusFilter != current.statusFilter ||
          previous.billingFilter != current.billingFilter,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _SearchBarBLoC(searchQuery: state.searchQuery),
            const SizedBox(height: AppSizes.lg),

            // Filter Buttons
            _FilterButtonsBLoC(selectedFilter: state.timeFilter),
            const SizedBox(height: AppSizes.md),

            // Dropdown Filters
            _DropdownFiltersBLoC(
              selectedCategory: state.categoryFilter,
              selectedStatus: state.statusFilter,
              selectedBilling: state.billingFilter,
            ),
          ],
        );
      },
    );
  }
}

class _TableActionsSection extends StatelessWidget {
  const _TableActionsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardUIBloc, DashboardUIState>(
      buildWhen: (previous, current) => previous.tableOptions != current.tableOptions,
      builder: (context, state) {
        return _TableActions();
      },
    );
  }
}

class _TransactionTableSection extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const _TransactionTableSection({
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardUIBloc, DashboardUIState>(
      buildWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery ||
          previous.timeFilter != current.timeFilter ||
          previous.categoryFilter != current.categoryFilter ||
          previous.statusFilter != current.statusFilter ||
          previous.billingFilter != current.billingFilter ||
          previous.tableOptions != current.tableOptions,
      builder: (context, state) {
        return _TransactionTable(
          transactions: transactions,
          searchQuery: state.searchQuery,
          categoryFilter: state.categoryFilter,
          timeFilter: state.timeFilter,
        );
      },
    );
  }
}

class _SearchBarBLoC extends StatefulWidget {
  final String searchQuery;

  const _SearchBarBLoC({required this.searchQuery});

  @override
  State<_SearchBarBLoC> createState() => _SearchBarBLoCState();
}

class _SearchBarBLoCState extends State<_SearchBarBLoC> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(_SearchBarBLoC oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery && _controller.text != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search subscriptions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              context.read<DashboardUIBloc>().add(SearchQueryChanged(value));
            },
          ),
        );
      },
    );
  }
}

class _FilterButtonsBLoC extends StatelessWidget {
  final String selectedFilter;

  const _FilterButtonsBLoC({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final filters = ['Overdue', 'Today', 'Upcoming', 'This Week', 'This Month'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newFilter = selected ? filter : 'All';
                      context.read<DashboardUIBloc>().add(
                            TimeFilterChanged(newFilter),
                          );
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownFiltersBLoC extends StatelessWidget {
  final String selectedCategory;
  final String selectedStatus;
  final String selectedBilling;

  const _DropdownFiltersBLoC({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedBilling,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop: 3 dropdowns in a row
          return Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  context,
                  'All Categories',
                  selectedCategory,
                  ['All Categories', 'Entertainment', 'Utilities', 'Health & Fitness', 'Shopping'],
                  (value) => context.read<DashboardUIBloc>().add(
                        CategoryFilterChanged(value ?? 'All Categories'),
                      ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildDropdown(
                  context,
                  'All Status',
                  selectedStatus,
                  ['All Status', 'Active', 'Paused', 'Cancelled'],
                  (value) => context.read<DashboardUIBloc>().add(
                        StatusFilterChanged(value ?? 'All Status'),
                      ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildDropdown(
                  context,
                  'All Billing',
                  selectedBilling,
                  ['All Billing', 'Monthly', 'Annual', 'Weekly'],
                  (value) => context.read<DashboardUIBloc>().add(
                        BillingFilterChanged(value ?? 'All Billing'),
                      ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: stacked dropdowns
          return Column(
            children: [
              _buildDropdown(
                context,
                'All Categories',
                selectedCategory,
                ['All Categories', 'Entertainment', 'Utilities', 'Health & Fitness', 'Shopping'],
                (value) => context.read<DashboardUIBloc>().add(
                      CategoryFilterChanged(value ?? 'All Categories'),
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      context,
                      'All Status',
                      selectedStatus,
                      ['All Status', 'Active', 'Paused', 'Cancelled'],
                      (value) => context.read<DashboardUIBloc>().add(
                            StatusFilterChanged(value ?? 'All Status'),
                          ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _buildDropdown(
                      context,
                      'All Billing',
                      selectedBilling,
                      ['All Billing', 'Monthly', 'Annual', 'Weekly'],
                      (value) => context.read<DashboardUIBloc>().add(
                            BillingFilterChanged(value ?? 'All Billing'),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String hint,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final dynamic balance;
  final List<TransactionEntity> transactions;

  const _MetricsRow({
    required this.balance,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate metrics
    final monthlySpend =
        transactions.where((t) => t.amount < 0 && _isCurrentMonth(t.date)).fold(0.0, (sum, t) => sum + t.amount.abs());

    final annualProjection = monthlySpend * 12;
    final activeSubscriptions = transactions.length;
    final upcomingRenewals = transactions.where((t) => _isUpcoming(t.date)).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop: 4 cards in a row
          return Row(
            children: [
              Expanded(
                  child: _MetricCard(
                title: 'Monthly Spend',
                value: CurrencyFormatter.format(monthlySpend),
                subtitle: 'No change from last month',
                icon: Icons.attach_money,
              )),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _MetricCard(
                title: 'Annual Projection',
                value: CurrencyFormatter.format(annualProjection),
                subtitle: 'Based on current active subscriptions',
                icon: Icons.calendar_today,
              )),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _MetricCard(
                title: 'Active Subscriptions',
                value: '$activeSubscriptions',
                subtitle: '$activeSubscriptions total',
                icon: Icons.subscriptions,
              )),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _MetricCard(
                title: 'Upcoming Renewals',
                value: '$upcomingRenewals',
                subtitle: 'Due in the next 7 days',
                icon: Icons.schedule,
              )),
            ],
          );
        } else {
          // Mobile: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _MetricCard(
                    title: 'Monthly Spend',
                    value: CurrencyFormatter.format(monthlySpend),
                    subtitle: 'No change from last month',
                    icon: Icons.attach_money,
                  )),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                      child: _MetricCard(
                    title: 'Annual Projection',
                    value: CurrencyFormatter.format(annualProjection),
                    subtitle: 'Based on current active subscriptions',
                    icon: Icons.calendar_today,
                  )),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                      child: _MetricCard(
                    title: 'Active Subscriptions',
                    value: '$activeSubscriptions',
                    subtitle: '$activeSubscriptions total',
                    icon: Icons.subscriptions,
                  )),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                      child: _MetricCard(
                    title: 'Upcoming Renewals',
                    value: '$upcomingRenewals',
                    subtitle: 'Due in the next 7 days',
                    icon: Icons.schedule,
                  )),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  bool _isUpcoming(DateTime date) {
    final now = DateTime.now();
    final future = now.add(const Duration(days: 7));
    return date.isAfter(now) && date.isBefore(future);
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.textPrimary,
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
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search subscriptions...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

class _FilterButtons extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterButtons({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Overdue', 'Today', 'Upcoming', 'This Week', 'This Month'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                onFilterChanged(selected ? filter : 'All');
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DropdownFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedStatus;
  final String selectedBilling;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onBillingChanged;

  const _DropdownFilters({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedBilling,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onBillingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop: 3 dropdowns in a row
          return Row(
            children: [
              Expanded(
                  child: _buildDropdown(
                context,
                'All Categories',
                selectedCategory,
                ['All Categories', 'Entertainment', 'Utilities', 'Health & Fitness', 'Shopping'],
                onCategoryChanged,
              )),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _buildDropdown(
                context,
                'All Status',
                selectedStatus,
                ['All Status', 'Active', 'Paused', 'Cancelled'],
                onStatusChanged,
              )),
              const SizedBox(width: AppSizes.md),
              Expanded(
                  child: _buildDropdown(
                context,
                'All Billing',
                selectedBilling,
                ['All Billing', 'Monthly', 'Annual', 'Weekly'],
                onBillingChanged,
              )),
            ],
          );
        } else {
          // Mobile: stacked dropdowns
          return Column(
            children: [
              _buildDropdown(
                context,
                'All Categories',
                selectedCategory,
                ['All Categories', 'Entertainment', 'Utilities', 'Health & Fitness', 'Shopping'],
                onCategoryChanged,
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown(
                    context,
                    'All Status',
                    selectedStatus,
                    ['All Status', 'Active', 'Paused', 'Cancelled'],
                    onStatusChanged,
                  )),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                      child: _buildDropdown(
                    context,
                    'All Billing',
                    selectedBilling,
                    ['All Billing', 'Monthly', 'Annual', 'Weekly'],
                    onBillingChanged,
                  )),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String hint,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _TableActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _showTableOptionsDialog(context),
            icon: const Icon(Icons.tune),
            label: const Text('Table Options'),
          ),
          const SizedBox(width: AppSizes.md),
          TextButton.icon(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(Icons.file_download),
            label: const Text('Export'),
          ),
          const SizedBox(width: AppSizes.md),
          TextButton.icon(
            onPressed: () => _showKeyboardShortcutsDialog(context),
            icon: const Icon(Icons.keyboard),
            label: const Text('Keyboard Shortcuts'),
          ),
          const SizedBox(width: AppSizes.md),
          FilledButton.icon(
            onPressed: () => _showAddSubscriptionDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New'),
          ),
        ],
      ),
    );
  }

  void _showTableOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TableOptionsDialog(),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ExportDialog(),
    );
  }

  void _showKeyboardShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _KeyboardShortcutsDialog(),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add New Subscription feature coming soon!'),
      ),
    );
  }
}

class _TransactionTable extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final String searchQuery;
  final String categoryFilter;
  final String timeFilter;

  const _TransactionTable({
    required this.transactions,
    required this.searchQuery,
    required this.categoryFilter,
    required this.timeFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filterTransactions();

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(context),
          ...filteredTransactions.map((transaction) => _buildTableRow(context, transaction)),
        ],
      ),
    );
  }

  List<TransactionEntity> _filterTransactions() {
    return transactions.where((transaction) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        if (!transaction.title.toLowerCase().contains(searchLower) &&
            !transaction.category.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Category filter
      if (categoryFilter != 'All Categories' && transaction.category != categoryFilter) {
        return false;
      }

      // Time filter
      if (timeFilter != 'All') {
        final now = DateTime.now();
        switch (timeFilter) {
          case 'Today':
            if (!_isSameDay(transaction.date, now)) return false;
            break;
          case 'This Week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            if (transaction.date.isBefore(startOfWeek)) return false;
            break;
          case 'This Month':
            if (transaction.date.month != now.month || transaction.date.year != now.year) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(width: 40), // Space for expand icon
          Expanded(
            flex: 3,
            child: Text('Service', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text('Next Billing', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 1,
            child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 1,
            child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, TransactionEntity transaction) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_right, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    _getServiceIcon(transaction.category),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Flexible(
                  child: Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category),
                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
              ),
              child: Text(
                transaction.category,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(transaction.amount.abs()),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'in ${_getDaysUntil(transaction.date)} days',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  'Scheduled',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl * 2),
      child: Column(
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No subscriptions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Try adjusting your search or filters to find what you\'re looking for',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.home;
      case 'health & fitness':
        return Icons.fitness_center;
      case 'shopping':
        return Icons.shopping_cart;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Colors.purple;
      case 'utilities':
        return Colors.blue;
      case 'health & fitness':
        return Colors.red;
      case 'shopping':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TableOptionsDialog extends StatefulWidget {
  const _TableOptionsDialog();

  @override
  State<_TableOptionsDialog> createState() => _TableOptionsDialogState();
}

class _TableOptionsDialogState extends State<_TableOptionsDialog> {
  bool _showRowNumbers = true;
  bool _showServiceIcon = true;
  bool _showCategory = true;
  bool _showAmount = true;
  bool _showNextBilling = true;
  bool _showStatus = true;
  bool _showActions = true;
  String _tableSize = 'Medium';
  String _sortBy = 'Service Name';
  String _sortOrder = 'Ascending';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.tune),
          SizedBox(width: AppSizes.sm),
          Text('Table Options'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Column Visibility',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.md),
              CheckboxListTile(
                title: const Text('Row Numbers'),
                value: _showRowNumbers,
                onChanged: (value) => setState(() => _showRowNumbers = value!),
              ),
              CheckboxListTile(
                title: const Text('Service Icon'),
                value: _showServiceIcon,
                onChanged: (value) => setState(() => _showServiceIcon = value!),
              ),
              CheckboxListTile(
                title: const Text('Category'),
                value: _showCategory,
                onChanged: (value) => setState(() => _showCategory = value!),
              ),
              CheckboxListTile(
                title: const Text('Amount'),
                value: _showAmount,
                onChanged: (value) => setState(() => _showAmount = value!),
              ),
              CheckboxListTile(
                title: const Text('Next Billing'),
                value: _showNextBilling,
                onChanged: (value) => setState(() => _showNextBilling = value!),
              ),
              CheckboxListTile(
                title: const Text('Status'),
                value: _showStatus,
                onChanged: (value) => setState(() => _showStatus = value!),
              ),
              CheckboxListTile(
                title: const Text('Actions'),
                value: _showActions,
                onChanged: (value) => setState(() => _showActions = value!),
              ),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Table Size',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: _tableSize,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                ),
                items: ['Compact', 'Medium', 'Large'].map((size) {
                  return DropdownMenuItem<String>(value: size, child: Text(size));
                }).toList(),
                onChanged: (value) => setState(() => _tableSize = value!),
              ),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Sorting',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort by',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                ),
                items: ['Service Name', 'Category', 'Amount', 'Next Billing', 'Status'].map((field) {
                  return DropdownMenuItem(value: field, child: Text(field));
                }).toList(),
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: _sortOrder,
                decoration: const InputDecoration(
                  labelText: 'Order',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                ),
                items: ['Ascending', 'Descending'].map((order) {
                  return DropdownMenuItem(value: order, child: Text(order));
                }).toList(),
                onChanged: (value) => setState(() => _sortOrder = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Apply table options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Table options applied!')),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  String _exportFormat = 'CSV';
  String _dateRange = 'All Time';
  bool _includeHeaders = true;
  bool _includeNotes = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.file_download),
          SizedBox(width: AppSizes.sm),
          Text('Export Data'),
        ],
      ),
      content: SizedBox(
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Format',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<String>(
              value: _exportFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              ),
              items: ['CSV', 'Excel', 'PDF', 'JSON'].map((format) {
                return DropdownMenuItem<String>(value: format, child: Text(format));
              }).toList(),
              onChanged: (value) => setState(() => _exportFormat = value!),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Date Range',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<String>(
              value: _dateRange,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              ),
              items: ['All Time', 'This Month', 'Last 3 Months', 'Last 6 Months', 'This Year', 'Custom Range']
                  .map((range) {
                return DropdownMenuItem<String>(value: range, child: Text(range));
              }).toList(),
              onChanged: (value) => setState(() => _dateRange = value!),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Export Options',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.md),
            CheckboxListTile(
              title: const Text('Include Headers'),
              value: _includeHeaders,
              onChanged: (value) => setState(() => _includeHeaders = value!),
            ),
            CheckboxListTile(
              title: const Text('Include Notes'),
              value: _includeNotes,
              onChanged: (value) => setState(() => _includeNotes = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Perform export
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exporting data as $_exportFormat...')),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}

class _KeyboardShortcutsDialog extends StatelessWidget {
  const _KeyboardShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.keyboard),
          SizedBox(width: AppSizes.sm),
          Text('Keyboard Shortcuts'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'General',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.md),
              _buildShortcutItem('Ctrl + /', 'Show keyboard shortcuts'),
              _buildShortcutItem('Ctrl + R', 'Refresh data'),
              _buildShortcutItem('Ctrl + F', 'Focus search'),
              _buildShortcutItem('Escape', 'Clear search'),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Navigation',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.md),
              _buildShortcutItem('↑ ↓', 'Navigate table rows'),
              _buildShortcutItem('Enter', 'Select/Edit row'),
              _buildShortcutItem('Tab', 'Navigate filters'),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.md),
              _buildShortcutItem('Ctrl + N', 'Add new subscription'),
              _buildShortcutItem('Ctrl + E', 'Export data'),
              _buildShortcutItem('Ctrl + O', 'Table options'),
              _buildShortcutItem('Delete', 'Delete selected row'),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.md),
              _buildShortcutItem('1', 'Show overdue'),
              _buildShortcutItem('2', 'Show today'),
              _buildShortcutItem('3', 'Show upcoming'),
              _buildShortcutItem('4', 'Show this week'),
              _buildShortcutItem('5', 'Show this month'),
              _buildShortcutItem('0', 'Show all'),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXs),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
