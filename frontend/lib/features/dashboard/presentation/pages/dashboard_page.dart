import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../shared/theme/theme_extensions.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../../../../shared/widgets/connectivity_wrapper.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(DashboardInitialLoadRequested()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DashboardError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final exception = ServerException(
                state.failure.message,
                code: 'DASHBOARD_ERROR',
              );
              ErrorDialog.show(
                context,
                exception: exception,
                title: 'Dashboard Error',
                onRetry: () {
                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                },
              );
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    state.failure.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(DashboardRefreshRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded || state is DashboardRefreshing) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(DashboardRefreshRequested());
                // Wait for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    const _GreetingSection(),
                    const SizedBox(height: AppSizes.lg),

                    // Balance Card
                    if (state is DashboardLoaded)
                      BalanceCard(balance: state.balance)
                    else if (state is DashboardRefreshing)
                      BalanceCard(balance: state.balance)
                    else
                      const _LoadingBalanceCard(),
                    const SizedBox(height: AppSizes.lg),

                    // Quick Actions
                    const QuickActions(),
                    const SizedBox(height: AppSizes.lg),

                    // Recent Transactions
                    if (state is DashboardLoaded)
                      RecentTransactions(transactions: state.recentTransactions)
                    else if (state is DashboardRefreshing)
                      RecentTransactions(transactions: state.recentTransactions)
                    else
                      const _LoadingTransactions(),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = AppLocalizations.of(context).goodMorning;
      icon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = AppLocalizations.of(context).goodAfternoon;
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = AppLocalizations.of(context).goodEvening;
      icon = Icons.nights_stay_outlined;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconMd,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.textSecondary,
                  ),
            ),
            Text(
              AppLocalizations.of(context).welcomeBack,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.textPrimary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingBalanceCard extends StatelessWidget {
  const _LoadingBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: Theme.of(context).colorScheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _LoadingTransactions extends StatelessWidget {
  const _LoadingTransactions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).recentTransactions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.textPrimary,
              ),
        ),
        const SizedBox(height: AppSizes.md),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
