import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureStorage _secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required SecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested, transformer: droppable());
    on<AuthRegisterRequested>(_onRegisterRequested, transformer: droppable());
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthErrorCleared>(_onErrorCleared);
    on<AuthAutoLoginRequested>(_onAutoLoginRequested);
    on<AuthTokenExpired>(_onTokenExpired);

    // Check authentication status on startup
    add(AuthCheckStatusRequested());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async => emit(AuthError(failure)),
      (token) async {
        // Save token to secure storage
        await _secureStorage.saveAccessToken(token);

        // Create user entity (in a real app, you'd fetch user details from API)
        final user = UserEntity(
          id: 1,
          email: event.email,
          fullName: 'User Name',
          isActive: true,
        );

        // Save user data to secure storage
        await _secureStorage.saveUserData(jsonEncode(user.toJson()));

        // Save login credentials for auto-login (optional - based on user preference)
        if (event.rememberMe == true) {
          await _secureStorage.saveLoginCredentials(event.email, event.password);
        }

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );

    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    await result.fold(
      (failure) async => emit(AuthError(failure)),
      (_) async {
        // Clear all stored authentication data
        await _secureStorage.clearAll();
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Try to restore user data from storage
        final userDataJson = await _secureStorage.getUserData();
        if (userDataJson != null) {
          final userData = jsonDecode(userDataJson);
          final user = UserEntity.fromJson(userData);
          emit(AuthAuthenticated(user));
          return;
        }
      }

      // No valid session found, check for saved credentials for auto-login
      final credentials = await _secureStorage.getLoginCredentials();
      if (credentials != null) {
        add(AuthAutoLoginRequested());
        return;
      }

      emit(AuthUnauthenticated());
    } catch (e) {
      // Clear any corrupted data
      await _secureStorage.clearAuthData();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAutoLoginRequested(
    AuthAutoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final credentials = await _secureStorage.getLoginCredentials();
      if (credentials != null) {
        add(AuthLoginRequested(
          email: credentials['email']!,
          password: credentials['password']!,
          rememberMe: true,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await _secureStorage.clearLoginCredentials();
      emit(AuthUnauthenticated());
    }
  }

  void _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthUnauthenticated());
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Clear all stored authentication data
    await _secureStorage.clearAll();
    emit(AuthUnauthenticated());
  }
}
