class BonModel {
  final String id;
  final int amount;
  final DateTime createdAt;
  final String creditorId;
  final String creditorName;
  final String debtorId;
  final String debtorName;
  final String description;
  final bool isPaid;
  final DateTime? paidAt;

  BonModel({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.creditorId,
    required this.creditorName,
    required this.debtorId,
    required this.debtorName,
    required this.description,
    required this.isPaid,
    this.paidAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'creditorId': creditorId,
      'creditorName': creditorName,
      'debtorId': debtorId,
      'debtorName': debtorName,
      'description': description,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory BonModel.fromMap(Map<String, dynamic> map) {
    return BonModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0 ),
      createdAt: DateTime.parse(map['createdAt']),
      creditorId: map['creditorId'] ?? '',
      creditorName: map['creditorName'] ?? '',
      debtorId: map['debtorId'] ?? '',
      debtorName: map['debtorName'] ?? '',
      description: map['description'] ?? '-',
      isPaid: map['isPaid'] ?? false,
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
    );
  }

  BonModel copyWith({
    String? id,
    int? amount,
    DateTime? createdAt,
    String? creditorId,
    String? creditorName,
    String? debtorId,
    String? debtorName,
    String? description,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return BonModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      creditorId: creditorId ?? this.creditorId,
      creditorName: creditorName ?? this.creditorName,
      debtorId: debtorId ?? this.debtorId,
      debtorName: debtorName ?? this.debtorName,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
