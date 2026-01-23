import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

enum BonType { piutang, utang }

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
            child: SegmentedButton<BonType>(
              segments: [
                ButtonSegment<BonType>(
                  value: BonType.piutang,
                  label: Text(
                    'Piutang Saya',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                ButtonSegment<BonType>(
                  value: BonType.utang,
                  label: Text(
                    'Utang Saya',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  icon: const Icon(Icons.credit_card_outlined),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<BonType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedType == BonType.piutang
                ? const _PiutangContent()
                : const _UtangContent(),
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

class _PiutangContent extends StatelessWidget {
  const _PiutangContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Belum ada piutang',
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
                'Piutang adalah uang yang dipinjamkan ke orang lain',
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

class _UtangContent extends StatelessWidget {
  const _UtangContent();

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
