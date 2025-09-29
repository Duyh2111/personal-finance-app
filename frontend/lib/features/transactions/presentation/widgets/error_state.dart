import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/auth_error_handler.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';

class ErrorState extends StatelessWidget {
  final Failure? failure;

  const ErrorState({super.key, this.failure});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Check if this is an authentication error
    if (failure != null && AuthErrorHandler.isAuthenticationError(failure!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(AuthTokenExpired());
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            l10n.errorLoadingTransactions,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            failure?.message ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
