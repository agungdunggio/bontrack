import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/bon_service.dart';
import '../../models/bon_model.dart';
import 'bon_state.dart';

class BonCubit extends Cubit<BonState> {
  final BonService _bonService;
  String? _currentUserId;
  StreamSubscription<List<BonModel>>? _piutangSubscription;
  StreamSubscription<List<BonModel>>? _utangSubscription;
  List<BonModel>? _cachedPiutangList;
  List<BonModel>? _cachedUtangList;

  BonCubit({required BonService bonService})
    : _bonService = bonService,
      super(BonInitial());

  void startListening(String userId) {
    if (_currentUserId == userId && state is BonLoaded) {
      return;
    }

    _piutangSubscription?.cancel();
    _utangSubscription?.cancel();

    _currentUserId = userId;
    _cachedPiutangList = null;
    _cachedUtangList = null;
    emit(BonLoading());

    _piutangSubscription = _bonService
        .streamPiutangList(userId)
        .listen(
          (piutangList) {
            _updateState(piutangList: piutangList);
          },
          onError: (error) {
            debugPrint('Error in piutang stream: $error');
            emit(BonError('Gagal memuat data piutang: ${error.toString()}'));
          },
        );

    _utangSubscription = _bonService
        .streamUtangList(userId)
        .listen(
          (utangList) {
            _updateState(utangList: utangList);
          },
          onError: (error) {
            debugPrint('Error in utang stream: $error');
            emit(BonError('Gagal memuat data utang: ${error.toString()}'));
          },
        );
  }

  void _updateState({List<BonModel>? piutangList, List<BonModel>? utangList}) {
    if (piutangList != null) {
      _cachedPiutangList = piutangList;
    }
    if (utangList != null) {
      _cachedUtangList = utangList;
    }

    if (_cachedPiutangList == null || _cachedUtangList == null) {
      return;
    }

    emit(
      BonLoaded(piutangList: _cachedPiutangList!, utangList: _cachedUtangList!),
    );
  }

  void stopListening() {
    _piutangSubscription?.cancel();
    _utangSubscription?.cancel();
    _piutangSubscription = null;
    _utangSubscription = null;
  }

  Future<void> createBon({
    required String creditorId,
    required String creditorName,
    required String debtorName,
    String? debtorPhoneNumber,
    required int amount,
    required String description,
  }) async {
    try {
      emit(BonLoading());

      await _bonService.createBon(
        creditorId: creditorId,
        creditorName: creditorName,
        debtorName: debtorName,
        debtorPhoneNumber: debtorPhoneNumber,
        amount: amount,
        description: description,
      );

      emit(
        BonLoaded(
          piutangList: _cachedPiutangList ?? [],
          utangList: _cachedUtangList ?? [],
        ),
      );
    } catch (e) {
      debugPrint('Error creating bon: $e');
      emit(BonError('Gagal menambahkan utang/piutang: ${e.toString()}'));
    }
  }

  Future<void> markAsPaid(String bonId) async {
    try {
      await _bonService.markAsPaid(bonId);
    } catch (e) {
      debugPrint('Error marking bon as paid: $e');
      emit(BonError('Gagal memperbarui status: ${e.toString()}'));
      if (_cachedPiutangList != null && _cachedUtangList != null) {
        emit(
          BonLoaded(
            piutangList: _cachedPiutangList!,
            utangList: _cachedUtangList!,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    stopListening();
    return super.close();
  }
}
