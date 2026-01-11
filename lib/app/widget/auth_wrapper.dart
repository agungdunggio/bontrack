import 'dart:io';
import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/features/auth/page/complete_profile_screen.dart';
import 'package:bontrack/features/auth/page/login_screen.dart';
import 'package:bontrack/features/home/page/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingConnection = true;
  bool _hasConnection = false;
  String _connectionError = '';

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw SocketException('Connection timeout');
        },
      );
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          setState(() {
            _hasConnection = true;
            _isCheckingConnection = false;
            _connectionError = '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasConnection = false;
            _isCheckingConnection = false;
            _connectionError = 'Tidak dapat terhubung ke internet';
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _isCheckingConnection = false;
          _connectionError = 'Tidak ada koneksi internet, silahkan check kembali koneksi internet anda';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _isCheckingConnection = false;
          _connectionError = 'Gagal memeriksa koneksi.\nSilakan coba lagi';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isCheckingConnection) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memeriksa koneksi...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasConnection) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Tidak Ada Koneksi',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _connectionError,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCheckingConnection = true;
                      _connectionError = '';
                    });
                    _checkInternetConnection();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Coba Lagi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        
        if (state is AuthInitial) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        
        if (state is AuthNeedsProfile) {
          return CompleteProfileScreen(
            uid: state.uid,
            email: state.email,
            displayName: state.displayName,
          );
        }
        
        return const LoginScreen();
      },
    );
  }
}