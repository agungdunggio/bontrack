import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      // 1. Memicu flow autentikasi Google (Popup pilih akun)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      // 2. Mendapatkan detail otentikasi dari request tersebut
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Membuat kredensial baru untuk Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Masuk ke Firebase dengan kredensial tersebut
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // 5. Mengembalikan objek User
      return userCredential.user;

    } catch (e) {
      debugPrint("Error saat Google Sign-In: $e");
      return null;
    }
  }

  Future<UserModel?> completeUserProfile({
    required String uid,
    required String email,
    required String phoneNumber,
    required String name,
  }) async {
    try {
      // Cek apakah nomor telepon sudah digunakan oleh user lain
      final existingUserWithPhone = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (existingUserWithPhone.docs.isNotEmpty) {
        final existingUid = existingUserWithPhone.docs.first.id;
        // Jika nomor telepon dimiliki user lain (bukan user saat ini)
        if (existingUid != uid) {
          throw 'Nomor telepon sudah digunakan oleh akun lain';
        }
      }

      DocumentSnapshot existingUser = await _firestore.collection('users').doc(uid).get();
      
      if (existingUser.exists) {
        await _firestore.collection('users').doc(uid).update({
          'phoneNumber': phoneNumber,
          'name': name,
        });
        return UserModel.fromMap({
          ...existingUser.data() as Map<String, dynamic>,
          'phoneNumber': phoneNumber,
          'name': name,
        });
      }

      UserModel userModel = UserModel(
        uid: uid,
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      return userModel;
    } catch (e) {
      debugPrint('Error completing user profile: $e');
      rethrow;
    }
  }

  Future<void> updatePhoneNumber({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      // Cek apakah nomor telepon sudah digunakan oleh user lain
      final existingUserWithPhone = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (existingUserWithPhone.docs.isNotEmpty) {
        final existingUid = existingUserWithPhone.docs.first.id;
        // Jika nomor telepon dimiliki user lain (bukan user saat ini)
        if (existingUid != uid) {
          throw 'Nomor telepon sudah digunakan oleh akun lain';
        }
      }

      await _firestore.collection('users').doc(uid).update({
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      debugPrint('Error updating phone number: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by phone: $e');
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<bool> isUserExists(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}

