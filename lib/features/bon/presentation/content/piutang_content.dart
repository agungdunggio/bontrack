import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/features/bon/widget/piutang_card_widget.dart';
import 'package:bontrack/features/bon/widget/status_filter_widget.dart';
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
  int _selectedFilterIndex = 0;

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

          return Column(
            children: [
              StatusFilterWidget(
                selectedIndex: _selectedFilterIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                },
              ),
              Expanded(
                child: BlocBuilder<BonCubit, BonState>(
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
                      final piutangList = state.piutangList.where((bon) {
                        final isPaid = bon.isPaid;
                        return _selectedFilterIndex == 0 ? !isPaid : isPaid;
                      }).toList();

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
                            final bon = piutangList[index];
                            return PiutangCardWidget(bon: bon);
                          },
                        ),
                      );
                    }

                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isHistory = _selectedFilterIndex == 1;
    final message = isHistory
        ? 'Belum ada riwayat pelunasan'
        : 'Belum ada piutang aktif';
    final subMessage = isHistory
        ? 'Transaksi yang sudah lunas akan muncul di sini'
        : 'Piutang adalah uang yang dipinjamkan ke orang lain';

    return SafeArea(
      top: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory
                  ? Icons.history_edu_rounded
                  : Icons.account_balance_wallet_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              message,
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
                subMessage,
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
