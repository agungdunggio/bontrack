import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/core/utils/currency_formatter.dart';
import 'package:bontrack/core/utils/date_formatter.dart';
import 'package:bontrack/features/bon/widget/finance_summary_card_widget.dart';
import 'package:bontrack/features/bon/widget/row_bon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PiutangContent extends StatefulWidget {
  final double paddingTop;
  final bool isHistory;

  const PiutangContent({
    super.key,
    this.paddingTop = 0,
    required this.isHistory,
  });

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
                        child: Text('Coba Lagi', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                );
              }

              if (state is BonLoaded) {
                final piutangList = state.piutangList.where((bon) {
                  return widget.isHistory ? bon.isPaid : !bon.isPaid;
                }).toList();

                final totalAmount = piutangList.fold<int>(
                  0,
                  (sum, item) => sum + item.amount,
                );

                Map<String, List<dynamic>> groupedBon = {};
                for (var bon in piutangList) {
                  final key = DateFormatter.formatMonthYear(bon.createdAt);
                  if (!groupedBon.containsKey(key)) {
                    groupedBon[key] = [];
                  }
                  groupedBon[key]!.add(bon);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _startListening();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.only(top: widget.paddingTop),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: FinanceSummaryCardWidget(
                                title: !widget.isHistory
                                    ? 'Total Piutang'
                                    : 'Piutang Lunas',
                                amount: CurrencyFormatter.format(totalAmount),
                                subtitle: !widget.isHistory
                                    ? 'Uang Anda di orang lain'
                                    : 'Sudah dibayar',
                                icon: Icons.trending_up_rounded,
                                gradientColors: const [
                                  Color(0xFF11998E),
                                  Color(0xFF38EF7D),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (piutangList.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      else
                        for (var entry in groupedBon.entries) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                24.h,
                                20.w,
                                8.h,
                              ),
                              child: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 0.w),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final bon = entry.value[index];
                                return RowBonWidget(
                                  bon: bon,
                                  index: index,
                                  isPiutang: true,
                                );
                              }, childCount: entry.value.length),
                            ),
                          ),
                        ],
                      SliverPadding(padding: EdgeInsets.only(bottom: 20.h)),
                    ],
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
    final message = widget.isHistory
        ? 'Belum ada riwayat pelunasan'
        : 'Belum ada piutang aktif';
    final subMessage = widget.isHistory
        ? 'Transaksi yang sudah lunas akan muncul di sini'
        : 'Piutang adalah uang yang dipinjamkan ke orang lain';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isHistory
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
    );
  }
}
