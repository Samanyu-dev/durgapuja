// Simple Firebase Testing Script - No Flutter dependencies
// Run with: dart run scripts/firebase_test_simple.dart

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

class FirebaseTester {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test results
  Map<String, dynamic> results = {};

  Future<void> runAllTests() async {
    print('🚀 Starting Simple Firebase Testing Suite...\n');

    try {
      // Initialize Firebase
      await _initializeFirebase();
      results['firebase_init'] = {'success': true, 'message': 'Firebase initialized successfully'};

      // Test Firestore operations
      await _testFirestoreOperations();

      // Test Authentication setup
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
      // Test 1: Add test document
      print('   Adding test document...');
      final testDocId = 'test_doc_${DateTime.now().millisecondsSinceEpoch}';
      final testData = {
        'name': 'Firebase Test Document',
        'timestamp': FieldValue.serverTimestamp(),
        'test_field': 'Hello Firebase!',
        'number_field': 42,
      };

      await _firestore.collection('test_collection').doc(testDocId).set(testData);
      results['firestore_write'] = {'success': true, 'doc_id': testDocId};
      print('   ✅ Document added successfully');

      // Test 2: Read the document back
      print('   Reading test document...');
      final docSnapshot = await _firestore.collection('test_collection').doc(testDocId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        results['firestore_read'] = {
          'success': true,
          'data': data,
          'name': data?['name'],
        };
        print('   ✅ Document read successfully: ${data?['name']}');
      } else {
        throw Exception('Document not found after writing');
      }

      // Test 3: Query documents
      print('   Querying documents...');
      final querySnapshot = await _firestore.collection('test_collection').get();
      results['firestore_query'] = {
        'success': true,
        'total_docs': querySnapshot.docs.length,
      };
      print('   ✅ Query successful: ${querySnapshot.docs.length} documents found');

      // Test 4: Delete test document
      print('   Deleting test document...');
      await _firestore.collection('test_collection').doc(testDocId).delete();
      results['firestore_delete'] = {'success': true, 'doc_id': testDocId};
      print('   ✅ Document deleted successfully');

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
      // Test Firebase Auth instance
      final currentUser = _auth.currentUser;
      print('   Current authenticated user: ${currentUser?.uid ?? 'None'}');
      print('   User email: ${currentUser?.email ?? 'None'}');
      print('   User phone: ${currentUser?.phoneNumber ?? 'None'}');

      results['auth_setup'] = {
        'success': true,
        'current_user': currentUser?.uid,
        'user_email': currentUser?.email,
        'user_phone': currentUser?.phoneNumber,
      };

      print('✅ Authentication setup verified');

      // Note about phone auth testing
      print('   📱 Note: Phone authentication testing requires:');
      print('      - Real device (not simulator)');
      print('      - Valid phone number');
      print('      - Firebase Console phone auth enabled');
      print('      - Test it through the actual Flutter app');

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
      print('💡 Next: Test phone authentication in the actual Flutter app');
    } else {
      print('⚠️  Some tests failed. Check Firebase configuration.');
    }
    print('=' * 50);
  }
}

void main() async {
  final tester = FirebaseTester();
  await tester.runAllTests();
}
