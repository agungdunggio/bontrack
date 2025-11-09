import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/debt_model.dart';
import '../../services/debt_service.dart';

class DebtDetailScreen extends StatefulWidget {
  final String personId;
  final String personName;
  final List<DebtModel> debts;
  final bool isCreditor;

  const DebtDetailScreen({
    super.key,
    required this.personId,
    required this.personName,
    required this.debts,
    required this.isCreditor,
  });

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final _debtService = DebtService();
  bool _showPaid = false;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
  }

  Future<void> _markAsPaid(DebtModel debt) async {
    try {
      await _debtService.markAsPaid(debt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utang ditandai sebagai lunas',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menandai sebagai lunas: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDebt(DebtModel debt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Catatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Hapus', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _debtService.deleteDebt(debt.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Catatan berhasil dihapus',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menghapus catatan: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDebts = _showPaid
        ? widget.debts
        : widget.debts.where((d) => !d.isPaid).toList();

    final totalUnpaid = widget.debts
        .where((d) => !d.isPaid)
        .fold<double>(0, (sum, debt) => sum + debt.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.personName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.personName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.personName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total ${widget.isCreditor ? 'Piutang' : 'Utang'} Belum Lunas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(totalUnpaid),
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '${filteredDebts.length} Catatan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilterChip(
                  label: Text(
                    'Tampilkan Lunas',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  selected: _showPaid,
                  onSelected: (value) {
                    setState(() => _showPaid = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredDebts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada catatan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = filteredDebts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _formatCurrency(debt.amount),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: debt.isPaid ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                  if (debt.isPaid)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'LUNAS',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                debt.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(debt.createdAt),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (debt.isPaid && debt.paidAt != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dilunasi: ${_formatDateTime(debt.paidAt!)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (!debt.isPaid && widget.isCreditor) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _markAsPaid(debt),
                                        icon: const Icon(Icons.check_circle_outline),
                                        label: Text(
                                          'Tandai Lunas',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _deleteDebt(debt),
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

