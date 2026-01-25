import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/bon_model.dart';

class BonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BonModel>> getPiutangList(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bons')
          .where('creditorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BonModel.fromMap(doc.data()))
          .toList();
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

      return snapshot.docs
          .map((doc) => BonModel.fromMap(doc.data()))
          .toList();
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
        .map((snapshot) => snapshot.docs
            .map((doc) => BonModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<BonModel>> streamUtangList(String userId) {
    return _firestore
        .collection('bons')
        .where('debtorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BonModel.fromMap(doc.data()))
            .toList());
  }
}
