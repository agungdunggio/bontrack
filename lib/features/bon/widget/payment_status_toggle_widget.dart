import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentStatusToggleWidget extends StatelessWidget {
  final bool isPaid;
  final ValueChanged<bool> onChanged;

  const PaymentStatusToggleWidget({
    super.key,
    required this.isPaid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 105;
    const double height = 36;
    const double padding = 2;
    const double knobSize = height - (padding * 2);

    final backgroundColor = isPaid
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFF5F5F5);
    final knobColor = Colors.white;
    final activeColor = isPaid
        ? const Color(0xFF4CAF50)
        : const Color(0xFF9E9E9E);
    final textColor = isPaid
        ? const Color(0xFF2E7D32)
        : const Color(0xFF757575);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!isPaid);
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && !isPaid) {
          HapticFeedback.lightImpact();
          onChanged(true);
        } else if (details.primaryVelocity! < 0 && isPaid) {
          HapticFeedback.lightImpact();
          onChanged(false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        width: width.w,
        height: height.h,
        padding: EdgeInsets.all(padding.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(height.h / 2),
          border: Border.all(color: activeColor.withAlpha(25), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: AnimatedOpacity(
                    opacity: isPaid ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Lunas',
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: AnimatedOpacity(
                    opacity: !isPaid ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Belum Lunas',
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              alignment: isPaid ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: knobSize.w,
                height: knobSize.h,
                decoration: BoxDecoration(
                  color: knobColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: child.key == const ValueKey<bool>(true)
                            ? Tween<double>(
                                begin: 0.75,
                                end: 1.0,
                              ).animate(animation)
                            : Tween<double>(
                                begin: 0.75,
                                end: 1.0,
                              ).animate(animation),
                        child: ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      key: ValueKey<bool>(isPaid),
                      size: 15.sp,
                      color: activeColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
