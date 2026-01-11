import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt_model.dart';

class DebtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new debt
  Future<void> addDebt(DebtModel debt) async {
    try {
      await _firestore.collection('debts').doc(debt.id).set(debt.toMap());
    } catch (e) {
      print('Error adding debt: $e');
      rethrow;
    }
  }

  // Get debts where current user is the creditor (yang ngasih utang)
  Stream<List<DebtModel>> getMyCredits(String userId) {
    return _firestore
        .collection('debts')
        .where('creditorId', isEqualTo: userId)
        // Temporary: orderBy disabled sampai index selesai building
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Firestore error in getMyCredits: $error');
          throw error;
        })
        .map((snapshot) {
          try {
            // Sort di client side
            final debts = snapshot.docs
                .map((doc) => DebtModel.fromMap(doc.data()))
                .toList();
            debts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            print('✅ getMyCredits: Loaded ${debts.length} credits');
            return debts;
          } catch (e) {
            print('❌ Error parsing credits: $e');
            return <DebtModel>[];
          }
        });
  }

  // Get debts where current user is the debtor (yang punya utang)
  Stream<List<DebtModel>> getMyDebts(String userId) {
    return _firestore
        .collection('debts')
        .where('debtorId', isEqualTo: userId)
        // Temporary: orderBy disabled sampai index selesai building
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Firestore error in getMyDebts: $error');
          throw error;
        })
        .map((snapshot) {
          try {
            // Sort di client side
            final debts = snapshot.docs
                .map((doc) => DebtModel.fromMap(doc.data()))
                .toList();
            debts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            print('✅ getMyDebts: Loaded ${debts.length} debts');
            return debts;
          } catch (e) {
            print('❌ Error parsing debts: $e');
            return <DebtModel>[];
          }
        });
  }

  // Get debts by debtor (untuk melihat semua utang seseorang)
  Stream<List<DebtModel>> getDebtsByDebtor(String debtorId) {
    return _firestore
        .collection('debts')
        .where('debtorId', isEqualTo: debtorId)
        // Temporary: orderBy disabled sampai index selesai building
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // Sort di client side
          final debts = snapshot.docs
              .map((doc) => DebtModel.fromMap(doc.data()))
              .toList();
          debts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return debts;
        });
  }

  // Mark debt as paid
  Future<void> markAsPaid(String debtId) async {
    try {
      await _firestore.collection('debts').doc(debtId).update({
        'isPaid': true,
        'paidAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking debt as paid: $e');
      rethrow;
    }
  }

  // Update debt
  Future<void> updateDebt(DebtModel debt) async {
    try {
      await _firestore.collection('debts').doc(debt.id).update(debt.toMap());
    } catch (e) {
      print('Error updating debt: $e');
      rethrow;
    }
  }

  // Delete debt
  Future<void> deleteDebt(String debtId) async {
    try {
      await _firestore.collection('debts').doc(debtId).delete();
    } catch (e) {
      print('Error deleting debt: $e');
      rethrow;
    }
  }

  // Get total debt amount for a debtor from a specific creditor
  Future<double> getTotalDebt(String debtorId, String creditorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('debts')
          .where('debtorId', isEqualTo: debtorId)
          .where('creditorId', isEqualTo: creditorId)
          .where('isPaid', isEqualTo: false)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        DebtModel debt = DebtModel.fromMap(doc.data() as Map<String, dynamic>);
        total += debt.amount;
      }
      return total;
    } catch (e) {
      print('Error getting total debt: $e');
      return 0;
    }
  }
}

