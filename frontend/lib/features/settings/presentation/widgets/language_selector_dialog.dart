import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final Locale currentLocale;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLocale,
  });

  static Future<Locale?> show(
    BuildContext context,
    Locale currentLocale,
  ) async {
    return showDialog<Locale>(
      context: context,
      builder: (context) => LanguageSelectorDialog(
        currentLocale: currentLocale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final languages = [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    ];

    return AlertDialog(
      title: Text(l10n.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: languages.map((language) {
          final locale = Locale(language['code']!, '');

          return RadioListTile<Locale>(
            title: Text(language['nativeName']!),
            subtitle: Text(language['name']!),
            value: locale,
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              if (value != null) {
                Navigator.of(context).pop(value);
              }
            },
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            activeColor: Theme.of(context).colorScheme.primary,
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}