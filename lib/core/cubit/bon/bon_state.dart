import 'package:equatable/equatable.dart';
import '../../models/bon_model.dart';

abstract class BonState extends Equatable {
  const BonState();

  @override
  List<Object?> get props => [];
}

class BonInitial extends BonState {}

class BonLoading extends BonState {}

class BonLoaded extends BonState {
  final List<BonModel> piutangList;
  final List<BonModel> utangList;

  const BonLoaded({
    required this.piutangList,
    required this.utangList,
  });

  @override
  List<Object?> get props => [piutangList, utangList];
}

class BonError extends BonState {
  final String message;

  const BonError(this.message);

  @override
  List<Object?> get props => [message];
}
