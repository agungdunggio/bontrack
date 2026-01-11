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

class AuthNeedsProfile extends AuthState {
  final String uid;
  final String email;
  final String? displayName; // Nama dari Google Sign In (opsional)

  const AuthNeedsProfile({
    required this.uid,
    required this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [uid, email, displayName];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

