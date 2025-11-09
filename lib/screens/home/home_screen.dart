import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/debt_service.dart';
import '../../models/debt_model.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import 'add_debt_screen.dart';
import 'debt_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _debtService = DebtService();
  late TabController _tabController;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() => _currentUser = userData);
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kasbon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Keluar',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: GoogleFonts.poppins()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut();
                      },
                      child: Text('Keluar', style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          tabs: const [
            Tab(text: 'Piutang Saya'),
            Tab(text: 'Utang Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Piutang (yang ngasih utang)
          _buildDebtList(
            stream: _debtService.getMyCredits(currentUserId),
            emptyMessage: 'Belum ada piutang',
            isCreditor: true,
          ),
          // Tab Utang (yang punya utang)
          _buildDebtList(
            stream: _debtService.getMyDebts(currentUserId),
            emptyMessage: 'Belum ada utang',
            isCreditor: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDebtScreen(currentUser: _currentUser),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Tambah Utang',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDebtList({
    required Stream<List<DebtModel>> stream,
    required String emptyMessage,
    required bool isCreditor,
  }) {
    return StreamBuilder<List<DebtModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Terjadi kesalahan: ${snapshot.error}',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        final debts = snapshot.data ?? [];

        if (debts.isEmpty) {
          return Center(
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
                  emptyMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Group by person
        Map<String, List<DebtModel>> groupedDebts = {};
        double totalAmount = 0;
        
        for (var debt in debts) {
          if (!debt.isPaid) {
            totalAmount += debt.amount;
          }
          
          final personId = isCreditor ? debt.debtorId : debt.creditorId;
          if (!groupedDebts.containsKey(personId)) {
            groupedDebts[personId] = [];
          }
          groupedDebts[personId]!.add(debt);
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    'Total ${isCreditor ? 'Piutang' : 'Utang'} Belum Lunas',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(totalAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedDebts.length,
                itemBuilder: (context, index) {
                  final personId = groupedDebts.keys.elementAt(index);
                  final personDebts = groupedDebts[personId]!;
                  final personName = isCreditor 
                      ? personDebts.first.debtorName 
                      : personDebts.first.creditorName;
                  
                  final unpaidDebts = personDebts.where((d) => !d.isPaid).toList();
                  final totalDebt = unpaidDebts.fold<double>(
                    0, 
                    (sum, debt) => sum + debt.amount,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          personName[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        personName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(totalDebt),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: totalDebt > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${unpaidDebts.length} catatan belum lunas',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DebtDetailScreen(
                              personId: personId,
                              personName: personName,
                              debts: personDebts,
                              isCreditor: isCreditor,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

