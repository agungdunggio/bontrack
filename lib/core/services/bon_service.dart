import 'package:bontrack/core/constants/app_config.dart';
import 'package:bontrack/core/utils/phone_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/bon_model.dart';
import '../models/user_model.dart';

class BonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BonModel>> getPiutangList(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bons')
          .where('creditorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => BonModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting piutang list: $e');
      return [];
    }
  }

  Future<List<BonModel>> getUtangList(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bons')
          .where('debtorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => BonModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting utang list: $e');
      return [];
    }
  }

  Stream<List<BonModel>> streamPiutangList(String userId) {
    return _firestore
        .collection('bons')
        .where('creditorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BonModel.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<BonModel>> streamUtangList(String userId) {
    return _firestore
        .collection('bons')
        .where('debtorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BonModel.fromMap(doc.data())).toList(),
        );
  }

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      final phoneHash = phoneNumber.toPhoneHashWithSalt(
        AppConfig.getPhoneHashSalt(),
      );
      final snapshot = await _firestore
          .collection('users')
          .where('phoneHash', isEqualTo: phoneHash)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by phone: $e');
      return null;
    }
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
      final now = DateTime.now();
      final bonId = now.millisecondsSinceEpoch.toString();

      String debtorId;
      String finalDebtorName = debtorName;

      UserModel? registeredUser;

      if (debtorPhoneNumber != null && debtorPhoneNumber.isNotEmpty) {
        registeredUser = await getUserByPhone(debtorPhoneNumber);
      }

      if (registeredUser != null) {
        debtorId = registeredUser.uid;
        finalDebtorName = registeredUser.name;
      } else {
        final phoneHash = debtorPhoneNumber != null
            ? debtorPhoneNumber.toPhoneHashWithSalt(
                AppConfig.getPhoneHashSalt(),
              )
            : 'no_phone';
        debtorId =
            'temp_${debtorName.toLowerCase().replaceAll(' ', '_')}_$phoneHash';
      }

      final bon = BonModel(
        id: bonId,
        amount: amount,
        createdAt: now,
        creditorId: creditorId,
        creditorName: creditorName,
        debtorId: debtorId,
        debtorName: finalDebtorName,
        description: description,
        isPaid: false,
        paidAt: null,
      );

      await _firestore.collection('bons').doc(bonId).set(bon.toMap());
    } catch (e) {
      debugPrint('Error creating bon: $e');
      rethrow;
    }
  }

  Future<void> markAsPaid(String bonId) async {
    try {
      await _firestore.collection('bons').doc(bonId).update({
        'isPaid': true,
        'paidAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error marking bon as paid: $e');
      rethrow;
    }
  }
}
