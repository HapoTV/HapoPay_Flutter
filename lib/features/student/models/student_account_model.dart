class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime timestamp;
  final String type; // 'debit' or 'credit'

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
      };
}

class StudentAccountModel {
  final String studentId;
  final double balance;
  final double dailyLimit;
  final double todaySpent;
  final List<TransactionModel> transactions;

  const StudentAccountModel({
    required this.studentId,
    required this.balance,
    required this.dailyLimit,
    required this.todaySpent,
    required this.transactions,
  });

  factory StudentAccountModel.fromJson(Map<String, dynamic> json) {
    return StudentAccountModel(
      studentId: json['student_id'] as String? ?? '',
      balance: (json['balance'] as num? ?? 0.0).toDouble(),
      dailyLimit: (json['daily_limit'] as num? ?? 0.0).toDouble(),
      todaySpent: (json['today_spent'] as num? ?? 0.0).toDouble(),
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'balance': balance,
        'daily_limit': dailyLimit,
        'today_spent': todaySpent,
        'transactions': transactions.map((e) => e.toJson()).toList(),
      };
}
