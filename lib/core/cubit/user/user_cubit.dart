import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final AuthService _authService;

  UserCubit({required AuthService authService})
      : _authService = authService,
        super(UserInitial());

  // Load all users
  Future<void> loadAllUsers() async {
    emit(UserLoading());

    try {
      final users = await _authService.getAllUsers();
      if (!isClosed) {
        emit(UserAllLoaded(users));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UserError('Gagal memuat daftar pengguna: ${e.toString()}'));
      }
    }
  }

  // Load specific user
  Future<void> loadUser(String uid) async {
    emit(UserLoading());

    try {
      final user = await _authService.getUserData(uid);
      if (!isClosed) {
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(const UserError('Pengguna tidak ditemukan'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(UserError('Gagal memuat data pengguna: ${e.toString()}'));
      }
    }
  }

  // Search users by name or phone
  Future<void> searchUsers(String query) async {
    emit(UserLoading());

    try {
      final users = await _authService.getAllUsers();
      final filteredUsers = users.where((user) {
        final searchQuery = query.toLowerCase();
        return user.name.toLowerCase().contains(searchQuery) ||
            user.phoneNumber.toLowerCase().contains(searchQuery);
      }).toList();

      if (!isClosed) {
        emit(UserAllLoaded(filteredUsers));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UserError('Gagal mencari pengguna: ${e.toString()}'));
      }
    }
  }
}

