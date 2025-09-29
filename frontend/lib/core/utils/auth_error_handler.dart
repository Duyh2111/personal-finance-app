import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../errors/failures.dart';

class AuthErrorHandler {
  static bool isAuthenticationError(Failure failure) {
    // Check if the failure message indicates authentication issues
    final message = failure.message.toLowerCase();
    return message.contains('not authenticated') ||
        message.contains('unauthorized') ||
        message.contains('token expired') ||
        message.contains('invalid token') ||
        message.contains('authentication failed') ||
        message.contains('401') ||
        (failure is AuthFailure);
  }

  static void handleAuthenticationError(
    BuildContext context,
    Failure failure,
  ) {
    if (isAuthenticationError(failure)) {
      // Trigger logout in AuthBloc
      context.read<AuthBloc>().add(AuthTokenExpired());
    }
  }
}
