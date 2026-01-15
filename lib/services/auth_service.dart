import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

// Mock Firebase User for testing
class MockUser implements User {
  final String _uid;
  final String _phoneNumber;

  MockUser({required String uid, required String phoneNumber})
      : _uid = uid,
        _phoneNumber = phoneNumber;

  @override
  String get uid => _uid;

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  String? get email => null;

  @override
  String? get displayName => null;

  @override
  String? get photoURL => null;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => UserMetadata(0, 0);

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';

  // Unimplemented methods (throw errors for unused functionality)
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock user database for development without Firebase
class _MockUserDatabase {
  final Map<String, UserModel> _users = {};
  final Map<String, String> _phoneToUid = {};
  final Map<String, String> _phoneToPassword = {};

  // Pre-populate with test users
  _MockUserDatabase() {
    _addTestUser('+919000012025', 'admin123', UserRole.admin, 'Test Admin');
    _addTestUser('+919876543210', 'user123', UserRole.user, 'Test User');
  }

  void _addTestUser(String phone, String password, UserRole role, String name) {
    final uid = 'mock_${phone.replaceAll('+91', '')}';
    final user = UserModel(
      uid: uid,
      phoneNumber: phone,
      name: name,
      email: null,
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    _users[uid] = user;
    _phoneToUid[phone] = uid;
    _phoneToPassword[phone] = password;
  }

  UserModel? getUser(String uid) => _users[uid];
  String? getUidForPhone(String phone) => _phoneToUid[phone];
  bool validatePassword(String phone, String password) => _phoneToPassword[phone] == password;

  void updateLastLogin(String uid) {
    if (_users.containsKey(uid)) {
      _users[uid] = _users[uid]!.copyWith(lastLogin: DateTime.now());
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _MockUserDatabase _mockDb = _MockUserDatabase();

  // Flag to use mock auth instead of Firebase
  static const bool _useMockAuth = true; // Set to false when Firebase is ready

  // Test mode flag - set to true to bypass Firebase auth
  bool _isTestMode = true; // TODO: Change to false when Firebase is set up

  // Stream controller for test mode auth state changes
  final StreamController<User?> _testAuthController = StreamController<User?>.broadcast();

  // Get current user
  User? get currentUser => _isTestMode ? _mockUser : _auth.currentUser;

  // Mock user for test mode
  User? _mockUser;

  // Create a mock Firebase User object
  User _createMockUser(String uid, String phoneNumber) {
    return MockUser(uid: uid, phoneNumber: phoneNumber);
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _isTestMode
      ? _testAuthController.stream
      : _auth.authStateChanges();

  // Sign out
  Future<void> signOut() async {
    if (_isTestMode) {
      _mockUser = null;
      _testAuthController.add(_mockUser);
    } else {
      await _auth.signOut();
    }
  }

  // Sign in with phone and password (using email as phone@domain.com)
  Future<bool> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    if (_isTestMode) {
      // Use mock authentication
      final uid = _mockDb.getUidForPhone(phoneNumber);
      if (uid == null) {
        throw Exception('user-not-found');
      }

      if (!_mockDb.validatePassword(phoneNumber, password)) {
        throw Exception('wrong-password');
      }

      // Create mock Firebase user
      _mockUser = _createMockUser(uid, phoneNumber);
      _mockDb.updateLastLogin(uid);

      // Emit the new user to the stream
      _testAuthController.add(_mockUser);

      return true;
    }

    try {
      // Create email from phone number for Firebase Auth
      final email = _getTestEmail(phoneNumber);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      throw e;
    }
  }

  // Sign up with phone and password
  Future<bool> signUpWithPhoneAndPassword(String phoneNumber, String password, {String? name, String? email}) async {
    try {
      // Use a Gmail account for Firebase Auth (required for email/password auth)
      final authEmail = _getTestEmail(phoneNumber);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      // Create user profile in Firestore
      await _createUserProfile(userCredential.user!, phoneNumber, name: name, email: email);

      return true;
    } catch (e) {
      throw e;
    }
  }

  // Get test email for Firebase Auth
  String _getTestEmail(String phoneNumber) {
    // For test admin user, use a specific Gmail account
    if (phoneNumber == '+919000012025') {
      return 'testadmin@durgaapp.com'; // This should be a real email you can access
    }
    // For other users, create a Gmail format
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[+\s]'), '');
    return '$cleanPhone@gmail.com'; // Use Gmail format
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, String phoneNumber, {String? name, String? email}) async {
    // Check if this is the test admin user
    final isTestAdmin = phoneNumber == '+919000012025';

    final userModel = UserModel(
      uid: user.uid,
      phoneNumber: phoneNumber,
      email: email,
      name: name,
      role: isTestAdmin ? UserRole.admin : UserRole.user, // Assign admin role to test user
      isActive: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
  }

  // Get user profile as UserModel
  Future<UserModel?> getUserProfile(String uid) async {
    if (_isTestMode) {
      return _mockDb.getUser(uid);
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, {String? name, String? email}) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;

    await _firestore.collection('users').doc(uid).update(updateData);
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Legacy OTP methods (kept for compatibility)
  Future<void> sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  String? _verificationId;
  String? get verificationId => _verificationId;

  Future<UserCredential> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not found. Please request OTP again.');
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    await _createUserProfile(userCredential.user!, userCredential.user!.phoneNumber ?? '');
    return userCredential;
  }

  Future<void> sendWhatsAppOTP(String phoneNumber) async {
    await sendOTP(phoneNumber);
  }

  Future<void> resendOTP(String phoneNumber) async {
    await sendOTP(phoneNumber);
  }
}
