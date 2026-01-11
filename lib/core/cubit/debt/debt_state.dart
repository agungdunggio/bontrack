import 'package:equatable/equatable.dart';
import '../../models/debt_model.dart';

abstract class DebtState extends Equatable {
  const DebtState();

  @override
  List<Object?> get props => [];
}

// Initial state
class DebtInitial extends DebtState {}

// Loading state
class DebtLoading extends DebtState {}

// Loaded state
class DebtLoaded extends DebtState {
  final List<DebtModel> debts;

  const DebtLoaded(this.debts);

  @override
  List<Object?> get props => [debts];
}

// Operation success (add, update, delete, mark as paid)
class DebtOperationSuccess extends DebtState {
  final String message;

  const DebtOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Error state
class DebtError extends DebtState {
  final String message;

  const DebtError(this.message);

  @override
  List<Object?> get props => [message];
}

