import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/theme_extensions.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('login'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.goNamed('dashboard');
          } else if (state is AuthError) {
            final exception = AuthException(
              state.failure.message,
              code: 'AUTH_ERROR',
            );
            ErrorDialog.show(
              context,
              exception: exception,
              onRetry: () => _onRegisterPressed(),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        Icon(
                          Icons.person_add,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          AppLocalizations.of(context).registerSubtitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.xl),

                        // Form Fields
                        AppTextField(
                          label: AppLocalizations.of(context).fullName,
                          hint: AppLocalizations.of(context).fullName,
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .errorFullNameRequired;
                            }
                            if (value.length < 2) {
                              return AppLocalizations.of(context)
                                  .errorFullNameTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField.email(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .errorEmailRequired;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return AppLocalizations.of(context)
                                  .errorInvalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField.password(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .errorPasswordRequired;
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)
                                  .errorPasswordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: AppLocalizations.of(context).confirmPassword,
                          hint: AppLocalizations.of(context).confirmPassword,
                          controller: _confirmPasswordController,
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .confirmPassword;
                            }
                            if (value != _passwordController.text) {
                              return AppLocalizations.of(context)
                                  .errorPasswordsNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.xl),

                        // Register Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton.primary(
                              text: AppLocalizations.of(context).createAccount,
                              isLoading: state is AuthLoading,
                              onPressed: state is AuthLoading
                                  ? null
                                  : _onRegisterPressed,
                            );
                          },
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // Login Link
                        AppButton.text(
                          text: AppLocalizations.of(context).haveAccountSignIn,
                          onPressed: () => context.goNamed('login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _nameController.text.trim(),
            ),
          );
    }
  }
}
