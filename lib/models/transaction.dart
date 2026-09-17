import 'category.dart';

class AppTransaction {
  const AppTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final TransactionType type;
  final int amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppTransaction.fromMap(Map<String, Object?> map) => AppTransaction(
        id: map['id']! as int,
        type: map['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        amount: map['amount']! as int,
        categoryId: map['category_id']! as String,
        date: DateTime.parse(map['date']! as String),
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  Map<String, Object?> toMap({bool includeId = false}) => {
        if (includeId) 'id': id,
        'type': type.name,
        'amount': amount,
        'category_id': categoryId,
        'date': date.toIso8601String(),
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
