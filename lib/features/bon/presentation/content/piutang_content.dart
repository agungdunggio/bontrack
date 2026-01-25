import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/features/bon/widget/piutang_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PiutangContent extends StatefulWidget {
  const PiutangContent({super.key});

  @override
  State<PiutangContent> createState() => _PiutangContentState();
}

class _PiutangContentState extends State<PiutangContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  void _startListening() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<BonCubit>().startListening(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _startListening();
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<BonCubit, BonState>(
          builder: (context, state) {
            if (state is BonLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BonError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _startListening(),
                      child: Text(
                        'Coba Lagi',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is BonLoaded) {
              final piutangList = state.piutangList;

              if (piutangList.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _startListening();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: piutangList.length,
                  itemBuilder: (context, index) {
                    return PiutangCardWidget(bon: piutangList[index]);
                  },
                ),
              );
            }

            return _buildEmptyState();
          },
        );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      top: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Belum ada piutang',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Piutang adalah uang yang dipinjamkan ke orang lain',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

