import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cubit/auth/auth_cubit.dart';
import '../../../core/cubit/auth/auth_state.dart';
import '../../../app/widget/bottom_toast.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            return current is AuthError;
          },
          listener: (context, state) {
            if (state is AuthError) {
              BottomToast.show(
                context,
                message: state.message,
                type: BottomToastType.error,
                duration: const Duration(milliseconds: 3000),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 100.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'BonTrack',
                    style: GoogleFonts.poppins(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Kelola catatan utang dengan mudah',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context.read<AuthCubit>().signInWithGoogle(),
                          icon: isLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  Icons.g_mobiledata,
                                  size: 28.sp,
                                  color: Colors.white,
                                ),
                          label: Text(
                            isLoading ? 'Memproses...' : 'Masuk dengan Google',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'Dengan masuk, Anda menyetujui\nSyarat & Ketentuan kami',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
