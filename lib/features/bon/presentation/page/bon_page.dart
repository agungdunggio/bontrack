import 'package:bontrack/core/enum/bon_enum.dart';
import 'package:bontrack/features/bon/presentation/content/piutang_content.dart';
import 'package:bontrack/features/bon/presentation/content/utang_content.dart';
import 'package:bontrack/features/bon/widget/modern_toggle_switch_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Utang & Piutang',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ModernToggleSwitchWidget(
              selectedType: _selectedType,
              onChanged: (BonType type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedType == BonType.piutang
                ? const PiutangContent()
                : const UtangContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add debt/credit
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Tambah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

