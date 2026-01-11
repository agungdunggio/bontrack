import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cubit/auth/auth_cubit.dart';
import '../../../core/cubit/auth/auth_state.dart';
import '../../../app/widget/bottom_toast.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String uid;
  final String email;
  final String? displayName; // Nama dari Google Sign In (opsional)

  const CompleteProfileScreen({
    super.key,
    required this.uid,
    required this.email,
    this.displayName,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill nama dari Google Sign In jika ada
    if (widget.displayName != null && widget.displayName!.isNotEmpty) {
      _nameController.text = widget.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove spaces and special characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If starts with 0, replace with +62
    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    }
    // If starts with 62, add +
    else if (phone.startsWith('62') && !phone.startsWith('+')) {
      phone = '+$phone';
    }
    // If doesn't start with +, add +62
    else if (!phone.startsWith('+')) {
      phone = '+62$phone';
    }
    
    return phone;
  }

  void _completeProfile() {
    // Tutup keyboard
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _formatPhoneNumber(_phoneController.text.trim());
      
      context.read<AuthCubit>().completeUserProfile(
        uid: widget.uid,
        email: widget.email,
        phoneNumber: phoneNumber,
        name: _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lengkapi Profil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              print("Error: ${state.message}");
              BottomToast.show(
                context,
                message: state.message,
                type: BottomToastType.error,
                duration: const Duration(milliseconds: 3000),
              );
            }
            // AuthAuthenticated will be handled by main.dart
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hampir Selesai!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lengkapi profil Anda untuk melanjutkan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akun Google Terhubung',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.email,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama Anda',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '08xxxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      helperText: 'Contoh: 08123456789 atau +6281234567890',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      // Basic validation
                      final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                      if (cleaned.length < 10) {
                        return 'Nomor telepon tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _completeProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Selesai',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nomor telepon digunakan untuk identifikasi dan notifikasi',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

