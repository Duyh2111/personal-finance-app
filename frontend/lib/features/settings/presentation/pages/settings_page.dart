import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:personal_finance_app/features/settings/presentation/widgets/theme_selector_dialog.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/language_selector_dialog.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../shared/theme/theme_extensions.dart';
import '../widgets/about_dialog.dart';
import 'notification_settings_page.dart';
import 'profile_page.dart';
import 'security_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings),
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Profile Section
              const _ProfileSection(),
              const SizedBox(height: AppSizes.lg),

              // Settings Sections
              _SettingsSection(
                title: l10n.account,
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: l10n.profileInformation,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    title: l10n.securityPrivacy,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SecurityPage()),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const NotificationSettingsPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              _SettingsSection(
                title: l10n.preferences,
                items: [
                  _SettingsItem(
                    icon: Icons.palette_outlined,
                    title: l10n.theme,
                    subtitle: settingsState.themeName,
                    onTap: () async {
                      final result = await ThemeSelectorDialog.show(
                        context,
                        settingsState.themeMode,
                      );
                      if (result != null && context.mounted) {
                        context.read<SettingsBloc>().add(ThemeChanged(result));
                      }
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.language,
                    title: l10n.language,
                    subtitle: settingsState.languageName,
                    onTap: () async {
                      final result = await LanguageSelectorDialog.show(
                        context,
                        settingsState.locale,
                      );
                      if (result != null && context.mounted) {
                        context.read<SettingsBloc>().add(LocaleChanged(result));
                      }
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.currency_exchange,
                    title: l10n.currency,
                    subtitle: l10n.usdCurrency,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Currency selection coming soon!')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              _SettingsSection(
                title: l10n.support,
                items: [
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: l10n.helpFaq,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & FAQ coming soon!')),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.feedback_outlined,
                    title: l10n.sendFeedback,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback form coming soon!')),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.info_outline,
                    title: l10n.about,
                    onTap: () => AppAboutDialog.show(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Logout Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'john.doe@example.com',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.textPrimary,
                ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outline,
                      indent: AppSizes.xl,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.textPrimary,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
