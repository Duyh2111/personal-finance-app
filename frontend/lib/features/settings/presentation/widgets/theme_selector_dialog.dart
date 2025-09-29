import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/theme/theme_extensions.dart';

class ThemeSelectorDialog extends StatefulWidget {
  final ThemeMode currentTheme;

  const ThemeSelectorDialog({
    super.key,
    required this.currentTheme,
  });

  @override
  State<ThemeSelectorDialog> createState() => _ThemeSelectorDialogState();

  static Future<ThemeMode?> show(BuildContext context, ThemeMode currentTheme) {
    return showDialog<ThemeMode>(
      context: context,
      builder: (context) => ThemeSelectorDialog(currentTheme: currentTheme),
    );
  }
}

class _ThemeSelectorDialogState extends State<ThemeSelectorDialog> {
  late ThemeMode selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        l10n.theme,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            title: l10n.systemDefault,
            subtitle: 'Follow system setting',
            icon: Icons.phone_android,
            value: ThemeMode.system,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value),
          ),
          const SizedBox(height: AppSizes.sm),
          _ThemeOption(
            title: 'Light',
            subtitle: 'Light theme',
            icon: Icons.light_mode,
            value: ThemeMode.light,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value),
          ),
          const SizedBox(height: AppSizes.sm),
          _ThemeOption(
            title: 'Dark',
            subtitle: 'Dark theme',
            icon: Icons.dark_mode,
            value: ThemeMode.dark,
            groupValue: selectedTheme,
            onChanged: (value) => setState(() => selectedTheme = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedTheme),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: AppSizes.iconSm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
