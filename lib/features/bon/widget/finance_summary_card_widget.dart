import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FinanceSummaryCardWidget extends StatefulWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const FinanceSummaryCardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradientColors,
    this.subtitle,
    this.onTap,
  });

  @override
  State<FinanceSummaryCardWidget> createState() => _FinanceSummaryCardState();
}

class _FinanceSummaryCardState extends State<FinanceSummaryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.last.withValues(alpha: 0.3),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20.r),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleSection(),
                                SizedBox(height: 12.h),
                                _buildAmountSection(),
                                if (widget.subtitle != null) ...[
                                  SizedBox(height: 8.h),
                                  _buildSubtitleSection(),
                                ],
                              ],
                            ),
                          ),
                          _buildIconBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Text(
      widget.amount,
      style: GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitleSection() {
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 14.sp,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        SizedBox(width: 4.w),
        Text(
          widget.subtitle!,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Icon(widget.icon, color: Colors.white, size: 24.sp),
    );
  }
}
