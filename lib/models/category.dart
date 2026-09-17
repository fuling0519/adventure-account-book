enum TransactionType { income, expense }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
  final String id;
  final String name;
  final String icon;
  final TransactionType type;

  factory Category.fromMap(Map<String, Object?> map) => Category(
        id: map['id']! as String,
        name: map['name']! as String,
        icon: map['icon']! as String,
        type: map['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'type': type.name,
      };
}
