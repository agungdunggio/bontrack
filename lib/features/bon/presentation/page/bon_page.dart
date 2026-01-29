import 'package:bontrack/core/enum/bon_enum.dart';
import 'package:bontrack/features/bon/presentation/content/piutang_content.dart';
import 'package:bontrack/features/bon/presentation/content/utang_content.dart';
import 'package:bontrack/features/bon/presentation/page/add_bon_screen.dart';
import 'package:bontrack/features/bon/widget/modern_toggle_switch_widget.dart';
import 'package:bontrack/features/bon/widget/payment_status_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BonPage extends StatefulWidget {
  const BonPage({super.key});

  @override
  State<BonPage> createState() => _BonPageState();
}

class _BonPageState extends State<BonPage> {
  BonType _selectedType = BonType.piutang;
  bool _isHistory = false;
  DateTime? _lastTapTime;

  void _handleTypeChange(BonType type) {
    if (_selectedType == type) return;

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 200) {
      return;
    }
    _lastTapTime = now;

    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Utang & Piutang',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: PaymentStatusToggleWidget(
              isPaid: _isHistory,
              onChanged: (value) {
                setState(() {
                  _isHistory = value;
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _selectedType == BonType.piutang
                ? PiutangContent(paddingTop: 80.h, isHistory: _isHistory)
                : UtangContent(paddingTop: 80.h, isHistory: _isHistory),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: ModernToggleSwitchWidget(
                selectedType: _selectedType,
                onChanged: _handleTypeChange,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBonScreen()),
          );
        },
        tooltip: 'Tambah Piutang',
        child: const Icon(Icons.add),
      ),
    );
  }
}
