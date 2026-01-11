import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final user = _authService.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        emit(AuthEmailVerificationSent(user.email ?? ''));
        return;
      }

      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        emit(AuthAuthenticated(userData));
      } else {
        emit(AuthEmailVerified(
          uid: user.uid,
          email: user.email ?? '',
        ));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
      );
      
      emit(AuthEmailVerificationSent(email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        emit(const AuthError('Login gagal'));
        return;
      }

      if (!user.emailVerified) {
        emit(AuthEmailVerificationSent(user.email ?? ''));
        return;
      }

      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        emit(AuthAuthenticated(userData));
      } else {
        emit(AuthEmailVerified(
          uid: user.uid,
          email: user.email ?? '',
        ));
      }
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    emit(AuthLoading());

    try {
      final isVerified = await _authService.isEmailVerified();
      
      if (isVerified) {
        final user = _authService.currentUser;
        if (user != null) {
          
          final userData = await _authService.getUserData(user.uid);
          if (userData != null) {
            emit(AuthAuthenticated(userData));
          } else {
            emit(AuthEmailVerified(
              uid: user.uid,
              email: user.email ?? '',
            ));
          }
        }
      } else {
        final user = _authService.currentUser;
        emit(AuthEmailVerificationSent(user?.email ?? ''));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      emit(AuthError('Gagal mengirim email verifikasi: ${e.toString()}'));
    }
  }

  Future<void> completeUserProfile({
    required String uid,
    required String email,
    required String phoneNumber,
    required String name,
  }) async {
    emit(AuthLoading());

    try {
      final userData = await _authService.completeUserProfile(
        uid: uid,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
      );

      if (userData != null) {
        emit(AuthAuthenticated(userData));
      } else {
        emit(const AuthError('Gagal melengkapi profil'));
      }
    } catch (e) {
      emit(AuthError('Gagal melengkapi profil: ${e.toString()}'));
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Cek apakah user sudah ada di Firestore
      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        emit(AuthAuthenticated(userData));
      } else {
        // User baru via Google, perlu lengkapi profil
        // Ambil displayName dari akun Google untuk auto-fill
        emit(AuthEmailVerified(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        ));
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      emit(AuthError('Gagal masuk dengan Google: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }
}

