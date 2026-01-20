// Comprehensive Firebase Testing Script
// Run with: dart run scripts/firebase_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';
import '../lib/models/client.dart';
import '../lib/models/idol_order.dart';
import '../lib/models/transaction.dart' as models;
import '../lib/services/auth_service.dart';
import '../lib/services/firestore_service.dart';

class FirebaseTester {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Test results
  Map<String, dynamic> results = {};

  Future<void> runAllTests() async {
    print('🚀 Starting Firebase Testing Suite...\n');

    try {
      // Initialize Firebase
      await _initializeFirebase();
      results['firebase_init'] = {'success': true, 'message': 'Firebase initialized successfully'};

      // Test Firestore operations
      await _testFirestoreOperations();

      // Test Authentication (Note: Phone auth requires real device/testing app)
      await _testAuthenticationSetup();

      // Generate test report
      _generateReport();

    } catch (e) {
      print('❌ Test suite failed: $e');
      results['overall'] = {'success': false, 'error': e.toString()};
    }
  }

  Future<void> _initializeFirebase() async {
    print('📱 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');

      // Test basic connectivity
      final user = _auth.currentUser;
      print('📊 Current user: ${user?.uid ?? 'None'}');

    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _testFirestoreOperations() async {
    print('\n🗄️  Testing Firestore Operations...');

    try {
      // Test 1: Add test client
      print('   Adding test client...');
      final testClient = Client(
        id: 'test_client_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Firebase Test Client',
        phone: '+919876543210',
        status: 'Active',
        idols: [
          IdolOrder(
            id: 'test_idol_1',
            name: 'Test Durga Idol',
            requirements: 'Firebase connectivity test',
            deliveryDate: DateTime.now().add(const Duration(days: 7)),
            status: 'Testing',
          ),
        ],
        pendingAmount: 15000.0,
        deliveryDates: [DateTime.now().add(const Duration(days: 7))],
        notes: ['Created during Firebase testing'],
      );

      await _firestoreService.addClient(testClient);
      results['firestore_client_add'] = {'success': true, 'client_id': testClient.id};
      print('   ✅ Client added successfully');

      // Test 2: Retrieve clients
      print('   Retrieving clients...');
      final clients = await _firestoreService.getClients();
      results['firestore_clients_retrieve'] = {
        'success': true,
        'count': clients.length,
        'has_test_client': clients.any((c) => c.id == testClient.id)
      };
      print('   ✅ Retrieved ${clients.length} clients');

      // Test 3: Add test material
      print('   Adding test material...');
      final testMaterial = models.MaterialRate(
        id: 'test_material_${DateTime.now().millisecondsSinceEpoch}',
        materialName: 'Test Clay',
        unit: 'kg',
        rate: 250.0,
        lastUpdated: DateTime.now(),
      );

      await _firestoreService.addMaterial(testMaterial);
      results['firestore_material_add'] = {'success': true, 'material_id': testMaterial.id};
      print('   ✅ Material added successfully');

      // Test 4: Add test transaction
      print('   Adding test transaction...');
      final testTransaction = models.Transaction(
        id: 'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Firebase Test Purchase',
        date: DateTime.now(),
        amount: 5000.0,
        category: 'Expense',
      );

      await _firestoreService.addTransaction(testTransaction);
      results['firestore_transaction_add'] = {'success': true, 'transaction_id': testTransaction.id};
      print('   ✅ Transaction added successfully');

      // Test 5: Retrieve all data
      print('   Retrieving all data...');
      final materials = await _firestoreService.getMaterials();
      final transactions = await _firestoreService.getTransactions();

      results['firestore_data_retrieval'] = {
        'success': true,
        'clients': clients.length,
        'materials': materials.length,
        'transactions': transactions.length,
      };
      print('   ✅ Data retrieval successful: ${clients.length} clients, ${materials.length} materials, ${transactions.length} transactions');

      print('✅ All Firestore operations completed successfully');

    } catch (e) {
      print('❌ Firestore test failed: $e');
      results['firestore'] = {'success': false, 'error': e.toString()};
      rethrow;
    }
  }

  Future<void> _testAuthenticationSetup() async {
    print('\n🔐 Testing Authentication Setup...');

    try {
      // Test Auth Service initialization
      print('   Testing Auth Service...');
      final currentUser = _authService.currentUser;
      print('   Current user (AuthService): ${currentUser?.uid ?? 'None'}');

      // Test Firebase Auth instance
      final firebaseUser = _auth.currentUser;
      print('   Current user (Firebase): ${firebaseUser?.uid ?? 'None'}');

      results['auth_setup'] = {
        'success': true,
        'auth_service_user': currentUser?.uid,
        'firebase_user': firebaseUser?.uid,
        'is_test_mode': _authService.isTestMode,
      };

      print('✅ Authentication setup verified');

      // Note about phone auth testing
      print('   📱 Note: Phone authentication testing requires:');
      print('      - Real device (not simulator)');
      print('      - Valid phone number');
      print('      - Firebase Console phone auth enabled');

    } catch (e) {
      print('❌ Authentication test failed: $e');
      results['auth'] = {'success': false, 'error': e.toString()};
    }
  }

  void _generateReport() {
    print('\n📊 FIREBASE TEST REPORT');
    print('=' * 50);

    bool allPassed = true;

    results.forEach((test, result) {
      final success = result['success'] ?? false;
      if (!success) allPassed = false;

      final status = success ? '✅ PASS' : '❌ FAIL';
      print('$status $test');

      if (!success && result.containsKey('error')) {
        print('   Error: ${result['error']}');
      }
    });

    print('\n' + '=' * 50);
    if (allPassed) {
      print('🎉 ALL TESTS PASSED! Firebase is working correctly.');
    } else {
      print('⚠️  Some tests failed. Check Firebase configuration.');
    }
    print('=' * 50);
  }
}

void main() async {
  // Initialize for command line usage
  WidgetsFlutterBinding.ensureInitialized();

  final tester = FirebaseTester();
  await tester.runAllTests();
}
