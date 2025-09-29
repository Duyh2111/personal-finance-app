import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/errors/failures.dart';

class ErrorStateWidget extends StatelessWidget {
  final Failure failure;
  final String title;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    required this.failure,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Text(
                failure.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}