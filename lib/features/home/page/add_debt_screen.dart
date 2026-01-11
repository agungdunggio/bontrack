import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/debt_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/debt_model.dart';

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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  final _debtService = DebtService();
  
  UserModel? _selectedDebtor;
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  bool _useManualInput = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<void> _pickContactFromPhone() async {
    try {
      // Request permission
      final permissionStatus = await Permission.contacts.request();
      
      if (permissionStatus.isGranted) {
        // Pick a contact
        final contact = await FlutterContacts.openExternalPick();
        
        if (contact != null) {
          // Get full contact details
          final fullContact = await FlutterContacts.getContact(contact.id);
          
          if (fullContact != null) {
            String name = fullContact.displayName;
            String phone = '';
            
            // Get primary phone number
            if (fullContact.phones.isNotEmpty) {
              phone = fullContact.phones.first.number;
              // Clean phone number
              phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
              
              // Format to +62
              if (phone.startsWith('0')) {
                phone = '+62${phone.substring(1)}';
              } else if (phone.startsWith('62') && !phone.startsWith('+')) {
                phone = '+$phone';
              } else if (!phone.startsWith('+')) {
                phone = '+62$phone';
              }
            }
            
            if (mounted) {
              setState(() {
                _useManualInput = true;
                _nameController.text = name;
                _phoneController.text = phone;
                _selectedDebtor = null;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kontak dipilih: $name',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      } else if (permissionStatus.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Izin akses kontak diperlukan',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Buka Pengaturan',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Izin kontak ditolak. Buka pengaturan untuk mengaktifkan',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Pengaturan',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil kontak: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      String debtorName;
      String debtorPhone;
      String debtorId;
      
      if (_useManualInput) {
        // Manual input dari kontak
        if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pilih kontak atau pilih dari daftar user',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        debtorName = _nameController.text.trim();
        debtorPhone = _formatPhoneNumber(_phoneController.text.trim());
        
        // Check if user exists with this phone number
        final existingUser = await _authService.getUserByPhone(debtorPhone);
        if (existingUser != null) {
          debtorId = existingUser.uid;
        } else {
          // Use phone number as temporary ID
          debtorId = 'temp_${debtorPhone.replaceAll('+', '')}';
        }
      } else {
        // Pilih dari existing user
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
        
        debtorId = _selectedDebtor!.uid;
        debtorName = _selectedDebtor!.name;
        debtorPhone = _selectedDebtor!.phoneNumber;
      }

      setState(() => _isLoading = true);

      try {
        final debt = DebtModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          debtorId: debtorId,
          debtorName: debtorName,
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
                    // Toggle between existing user and manual input
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                value: false,
                                label: Text(
                                  'Dari User',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                icon: const Icon(Icons.people, size: 18),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text(
                                  'Dari Kontak',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                icon: const Icon(Icons.contacts, size: 18),
                              ),
                            ],
                            selected: {_useManualInput},
                            onSelectionChanged: (Set<bool> selected) {
                              setState(() {
                                _useManualInput = selected.first;
                                _selectedDebtor = null;
                                _nameController.clear();
                                _phoneController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (!_useManualInput) ...[
                      // Pilih dari existing user
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
                        child: _users.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Belum ada user terdaftar',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gunakan "Dari Kontak" untuk menambah dari kontak HP',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : DropdownButtonHideUnderline(
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
                                            backgroundColor: Theme.of(context).colorScheme.primary,
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
                                                  user.phoneNumber,
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
                    ] else ...[
                      // Manual input dari kontak
                      Text(
                        'Pilih dari Kontak HP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickContactFromPhone,
                        icon: const Icon(Icons.contacts),
                        label: Text(
                          'Pilih Kontak',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          hintText: 'Nama orang yang berutang',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (_useManualInput && (value == null || value.isEmpty)) {
                            return 'Nama tidak boleh kosong';
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (_useManualInput && (value == null || value.isEmpty)) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                    
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
