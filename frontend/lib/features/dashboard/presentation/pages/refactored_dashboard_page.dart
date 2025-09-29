import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/auth_error_handler.dart';
import '../../../../shared/widgets/connectivity_wrapper.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/financial_overview_section.dart';
import '../widgets/transactions_list_section.dart';

class RefactoredDashboardPage extends StatelessWidget {
  const RefactoredDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (context) => getIt<DashboardBloc>()..add(DashboardInitialLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (KeyEvent event) => _handleKeyEvent(context, event),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: const DashboardAppBar(),
          body: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) => _shouldRebuild(previous, current),
            builder: (context, state) {
              return _buildBody(context, state);
            },
          ),
        ),
      ),
    );
  }

  bool _shouldRebuild(DashboardState previous, DashboardState current) {
    return previous.runtimeType != current.runtimeType ||
        (previous is DashboardLoaded &&
            current is DashboardLoaded &&
            (previous.balance != current.balance ||
                previous.recentTransactions != current.recentTransactions)) ||
        (previous is DashboardRefreshing &&
            current is DashboardRefreshing &&
            (previous.balance != current.balance ||
                previous.recentTransactions != current.recentTransactions));
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return const LoadingStateWidget(
        message: 'Loading dashboard...',
        showMessage: true,
      );
    }

    if (state is DashboardError) {
      _handleAuthError(context, state);
      return ErrorStateWidget(
        failure: state.failure,
        title: 'Error loading dashboard',
        onRetry: () => context.read<DashboardBloc>().add(DashboardRefreshRequested()),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildQuickActionsSection(context),
            _buildMainContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      padding: const EdgeInsets.all(16),
      child: const DashboardQuickActions(),
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState state) {
    if (state is! DashboardLoaded && state is! DashboardRefreshing) {
      return const SizedBox.shrink();
    }

    final balance = state is DashboardLoaded ? state.balance : (state as DashboardRefreshing).balance;
    final transactions = state is DashboardLoaded ? state.recentTransactions : (state as DashboardRefreshing).recentTransactions;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Overview
          FinancialOverviewSection(
            balance: balance,
            transactions: transactions,
          ),
          const SizedBox(height: 32),

          // Recent Transactions Header
          SectionHeader(
            title: 'Recent Transactions',
            subtitle: 'Your latest financial activity',
            onViewAll: () => _navigateToTransactions(context),
          ),
          const SizedBox(height: 16),

          // Transactions List
          TransactionsListSection(
            transactions: transactions,
            onViewAll: () => _navigateToTransactions(context),
          ),
        ],
      ),
    );
  }

  void _handleAuthError(BuildContext context, DashboardError state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthErrorHandler.isAuthenticationError(state.failure)) {
        context.read<AuthBloc>().add(AuthTokenExpired());
      }
    });
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<DashboardBloc>().add(DashboardRefreshRequested());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToTransactions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransactionsPage(),
      ),
    );
  }

  void _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyR) {
        context.read<DashboardBloc>().add(DashboardRefreshRequested());
      }
    }
  }
}