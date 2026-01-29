import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/core/utils/currency_formatter.dart';
import 'package:bontrack/features/bon/widget/finance_summary_card_widget.dart';
import 'package:bontrack/features/bon/widget/utang_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UtangContent extends StatefulWidget {
  final double paddingTop;
  final bool isHistory;

  const UtangContent({super.key, this.paddingTop = 0, required this.isHistory});

  @override
  State<UtangContent> createState() => _UtangContentState();
}

class _UtangContentState extends State<UtangContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BonCubit, BonState>(
      builder: (context, state) {
        if (state is BonLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BonLoaded) {
          final utangList = state.utangList.where((bon) {
            return widget.isHistory ? bon.isPaid : !bon.isPaid;
          }).toList();

          final totalAmount = utangList.fold<int>(
            0,
            (sum, item) => sum + item.amount,
          );

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(padding: EdgeInsets.only(top: widget.paddingTop)),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                      child: FinanceSummaryCardWidget(
                        title: !widget.isHistory
                            ? 'Total Utang'
                            : 'Utang Lunas',
                        amount: CurrencyFormatter.format(totalAmount),
                        subtitle: !widget.isHistory
                            ? 'Kewajiban pembayaran Anda'
                            : 'Sudah dibayar',
                        icon: Icons.trending_down_rounded,
                        gradientColors: const [
                          Color(0xFFFF512F),
                          Color(0xFFDD2476),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (utangList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final bon = utangList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: UtangCardWidget(
                          bon: bon,
                          index: index, // Pass index for staggered animation
                        ),
                      );
                    }, childCount: utangList.length),
                  ),
                ),
            ],
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    final message = widget.isHistory
        ? 'Belum ada riwayat pelunasan'
        : 'Belum ada utang aktif';
    final subMessage = widget.isHistory
        ? 'Utang yang sudah lunas akan muncul di sini'
        : 'Utang adalah uang yang Anda pinjam dari orang lain';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isHistory
                ? Icons.history_edu_rounded
                : Icons.credit_card_outlined,
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
