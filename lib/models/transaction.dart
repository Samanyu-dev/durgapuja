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
    try {
      return Transaction(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        amount: map['amount'].toDouble(),
        category: map['category'],
      );
    } catch (e) {
      // Return a default transaction if parsing fails
      return Transaction(
        id: map['id'] ?? '',
        title: map['title'] ?? 'Unknown Transaction',
        date: DateTime.now(),
        amount: 0.0,
        category: map['category'] ?? 'unknown',
      );
    }
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty && 
           title.isNotEmpty && 
           amount != 0.0 &&
           category.isNotEmpty;
  }

  // Helper methods
  bool isIncome() => amount > 0;
  bool isExpense() => amount < 0;
  String getFormattedAmount() => isIncome() ? '+₹${amount.abs()}' : '-₹${amount.abs()}';
  String getDisplayCategory() => category.isEmpty ? 'Uncategorized' : category;
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
    try {
      return MaterialRate(
        id: map['id'],
        materialName: map['materialName'],
        unit: map['unit'],
        rate: map['rate'].toDouble(),
        lastUpdated: DateTime.parse(map['lastUpdated']),
      );
    } catch (e) {
      // Return a default material rate if parsing fails
      return MaterialRate(
        id: map['id'] ?? '',
        materialName: map['materialName'] ?? 'Unknown Material',
        unit: map['unit'] ?? 'unit',
        rate: 0.0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty && 
           materialName.isNotEmpty && 
           unit.isNotEmpty && 
           rate > 0;
  }

  // Helper methods
  String getFormattedRate() => '₹$rate / $unit';
  bool isRecentUpdate() => lastUpdated.isAfter(DateTime.now().subtract(const Duration(days: 30)));
}
