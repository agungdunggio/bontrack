import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Initial state
class UserInitial extends UserState {}

// Loading state
class UserLoading extends UserState {}

// All users loaded
class UserAllLoaded extends UserState {
  final List<UserModel> users;

  const UserAllLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

// Single user loaded
class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

// Error state
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

