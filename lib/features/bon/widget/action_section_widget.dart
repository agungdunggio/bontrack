import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bontrack/core/models/bon_model.dart';

class ActionSectionWidget extends StatelessWidget {
  final BonModel bon;
  final bool isPiutang;
  final ThemeData theme;
  final Color surfaceColor;
  final VoidCallback? onMarkAsPaid;

  const ActionSectionWidget({
    super.key,
    required this.bon,
    required this.isPiutang,
    required this.theme,
    required this.surfaceColor,
    this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    if (bon.isPaid) return const SizedBox.shrink();

    final label = isPiutang
        ? 'Tandai Sudah Lunas'
        : 'Ajukan Pelunasan - on development';
    final buttonColor = isPiutang ? Colors.green : Colors.orange;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ElevatedButton(
        onPressed: isPiutang ? () => _showConfirmationDialog(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Pelunasan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah anda yakin ingin menandai transaksi ini sebagai lunas?',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onMarkAsPaid != null) {
                onMarkAsPaid!();
                Navigator.pop(context); 
              }
            },
            child: Text(
              'Ya, Lunas',
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _showRequestDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         'Permintaan Terkirim',
  //         style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  //       ),
  //       content: Text(
  //         'Notifikasi permintaan pelunasan telah dikirim ke kreditur.',
  //         style: GoogleFonts.poppins(),
  //       ),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Oke',
  //             style: GoogleFonts.poppins(color: theme.colorScheme.primary),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}