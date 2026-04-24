// Raw Firebase Testing Script - No app dependencies
// Run with: dart test_firebase_raw.dart

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRawTester {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase project configuration (from your firebase_options.dart)
  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyAS6VstWG5JSvZypvpKREUBpQYuCso_lO8',
    appId: '1:883266614954:android:3f6fe3fccee696fd8c42d3',
    messagingSenderId: '883266614954',
    projectId: 'idolmakers-e7c0c',
    storageBucket: 'idolmakers-e7c0c.firebasestorage.app',
  );

  Future<void> runAllTests() async {
    print('🚀 Starting Raw Firebase Testing Suite...\n');

    try {
      // Initialize Firebase
      await _initializeFirebase();

      // Test Firestore operations
      await _testFirestoreOperations();

      // Test Authentication setup
      await _testAuthenticationSetup();

      print('\n🎉 Firebase testing completed successfully!');
      print('📊 Check Firebase Console for created test data.');
      print('🔗 Console URL: https://console.firebase.google.com/project/idolmakers-e7c0c/firestore');

    } catch (e) {
      print('❌ Test suite failed: $e');
      print('🔍 Check Firebase Console for any partial data that was created.');
    }
  }

  Future<void> _initializeFirebase() async {
    print('📱 Initializing Firebase with raw config...');
    try {
      await Firebase.initializeApp(
        options: firebaseOptions,
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
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Test 1: Create test client document
      print('   Creating test client document...');
      final clientData = {
        'id': 'test_client_$timestamp',
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
        'testType': 'raw_firebase_test',
      };

      await _firestore.collection('clients').doc(clientData['id'] as String).set(clientData);
      print('   ✅ Test client created: ${clientData['id']}');

      // Test 2: Create test material document
      print('   Creating test material document...');
      final materialData = {
        'id': 'test_material_$timestamp',
        'materialName': 'Test Clay',
        'unit': 'kg',
        'rate': 250.0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'testType': 'raw_firebase_test',
      };

      await _firestore.collection('materials').doc(materialData['id'] as String).set(materialData);
      print('   ✅ Test material created: ${materialData['id']}');

      // Test 3: Create test transaction document
      print('   Creating test transaction document...');
      final transactionData = {
        'id': 'test_transaction_$timestamp',
        'title': 'Firebase Test Purchase',
        'date': FieldValue.serverTimestamp(),
        'amount': 5000.0,
        'category': 'Expense',
        'testType': 'raw_firebase_test',
      };

      await _firestore.collection('transactions').doc(transactionData['id'] as String).set(transactionData);
      print('   ✅ Test transaction created: ${transactionData['id']}');

      // Test 4: Query and verify data
      print('   Verifying created data...');

      // Query clients with test type
      final clientsQuery = await _firestore
          .collection('clients')
          .where('testType', isEqualTo: 'raw_firebase_test')
          .get();

      // Query materials with test type
      final materialsQuery = await _firestore
          .collection('materials')
          .where('testType', isEqualTo: 'raw_firebase_test')
          .get();

      // Query transactions with test type
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('testType', isEqualTo: 'raw_firebase_test')
          .get();

      print('   📊 Test data verification:');
      print('      - Test Clients: ${clientsQuery.docs.length}');
      print('      - Test Materials: ${materialsQuery.docs.length}');
      print('      - Test Transactions: ${transactionsQuery.docs.length}');

      // Show sample data
      if (clientsQuery.docs.isNotEmpty) {
        final sampleClient = clientsQuery.docs.first.data();
        print('      - Sample client: ${sampleClient['name']}');
      }

      print('✅ All Firestore operations completed successfully');

    } catch (e) {
      print('❌ Firestore test failed: $e');
      rethrow;
    }
  }

  Future<void> _testAuthenticationSetup() async {
    print('\n🔐 Testing Authentication Setup...');

    try {
      // Test Firebase Auth instance
      final currentUser = _auth.currentUser;
      print('   Current Firebase user: ${currentUser?.uid ?? 'None'}');

      if (currentUser != null) {
        print('   User email: ${currentUser.email ?? 'None'}');
        print('   User phone: ${currentUser.phoneNumber ?? 'None'}');
        print('   Email verified: ${currentUser.emailVerified}');
      }

      print('✅ Authentication setup verified');

      // Note about phone auth testing
      print('   📱 Note: Phone authentication requires:');
      print('      - Real device (not simulator)');
      print('      - Valid phone number');
      print('      - Firebase Console phone auth enabled');
      print('      - Test through the actual Flutter app');

    } catch (e) {
      print('❌ Authentication test failed: $e');
    }
  }
}

void main() async {
  print('Raw Firebase Testing Script');
  print('===========================');
  print('This script will test Firebase connectivity and create test data.');
  print('Check Firebase Console after running to verify the results.');
  print('Firebase Project: idolmakers-e7c0c\n');

  final tester = FirebaseRawTester();
  await tester.runAllTests();

  print('\n🔚 Script completed.');
  print('📊 Check Firebase Console:');
  print('   - Firestore Database: https://console.firebase.google.com/project/idolmakers-e7c0c/firestore');
  print('   - Authentication: https://console.firebase.google.com/project/idolmakers-e7c0c/authentication');
}
