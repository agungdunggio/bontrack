import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bontrack/core/constants/color_constants.dart';

enum BottomToastType {
  success,
  error,
  info,
}

class _BottomToastManager {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    BottomToastType type = BottomToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    EdgeInsets? margin,
  }) {
    // Jika ada toast aktif, hapus dulu
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _BottomToastWidget(
          message: message,
          type: type,
          duration: duration,
          margin: margin,
          onDismissed: () {
            entry.remove();
            if (_currentEntry == entry) {
              _currentEntry = null;
            }
          },
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class BottomToast {
  static void show(
    BuildContext context, {
    required String message,
    BottomToastType type = BottomToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    EdgeInsets? margin,
  }) {
    _BottomToastManager.show(
      context,
      message: message,
      type: type,
      duration: duration,
      margin: margin,
    );
  }
}

class _BottomToastWidget extends StatefulWidget {
  final String message;
  final BottomToastType type;
  final Duration duration;
  final EdgeInsets? margin;
  final VoidCallback onDismissed;

  const _BottomToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.margin,
  });

  @override
  State<_BottomToastWidget> createState() => _BottomToastWidgetState();
}

class _BottomToastWidgetState extends State<_BottomToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
    _autoDismiss();
  }

  Future<void> _autoDismiss() async {
    await Future.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _tintForType() {
    switch (widget.type) {
      case BottomToastType.success:
        return AppColors.success; // mengikuti theme
      case BottomToastType.error:
        return AppColors.error; // mengikuti theme
      case BottomToastType.info:
        return AppColors.info; // netral mengikuti theme
    }
  }

  IconData _iconForType() {
    switch (widget.type) {
      case BottomToastType.success:
        return Icons.check_circle_rounded;
      case BottomToastType.error:
        return Icons.error_rounded;
      case BottomToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = _tintForType();

    return IgnorePointer(
      ignoring: true, // biar tidak menghalangi interaksi di bawahnya
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: widget.margin ?? EdgeInsets.fromLTRB(16.w, 0, 16.w, 70.h),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tint.withAlpha(38),
                            tint.withAlpha(20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: tint.withAlpha(41),
                          width: 1,
                        ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.white.withAlpha(25),
                        //     blurRadius: 10,
                        //     offset: const Offset(0, 5),
                        //   ),
                        // ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22.sp,
                            height: 22.sp,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tint.withAlpha(24),
                              border: Border.all(color: tint.withAlpha(96), width: 1),
                            ),
                            child: Icon(
                              _iconForType(),
                              color: tint,
                              size: 14.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Flexible(
                            child: Text(
                              widget.message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: tint.withAlpha(204),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


