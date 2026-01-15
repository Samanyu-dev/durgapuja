// ignore_for_file: avoid_print

import 'firestore_service.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import 'dart:math';

class FirebaseTestService {
  final FirestoreService _firestore = FirestoreService();
  final Random _random = Random();

  /// Generate a random ID
  String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(1000).toString();
  }

  /// Generate dynamic test data and test Firebase connection
  Future<Map<String, dynamic>> testFirebaseConnection() async {
    try {
      // Test 1: Create and add dynamic clients
      print('Testing Firebase: Creating and adding dynamic clients...');
      final testClients = _generateTestClients(3);
      for (var client in testClients) {
        await _firestore.addClient(client);
        print('✓ Added client: ${client.name}');
      }

      // Test 2: Create and add dynamic materials
      print('Testing Firebase: Creating and adding dynamic materials...');
      final testMaterials = _generateTestMaterials(3);
      for (var material in testMaterials) {
        await _firestore.addMaterial(material);
        print('✓ Added material: ${material.materialName}');
      }

      // Test 3: Create and add dynamic transactions
      print('Testing Firebase: Creating and adding dynamic transactions...');
      final testTransactions = _generateTestTransactions(3);
      for (var transaction in testTransactions) {
        await _firestore.addTransaction(transaction);
        print('✓ Added transaction: ${transaction.title}');
      }

      // Test 4: Retrieve all data
      print('Testing Firebase: Retrieving all data...');
      final clients = await _firestore.getClients();
      final materials = await _firestore.getMaterials();
      final transactions = await _firestore.getTransactions();

      print('✓ Retrieved ${clients.length} clients');
      print('✓ Retrieved ${materials.length} materials');
      print('✓ Retrieved ${transactions.length} transactions');

      // Test 5: Verify data integrity by checking a specific client
      if (clients.isNotEmpty) {
        final firstClient = clients.first;
        final retrievedClient = await _firestore.getClientById(firstClient.id);
        if (retrievedClient != null) {
          print('✓ Client data integrity verified: ${retrievedClient.name}');
        } else {
          throw Exception('Client retrieval failed - data integrity check failed');
        }
      }

      return {
        'success': true,
        'message': 'Firebase test completed successfully!',
        'data': {
          'clients_count': clients.length,
          'materials_count': materials.length,
          'transactions_count': transactions.length,
          'sample_client': clients.isNotEmpty ? clients.first.name : null,
          'total_test_records': clients.length + materials.length + transactions.length,
        }
      };
    } catch (e) {
      print('✗ Firebase test failed: $e');
      return {
        'success': false,
        'message': 'Firebase test failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Generate dynamic test clients
  List<Client> _generateTestClients(int count) {
    final names = ['Rajesh Kumar', 'Priya Sharma', 'Amit Singh', 'Sunita Patel', 'Vikram Gupta'];
    final phones = ['9876543210', '8765432109', '7654321098', '6543210987', '5432109876'];

    return List.generate(count, (index) {
      final name = names[_random.nextInt(names.length)];
      final phone = phones[_random.nextInt(phones.length)];
      final clientId = _generateRandomId();

      return Client(
        id: clientId,
        name: name,
        phone: '+91 $phone',
        idols: [
          IdolOrder(
            id: _generateRandomId(),
            name: ['Ganesh Idol', 'Durga Idol', 'Lakshmi Idol'][_random.nextInt(3)],
            requirements: 'Custom design with traditional elements',
            deliveryDate: DateTime.now().add(Duration(days: _random.nextInt(30) + 1)),
            status: ['Pending', 'In Progress', 'Completed'][_random.nextInt(3)],
          ),
        ],
        pendingAmount: (_random.nextInt(50) + 1) * 1000.0,
        deliveryDates: [
          DateTime.now().add(Duration(days: _random.nextInt(30) + 1)),
        ],
        notes: [
          'Test client generated dynamically',
          'Created for Firebase testing',
        ],
      );
    });
  }

  /// Generate dynamic test materials
  List<MaterialRate> _generateTestMaterials(int count) {
    final materialNames = ['Clay', 'Paint', 'Bamboo', 'Gold Leaf', 'Marble Powder'];
    final units = ['kg', 'liter', 'piece', 'sheet', 'gram'];

    return List.generate(count, (index) {
      return MaterialRate(
        id: _generateRandomId(),
        materialName: materialNames[_random.nextInt(materialNames.length)],
        unit: units[_random.nextInt(units.length)],
        rate: (_random.nextInt(500) + 50).toDouble(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      );
    });
  }

  /// Generate dynamic test transactions
  List<Transaction> _generateTestTransactions(int count) {
    final titles = [
      'Material Purchase', 'Client Payment', 'Equipment Maintenance',
      'Workshop Rent', 'Marketing Expenses', 'Idol Sale'
    ];
    final categories = ['Income', 'Expense'];

    return List.generate(count, (index) {
      final isIncome = _random.nextBool();
      return Transaction(
        id: _generateRandomId(),
        title: titles[_random.nextInt(titles.length)],
        date: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        amount: (_random.nextInt(100) + 1) * (isIncome ? 1000.0 : -500.0),
        category: categories[_random.nextInt(categories.length)],
      );
    });
  }
}
