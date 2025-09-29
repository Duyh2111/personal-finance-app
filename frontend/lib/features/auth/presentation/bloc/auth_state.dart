import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final Failure failure;

  AuthError(this.failure);

  @override
  List<Object> get props => [failure];
}