import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/theme_extensions.dart';
import '../../core/constants/app_sizes.dart';

class NoInternetBanner extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const NoInternetBanner({
    super.key,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.warning.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).colorScheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Theme.of(context).colorScheme.warning,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              AppLocalizations.of(context).noInternetConnection,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.warning,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(width: AppSizes.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context).retry,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}