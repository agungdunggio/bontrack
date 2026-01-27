import 'package:bontrack/core/models/bon_model.dart';
import 'package:bontrack/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountHeaderWidget extends StatelessWidget {
  final BonModel bon;
  final bool isPiutang;
  final ThemeData theme;

  const AmountHeaderWidget({
    required this.bon,
    required this.isPiutang,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = CurrencyFormatter.format(bon.amount);

    final statusColor = isPiutang ? Colors.green : Colors.orange;

    Color badgeColor;
    String badgeText;

    if (bon.isPaid) {
      badgeColor = Colors.green;
      badgeText = 'LUNAS';
    } else {
      badgeColor = statusColor;
      badgeText = isPiutang ? 'PIUTANG' : 'UTANG';
    }

    final otherMxName = isPiutang ? bon.debtorName : bon.creditorName;
    final relationText = isPiutang ? 'dari ' : 'ke ';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          formattedAmount,
          style: GoogleFonts.poppins(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
            height: 1.0,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              relationText,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
            Flexible(
              child: Text(
                otherMxName,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
