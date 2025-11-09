class DebtModel {
  final String id;
  final String debtorId; // UID orang yang berutang
  final String debtorName; // Nama orang yang berutang
  final String creditorId; // UID orang yang memberikan utang
  final String creditorName; // Nama orang yang memberikan utang
  final double amount; // Jumlah utang
  final String description; // Keterangan
  final DateTime createdAt;
  final DateTime? paidAt; // Tanggal pelunasan (null jika belum lunas)
  final bool isPaid; // Status lunas atau belum

  DebtModel({
    required this.id,
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.paidAt,
    this.isPaid = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtorId': debtorId,
      'debtorName': debtorName,
      'creditorId': creditorId,
      'creditorName': creditorName,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  // Create from Firestore document
  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] ?? '',
      debtorId: map['debtorId'] ?? '',
      debtorName: map['debtorName'] ?? '',
      creditorId: map['creditorId'] ?? '',
      creditorName: map['creditorName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
      isPaid: map['isPaid'] ?? false,
    );
  }

  DebtModel copyWith({
    String? id,
    String? debtorId,
    String? debtorName,
    String? creditorId,
    String? creditorName,
    double? amount,
    String? description,
    DateTime? createdAt,
    DateTime? paidAt,
    bool? isPaid,
  }) {
    return DebtModel(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      debtorName: debtorName ?? this.debtorName,
      creditorId: creditorId ?? this.creditorId,
      creditorName: creditorName ?? this.creditorName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

