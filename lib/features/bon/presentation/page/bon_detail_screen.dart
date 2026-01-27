import 'package:bontrack/app/widget/info_row.dart';
import 'package:bontrack/app/widget/time_line_item.dart';
import 'package:bontrack/core/models/bon_model.dart';
import 'package:bontrack/features/bon/widget/action_section_widget.dart';
import 'package:bontrack/features/bon/widget/amount_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BonDetailScreen extends StatelessWidget {
  final BonModel bon;
  final bool isPiutang;
  final VoidCallback? onMarkAsPaid;

  const BonDetailScreen({
    super.key,
    required this.bon,
    this.isPiutang = false,
    this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final surfaceColor = isDarkMode
        ? Colors.black
        : const Color(0xFFF2F2F7); // iOS Grouped BG
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Bon',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  AmountHeaderWidget(
                    bon: bon,
                    isPiutang: isPiutang,
                    theme: theme,
                  ),

                  SizedBox(height: 32.h),

                  _InfoGroup(bon: bon, cardColor: cardColor, theme: theme),

                  SizedBox(height: 24.h),

                  _StatusSection(bon: bon, theme: theme),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ActionSectionWidget(
        bon: bon,
        isPiutang: isPiutang,
        theme: theme,
        onMarkAsPaid: onMarkAsPaid,
        surfaceColor: cardColor,
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  final BonModel bon;
  final Color cardColor;
  final ThemeData theme;

  const _InfoGroup({
    required this.bon,
    required this.cardColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InfoRow(
            label: 'Tanggal Transaksi',
            value: DateFormat('d MMM yyyy, HH:mm').format(bon.createdAt),
            theme: theme,
          ),
          Divider(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.1),
            indent: 16.w,
          ),
          InfoRow(
            label: 'Deskripsi',
            value: bon.description.isNotEmpty ? bon.description : '-',
            theme: theme,
            isMultiLine: true,
          ),
          Divider(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.1),
            indent: 16.w,
          ),
          InfoRow(
            label: 'ID Transaksi',
            value:
                '#${bon.id.substring(max(0, bon.id.length - 8))}',
            theme: theme,
            valueStyle: GoogleFonts.sourceCodePro(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  int max(int a, int b) => a > b ? a : b;
}

class _StatusSection extends StatelessWidget {
  final BonModel bon;
  final ThemeData theme;

  const _StatusSection({required this.bon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineItem(
          icon: Icons.check_circle_rounded,
          color: theme.disabledColor, 
          title: 'Transaksi Dibuat',
          subtitle: DateFormat('d MMM yyyy, HH:mm').format(bon.createdAt),
          isLast: !bon.isPaid,
          theme: theme,
        ),
        if (bon.isPaid)
          TimelineItem(
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            title: 'Pembayaran Lunas',
            subtitle: bon.paidAt != null
                ? DateFormat('d MMM yyyy, HH:mm').format(bon.paidAt!)
                : 'Tanggal tidak tercatat',
            isLast: true,
            theme: theme,
          ),
      ],
    );
  }
}
