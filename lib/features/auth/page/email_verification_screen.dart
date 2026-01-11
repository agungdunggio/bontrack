import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cubit/auth/auth_cubit.dart';
import '../../../core/cubit/auth/auth_state.dart';
import '../../../app/widget/bottom_toast.dart';
import 'complete_profile_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isNavigating = false;
  bool _canResend = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Auto check verification every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        context.read<AuthCubit>().checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resendVerificationEmail() {
    if (!_canResend) return;

    context.read<AuthCubit>().resendEmailVerification();
    
    // Start countdown
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });

    BottomToast.show(
      context,
      message: 'Email verifikasi telah dikirim ulang',
      type: BottomToastType.success,
      duration: const Duration(milliseconds: 2400),
    );
  }

  void _checkNow() {
    context.read<AuthCubit>().checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifikasi Email',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            if (previous.runtimeType == current.runtimeType) {
              return false;
            }
            return current is AuthEmailVerified || current is AuthError;
          },
          listener: (context, state) {
            print('🔔 Verification Screen - State: ${state.runtimeType}');
            
            if (!mounted) return;

            if (state is AuthEmailVerified) {
              if (_isNavigating) return;
              _isNavigating = true;

              _timer?.cancel();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompleteProfileScreen(
                      uid: state.uid,
                      email: state.email,
                    ),
                  ),
                );
              });
            } else if (state is AuthError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                
                BottomToast.show(
                  context,
                  message: state.message,
                  type: BottomToastType.error,
                  duration: const Duration(milliseconds: 2400),
                );
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Cek Email Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kami telah mengirim link verifikasi ke:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Langkah-langkah:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStep('1', 'Buka email Anda'),
                      const SizedBox(height: 8),
                      _buildStep('2', 'Klik link verifikasi'),
                      const SizedBox(height: 8),
                      _buildStep('3', 'Kembali ke aplikasi'),
                      const SizedBox(height: 8),
                      _buildStep('4', 'Halaman akan otomatis lanjut'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _checkNow,
                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        isLoading ? 'Mengecek...' : 'Sudah Verifikasi? Cek Sekarang',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tidak menerima email? ',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _canResend ? _resendVerificationEmail : null,
                      child: Text(
                        _canResend
                            ? 'Kirim Ulang'
                            : 'Kirim Ulang ($_resendCountdown)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.autorenew,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mengecek verifikasi otomatis setiap 3 detik...',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.orange[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

