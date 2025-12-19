class Transaction {
  final String id;
  final String title;
  final DateTime date;
  final double amount; // positive for income, negative for expense
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'amount': amount,
      'category': category,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      amount: map['amount'].toDouble(),
      category: map['category'],
    );
  }
}

class MaterialRate {
  final String id;
  final String materialName;
  final String unit;
  final double rate;
  final DateTime lastUpdated;

  MaterialRate({
    required this.id,
    required this.materialName,
    required this.unit,
    required this.rate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialName': materialName,
      'unit': unit,
      'rate': rate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory MaterialRate.fromMap(Map<String, dynamic> map) {
    return MaterialRate(
      id: map['id'],
      materialName: map['materialName'],
      unit: map['unit'],
      rate: map['rate'].toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
