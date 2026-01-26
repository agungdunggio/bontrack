import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/auth/auth_state.dart';
import 'package:bontrack/core/cubit/bon/bon_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_state.dart';
import 'package:bontrack/core/utils/currency_formatter.dart';
import 'package:bontrack/core/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class AddBonScreen extends StatefulWidget {
  const AddBonScreen({super.key});

  @override
  State<AddBonScreen> createState() => _AddBonScreenState();
}

class _AddBonScreenState extends State<AddBonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedPhoneNumber;
  bool _isContactSelected = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _formatAmount(String value) {
    if (value.isEmpty) {
      _amountController.value = TextEditingValue.empty;
      return;
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      _amountController.clear();
      return;
    }

    // Remove leading zeros
    final amount = int.parse(digitsOnly);
    final formatted = CurrencyFormatter.format(
      amount,
    ).replaceAll('Rp', '').trim();

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  int _parseAmount(String formatted) {
    if (formatted.isEmpty) return 0;
    final digitsOnly = formatted.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  Future<void> _pickContact() async {
    try {
      final permission = await Permission.contacts.request();

      if (!permission.isGranted) {
        if (mounted) {
          _showSnackBar('Izin akses kontak diperlukan', Colors.orange);
        }
        return;
      }

      final contact = await FlutterContacts.openExternalPick();

      if (contact != null && mounted) {
        final displayName = contact.displayName;
        if (displayName.isNotEmpty) {
          setState(() {
            _nameController.text = displayName;
            _isContactSelected = true;

            if (contact.phones.isNotEmpty) {
              _selectedPhoneNumber = contact.phones.first.number
                  .toFormattedPhone();
            } else {
              _selectedPhoneNumber = null;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih kontak', Colors.red);
      }
    }
  }

  void _clearContact() {
    setState(() {
      _isContactSelected = false;
      _selectedPhoneNumber = null;
      _nameController.clear();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final amount = _parseAmount(_amountController.text);
        final debtorName = _nameController.text.trim();
        final description = _descriptionController.text.trim().isEmpty
            ? '-'
            : _descriptionController.text.trim();

        context.read<BonCubit>().createBon(
          creditorId: authState.user.uid,
          creditorName: authState.user.name,
          debtorName: debtorName,
          debtorPhoneNumber: _selectedPhoneNumber,
          amount: amount,
          description: description,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 24.sp, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Catat Utang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<BonCubit, BonState>(
        listener: (context, state) {
          if (state is BonError) {
            _showSnackBar(state.message, Colors.red);
          } else if (state is BonLoaded) {
            _showSnackBar('Berhasil disimpan', Colors.green);
            Navigator.of(context).pop();
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.h),

                        // Amount Input Section
                        Text(
                          'Berapa jumlahnya?',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        IntrinsicWidth(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[300],
                              ),
                              prefixText: 'Rp ',
                              prefixStyle: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
                            onChanged: _formatAmount,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  _parseAmount(value) == 0) {
                                return 'Masukkan jumlah';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 48.h),

                        // Form Fields Container
                        // Name Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Siapa yang berutang?',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _nameController,
                              readOnly: _isContactSelected,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: _isContactSelected
                                    ? theme.colorScheme.primary
                                    : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.normal,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(
                                  Icons.person_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22.sp,
                                ),
                                suffixIcon: IntrinsicWidth(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isContactSelected)
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: Colors.grey[400],
                                          ),
                                          onPressed: _clearContact,
                                        ),
                                      Container(
                                        margin: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: _pickContact,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 8.h,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.contacts_rounded,
                                                  size: 18.sp,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                if (!_isContactSelected) ...[
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    'Kontak',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 18.h,
                                ),
                              ),
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? 'Nama wajib diisi'
                                  : null,
                            ),
                            if (_isContactSelected &&
                                _selectedPhoneNumber != null) ...[
                              Padding(
                                padding: EdgeInsets.only(left: 16.w, top: 8.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 14.sp,
                                      color: Colors.grey[500],
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _selectedPhoneNumber!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Description Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _descriptionController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 3,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tulis keterangan (opsional)',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[400],
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 40.h,
                                  ), // Align icon to top
                                  child: Icon(
                                    Icons.notes_rounded,
                                    color: Colors.grey[500],
                                    size: 22.sp,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 18.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: EdgeInsets.all(24.w),
                child: BlocBuilder<BonCubit, BonState>(
                  builder: (context, state) {
                    final isLoading = state is BonLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Simpan Transaksi',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
