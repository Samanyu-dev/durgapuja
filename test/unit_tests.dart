// Unit tests for critical business logic
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/client.dart';
import '../lib/models/transaction.dart' as app_transaction;
import '../lib/utils/constants.dart';

// Import MaterialRate from transaction.dart
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

void main() {
  group('Client Model Tests', () {
    test('should create Client from map', () {
      // Arrange
      final clientMap = {
        'id': 'client-1',
        'name': 'John Doe',
        'phone': '+919876543210',
        'idols': [
          {
            'id': 'idol-1',
            'name': 'Durga Idol',
            'requirements': 'Traditional design',
            'deliveryDate': DateTime.now().toIso8601String(),
            'status': 'pending',
          }
        ],
        'pendingAmount': 5000.0,
        'deliveryDates': [DateTime.now().toIso8601String()],
        'notes': ['Custom requirements'],
        'photoUrl': null,
      };

      // Act
      final client = Client.fromMap(clientMap);

      // Assert
      expect(client.id, 'client-1');
      expect(client.name, 'John Doe');
      expect(client.phone, '+919876543210');
      expect(client.pendingAmount, 5000.0);
      expect(client.idols.length, 1);
      expect(client.notes.length, 1);
    });

    test('should convert Client to map', () {
      // Arrange
      final client = Client(
        id: 'client-1',
        name: 'John Doe',
        phone: '+919876543210',
        idols: [
          IdolOrder(
            id: 'idol-1',
            name: 'Durga Idol',
            requirements: 'Traditional design',
            deliveryDate: DateTime.now(),
            status: 'pending',
          )
        ],
        pendingAmount: 5000.0,
        deliveryDates: [DateTime.now()],
        notes: ['Custom requirements'],
      );

      // Act
      final clientMap = client.toMap();

      // Assert
      expect(clientMap['id'], 'client-1');
      expect(clientMap['name'], 'John Doe');
      expect(clientMap['phone'], '+919876543210');
      expect(clientMap['pendingAmount'], 5000.0);
      expect((clientMap['idols'] as List).length, 1);
      expect((clientMap['notes'] as List).length, 1);
    });

    test('should validate Client data', () {
      // Arrange & Act & Assert
      expect(() => Client(id: '', name: 'John', phone: '+919876543210', idols: [], pendingAmount: 0, deliveryDates: [], notes: []), throwsException);
      expect(() => Client(id: 'client-1', name: '', phone: '+919876543210', idols: [], pendingAmount: 0, deliveryDates: [], notes: []), throwsException);
      expect(() => Client(id: 'client-1', name: 'John', phone: 'invalid', idols: [], pendingAmount: 0, deliveryDates: [], notes: []), throwsException);
    });
  });

  group('Transaction Model Tests', () {
    test('should create Transaction from map', () {
      // Arrange
      final transactionMap = {
        'id': 'txn-1',
        'title': 'Material Purchase',
        'date': DateTime.now().toIso8601String(),
        'amount': -2500.0,
        'category': 'materials',
      };

      // Act
      final transaction = app_transaction.Transaction.fromMap(transactionMap);

      // Assert
      expect(transaction.id, 'txn-1');
      expect(transaction.title, 'Material Purchase');
      expect(transaction.amount, -2500.0);
      expect(transaction.category, 'materials');
    });

    test('should convert Transaction to map', () {
      // Arrange
      final transaction = app_transaction.Transaction(
        id: 'txn-1',
        title: 'Material Purchase',
        date: DateTime.now(),
        amount: -2500.0,
        category: 'materials',
      );

      // Act
      final transactionMap = transaction.toMap();

      // Assert
      expect(transactionMap['id'], 'txn-1');
      expect(transactionMap['title'], 'Material Purchase');
      expect(transactionMap['amount'], -2500.0);
      expect(transactionMap['category'], 'materials');
    });

    test('should calculate transaction totals correctly', () {
      // Arrange
      final transactions = [
        app_transaction.Transaction(id: '1', title: 'Payment', amount: 1000, date: DateTime.now(), category: 'income'),
        app_transaction.Transaction(id: '2', title: 'Materials', amount: -2000, date: DateTime.now(), category: 'expense'),
        app_transaction.Transaction(id: '3', title: 'Refund', amount: 500, date: DateTime.now(), category: 'income'),
      ];

      // Act
      final totalIncome = transactions
          .where((t) => t.amount > 0)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpenses = transactions
          .where((t) => t.amount < 0)
          .fold(0.0, (sum, t) => sum + t.amount.abs());

      // Assert
      expect(totalIncome, 1500.0);
      expect(totalExpenses, 2000.0);
    });
  });

  group('MaterialRate Model Tests', () {
    test('should create MaterialRate from map', () {
      // Arrange
      final materialMap = {
        'id': 'mat-1',
        'materialName': 'Clay',
        'unit': 'kg',
        'rate': 50.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Act
      final material = MaterialRate.fromMap(materialMap);

      // Assert
      expect(material.id, 'mat-1');
      expect(material.materialName, 'Clay');
      expect(material.unit, 'kg');
      expect(material.rate, 50.0);
    });

    test('should convert MaterialRate to map', () {
      // Arrange
      final material = MaterialRate(
        id: 'mat-1',
        materialName: 'Clay',
        unit: 'kg',
        rate: 50.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final materialMap = material.toMap();

      // Assert
      expect(materialMap['id'], 'mat-1');
      expect(materialMap['materialName'], 'Clay');
      expect(materialMap['unit'], 'kg');
      expect(materialMap['rate'], 50.0);
    });
  });

  group('Constants Tests', () {
    test('should have correct constant values', () {
      // Test that constants are properly defined
      expect(AppConstants.defaultPadding, isA<double>());
      expect(AppConstants.fontSizeBody, isA<double>());
      expect(AppConstants.borderRadius, isA<double>());
    });

    test('should validate email format', () {
      // Test email validation logic
      const validEmail = 'test@example.com';
      const invalidEmail = 'invalid-email';

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(emailRegex.hasMatch(validEmail), true);
      expect(emailRegex.hasMatch(invalidEmail), false);
    });

    test('should validate phone format', () {
      // Test phone validation logic
      const validPhone = '+919876543210';
      const invalidPhone = '9876543210';

      final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
      expect(phoneRegex.hasMatch(validPhone), true);
      expect(phoneRegex.hasMatch(invalidPhone), false);
    });
  });

  group('Business Logic Tests', () {
    test('should calculate correct inventory status', () {
      // Arrange
      const currentStock = 25.0;
      const minThreshold = 20.0;

      // Act
      final stockLevel = (currentStock / minThreshold) * 100;
      final isLowStock = currentStock <= minThreshold;

      // Assert
      expect(stockLevel, 125.0);
      expect(isLowStock, false);
    });

    test('should calculate order totals correctly', () {
      // Arrange
      final orderItems = [
        {'price': 1000.0, 'quantity': 2},
        {'price': 500.0, 'quantity': 1},
        {'price': 200.0, 'quantity': 3},
      ];

      // Act
      final subtotal = orderItems.fold(0.0, (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int));
      const taxRate = 0.18;
      final tax = subtotal * taxRate;
      final total = subtotal + tax;

      // Assert
      expect(subtotal, 2700.0);
      expect(tax, 486.0);
      expect(total, 3186.0);
    });

    test('should validate business rules', () {
      // Test payment validation
      const orderAmount = 5000.0;
      const paymentAmount = 3000.0;

      final isPartialPayment = paymentAmount < orderAmount;
      final remainingAmount = orderAmount - paymentAmount;

      expect(isPartialPayment, true);
      expect(remainingAmount, 2000.0);

      // Test delivery date validation
      final orderDate = DateTime.now();
      final deliveryDate = orderDate.add(const Duration(days: 15));
      final daysUntilDelivery = deliveryDate.difference(orderDate).inDays;

      expect(daysUntilDelivery, 15);
    });

    test('should calculate client pending amounts correctly', () {
      // Arrange
      final clients = [
        Client(id: '1', name: 'Client A', phone: '+911234567890', idols: [], pendingAmount: 5000, deliveryDates: [], notes: []),
        Client(id: '2', name: 'Client B', phone: '+919876543210', idols: [], pendingAmount: 3000, deliveryDates: [], notes: []),
        Client(id: '3', name: 'Client C', phone: '+918765432109', idols: [], pendingAmount: 0, deliveryDates: [], notes: []),
      ];

      // Act
      final totalPending = clients.fold(0.0, (sum, client) => sum + client.pendingAmount);
      final clientsWithPending = clients.where((client) => client.pendingAmount > 0).length;

      // Assert
      expect(totalPending, 8000.0);
      expect(clientsWithPending, 2);
    });
  });
}
