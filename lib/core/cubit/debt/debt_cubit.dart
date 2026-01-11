import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/debt_service.dart';
import '../../models/debt_model.dart';
import 'debt_state.dart';

class DebtCubit extends Cubit<DebtState> {
  final DebtService _debtService;
  StreamSubscription<List<DebtModel>>? _debtsSubscription;

  DebtCubit({required DebtService debtService})
      : _debtService = debtService,
        super(DebtInitial());

  // Load debts for user
  void loadDebts(String userId) {
    _debtsSubscription?.cancel();
    
    emit(DebtLoading());
    
    _debtsSubscription = _debtService
        .getMyDebts(userId)
        .listen(
      (debts) {
        if (!isClosed) {
          emit(DebtLoaded(debts));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(DebtError('Gagal memuat data: ${error.toString()}'));
        }
      },
    );
  }

  // Add new debt
  Future<void> addDebt(DebtModel debt) async {
    try {
      await _debtService.addDebt(debt);
      if (!isClosed) {
        emit(const DebtOperationSuccess('Catatan berhasil ditambahkan'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DebtError('Gagal menambahkan: ${e.toString()}'));
      }
    }
  }

  // Mark debt as paid
  Future<void> markAsPaid(String debtId) async {
    try {
      await _debtService.markAsPaid(debtId);
      if (!isClosed) {
        emit(const DebtOperationSuccess('Ditandai sebagai lunas'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DebtError('Gagal menandai sebagai lunas: ${e.toString()}'));
      }
    }
  }

  // Update debt
  Future<void> updateDebt(DebtModel debt) async {
    try {
      await _debtService.updateDebt(debt);
      if (!isClosed) {
        emit(const DebtOperationSuccess('Catatan berhasil diperbarui'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DebtError('Gagal memperbarui: ${e.toString()}'));
      }
    }
  }

  // Delete debt
  Future<void> deleteDebt(String debtId) async {
    try {
      await _debtService.deleteDebt(debtId);
      if (!isClosed) {
        emit(const DebtOperationSuccess('Catatan berhasil dihapus'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DebtError('Gagal menghapus: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _debtsSubscription?.cancel();
    return super.close();
  }
}

