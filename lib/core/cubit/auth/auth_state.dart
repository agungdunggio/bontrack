import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthEmailVerificationSent extends AuthState {
  final String email;

  const AuthEmailVerificationSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerified extends AuthState {
  final String uid;
  final String email;
  final String? displayName; // Nama dari Google Sign In (opsional)

  const AuthEmailVerified({
    required this.uid,
    required this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [uid, email, displayName];
}

class AuthPhoneAdded extends AuthState {
  final String uid;
  final String email;
  final String phoneNumber;

  const AuthPhoneAdded({
    required this.uid,
    required this.email,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [uid, email, phoneNumber];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

