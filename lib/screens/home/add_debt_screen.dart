import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/debt_service.dart';
import '../../models/user_model.dart';
import '../../models/debt_model.dart';

class AddDebtScreen extends StatefulWidget {
  final UserModel? currentUser;

  const AddDebtScreen({super.key, this.currentUser});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authService = AuthService();
  final _debtService = DebtService();
  
  UserModel? _selectedDebtor;
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await _authService.getAllUsers();
    if (mounted) {
      setState(() {
        // Filter out current user
        _users = users.where((u) => u.uid != widget.currentUser?.uid).toList();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDebtor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pilih orang yang berutang',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final debt = DebtModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          debtorId: _selectedDebtor!.uid,
          debtorName: _selectedDebtor!.name,
          creditorId: widget.currentUser!.uid,
          creditorName: widget.currentUser!.name,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          isPaid: false,
        );

        await _debtService.addDebt(debt);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Catatan utang berhasil ditambahkan',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menambahkan utang: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Catatan Utang',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pilih Orang yang Berutang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserModel>(
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          hint: Text(
                            'Pilih orang',
                            style: GoogleFonts.poppins(),
                          ),
                          value: _selectedDebtor,
                          items: _users.map((user) {
                            return DropdownMenuItem<UserModel>(
                              value: user,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          user.email,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDebtor = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Jumlah Utang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Keterangan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Utang untuk beli barang...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Keterangan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveDebt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Simpan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

