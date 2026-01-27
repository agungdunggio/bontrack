import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/features/bon/widget/status_filter_widget.dart';
import 'package:bontrack/features/bon/widget/utang_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UtangContent extends StatefulWidget {
  const UtangContent({super.key});

  @override
  State<UtangContent> createState() => _UtangContentState();
}

class _UtangContentState extends State<UtangContent> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
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

              if (state is BonLoaded) {
                final utangList = state.utangList.where((bon) {
                  final isPaid = bon.isPaid;
                  return _selectedFilterIndex == 0 ? !isPaid : isPaid;
                }).toList();

                if (utangList.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  itemCount: utangList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final bon = utangList[index];
                    return UtangCardWidget(bon: bon);
                  },
                );
              }

              return _buildEmptyState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isHistory = _selectedFilterIndex == 1;
    final message = isHistory
        ? 'Belum ada riwayat pelunasan'
        : 'Belum ada utang aktif';
    final subMessage = isHistory
        ? 'Utang yang sudah lunas akan muncul di sini'
        : 'Utang adalah uang yang Anda pinjam dari orang lain';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHistory ? Icons.history_edu_rounded : Icons.credit_card_outlined,
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
