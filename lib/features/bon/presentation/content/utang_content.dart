import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UtangContent extends StatelessWidget {
  const UtangContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Belum ada utang',
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
                'Utang adalah uang yang dipinjam dari orang lain',
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
