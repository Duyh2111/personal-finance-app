import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}