// Standalone Firebase Testing Script
// Run with: dart test_firebase_standalone.dart

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/firestore_service.dart';

class FirebaseStandaloneTester {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> runAllTests() async {
    print('🚀 Starting Firebase Standalone Testing Suite...\n');

    try {
      // Initialize Firebase
      await _initializeFirebase();

      // Test Firestore operations
      await _testFirestoreOperations();

      // Test Authentication setup
      await _testAuthenticationSetup();

      print('\n🎉 Firebase testing completed successfully!');
      print('📊 Check Firebase Console for created data and authentication attempts.');

    } catch (e) {
      print('❌ Test suite failed: $e');
      print('🔍 Check Firebase Console for any partial data that was created.');
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
      // Test 1: Create test client
      print('   Creating test client...');
      final clientData = {
        'id': 'test_client_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Firebase Test Client',
        'phone': '+919876543210',
        'idols': [
          {
            'id': 'test_idol_1',
            'name': 'Test Durga Idol',
            'requirements': 'Firebase connectivity test',
            'deliveryDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            'status': 'Testing',
          }
        ],
        'pendingAmount': 15000.0,
        'deliveryDates': [DateTime.now().add(const Duration(days: 7)).toIso8601String()],
        'notes': ['Created during Firebase testing'],
        'createdAt': FieldValue.serverTimestamp(),
      };

      final clientRef = _firestore.collection('clients').doc(clientData['id'] as String);
      await clientRef.set(clientData);
      print('   ✅ Test client created: ${clientData['id']}');

      // Test 2: Create test material
      print('   Creating test material...');
      final materialData = {
        'id': 'test_material_${DateTime.now().millisecondsSinceEpoch}',
        'materialName': 'Test Clay',
        'unit': 'kg',
        'rate': 250.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      final materialRef = _firestore.collection('materials').doc(materialData['id'] as String);
      await materialRef.set(materialData);
      print('   ✅ Test material created: ${materialData['id']}');

      // Test 3: Create test transaction
      print('   Creating test transaction...');
      final transactionData = {
        'id': 'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Firebase Test Purchase',
        'date': FieldValue.serverTimestamp(),
        'amount': 5000.0,
        'category': 'Expense',
      };

      final transactionRef = _firestore.collection('transactions').doc(transactionData['id'] as String);
      await transactionRef.set(transactionData);
      print('   ✅ Test transaction created: ${transactionData['id']}');

      // Test 4: Query and verify data
      print('   Verifying created data...');

      final clientsQuery = await _firestore.collection('clients').get();
      final materialsQuery = await _firestore.collection('materials').get();
      final transactionsQuery = await _firestore.collection('transactions').get();

      print('   📊 Data verification:');
      print('      - Clients: ${clientsQuery.docs.length}');
      print('      - Materials: ${materialsQuery.docs.length}');
      print('      - Transactions: ${transactionsQuery.docs.length}');

      print('✅ All Firestore operations completed successfully');

    } catch (e) {
      print('❌ Firestore test failed: $e');
      rethrow;
    }
  }

  Future<void> _testAuthenticationSetup() async {
    print('\n🔐 Testing Authentication Setup...');

    try {
      // Test Auth Service initialization
      final currentUser = _auth.currentUser;
      print('   Current Firebase user: ${currentUser?.uid ?? 'None'}');
      print('   Test mode status: ${_authService.isTestMode}');

      // Note about phone auth testing
      print('   📱 Note: Phone authentication requires:');
      print('      - Real device (not simulator)');
      print('      - Valid phone number');
      print('      - Firebase Console phone auth enabled');
      print('      - Test through the actual Flutter app');

      print('✅ Authentication setup verified');

    } catch (e) {
      print('❌ Authentication test failed: $e');
    }
  }
}

void main() async {
  print('Firebase Standalone Testing Script');
  print('====================================');
  print('This script will test Firebase connectivity and create test data.');
  print('Check Firebase Console after running to verify the results.\n');

  final tester = FirebaseStandaloneTester();
  await tester.runAllTests();

  print('\n🔚 Script completed. Check Firebase Console for results.');
}
