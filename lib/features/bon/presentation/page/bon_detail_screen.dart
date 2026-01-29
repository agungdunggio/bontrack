import 'package:bontrack/app/widget/info_row.dart';
import 'package:bontrack/app/widget/time_line_item.dart';
import 'package:bontrack/core/constants/color_constants.dart';
import 'package:bontrack/core/enum/bon_enum.dart';
import 'package:bontrack/core/models/bon_model.dart';
import 'package:bontrack/features/bon/widget/action_section_widget.dart';
import 'package:bontrack/features/bon/widget/amount_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BonDetailScreen extends StatelessWidget {
  final BonModel bon;
  final BonType type;
  final VoidCallback? onMarkAsPaid;

  const BonDetailScreen({
    super.key,
    required this.bon,
    this.type = BonType.piutang,
    this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use theme colors
    final surfaceColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Keep transparent for floating look
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Bon',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
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
                    type: type,
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
        type: type,
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
            color: theme.shadowColor.withAlpha(30),
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
          Divider(height: 1, color: theme.dividerTheme.color, indent: 16.w),
          InfoRow(
            label: 'Deskripsi',
            value: bon.description.isNotEmpty ? bon.description : '-',
            theme: theme,
            isMultiLine: true,
          ),
          Divider(height: 1, color: theme.dividerTheme.color, indent: 16.w),
          InfoRow(
            label: 'ID Transaksi',
            value: '#${bon.id.substring(max(0, bon.id.length - 8))}',
            theme: theme,
            valueStyle: GoogleFonts.sourceCodePro(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
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
            color: AppColors.success,
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
