import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';
import '../services/logging_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock UserCredential for testing
class MockUserCredential implements UserCredential {
  final User _user;

  MockUserCredential(this._user);

  @override
  User get user => _user;

  @override
  AuthCredential? get credential => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;
}

// Mock user database for development without Firebase
class _MockUserDatabase {
  final Map<String, UserModel> _users = {};
  final Map<String, String> _phoneToUid = {};

  _MockUserDatabase() {
    // No default test users in production.
    // Use AuthService.setTestMode(true) to enable mock authentication during development.
  }

  void _addTestUser(String phone, UserRole role, String name) {
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
  }

  UserModel? getUser(String uid) => _users[uid];
  String? getUidForPhone(String phone) => _phoneToUid[phone];

  void updateLastLogin(String uid) {
    if (_users.containsKey(uid)) {
      _users[uid] = _users[uid]!.copyWith(lastLogin: DateTime.now());
    }
  }

  void addUser(UserModel user) {
    _users[user.uid] = user;
    _phoneToUid[user.phoneNumber] = user.uid;
  }
}

class AuthService {
  // Lazily resolved so that in test mode (where no real Firebase app is
  // initialized) these platform singletons are never touched — accessing
  // FirebaseAuth.instance/FirebaseFirestore.instance before Firebase.initializeApp()
  // has run throws, and every call site below already branches on _isTestMode
  // before touching these.
  FirebaseAuth? __auth;
  FirebaseAuth get _auth => __auth ??= FirebaseAuth.instance;

  FirebaseFirestore? __firestore;
  FirebaseFirestore get _firestore => __firestore ??= FirebaseFirestore.instance;

  final _MockUserDatabase _mockDb = _MockUserDatabase();

  // Test mode flag - SET TO FALSE FOR PRODUCTION
  bool _isTestMode = false;

  bool get isTestMode => _isTestMode;

  // Enable/disable test mode
  void setTestMode(bool enabled) {
    _isTestMode = enabled;
  }

  final StreamController<User?> _testAuthController =
      StreamController<User?>.broadcast();

  User? get currentUser => _isTestMode ? _mockUser : _auth.currentUser;

  User? _mockUser;

  User createMockUser(String uid, String phoneNumber) {
    return MockUser(uid: uid, phoneNumber: phoneNumber);
  }

  // Public access to mock user for testing
  User? get mockUser => _mockUser;
  set mockUser(User? user) => _mockUser = user;

  // Public access to test controller for testing
  StreamController<User?> get testAuthController => _testAuthController;

  Stream<User?> get authStateChanges => _isTestMode
      ? _testAuthController.stream
      : _auth.authStateChanges();

  AuthService({bool testMode = false}) {
    _isTestMode = testMode;
    // Initialize Firebase in production mode
    if (!_isTestMode) {
      _initializeFirebase();
    } else {
      // In test mode, emit initial null value to indicate no user is logged in
      _testAuthController.add(null);
    }
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      LoggingService.logInfo('Firebase initialized successfully');
    } catch (e) {
      LoggingService.logError('Firebase initialization error: $e');
      // Handle the error - Firebase might not be configured properly
      // This prevents the app from getting stuck in loading state
    }
  }

  Future<void> signOut() async {
    if (_isTestMode) {
      _mockUser = null;
      _testAuthController.add(_mockUser);
    } else {
      await _auth.signOut();
    }
  }

  // OTP methods
  String? _verificationId;
  String? _pendingPhoneNumber;
  int? _resendToken;

  String? get verificationId => _verificationId;
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  Future<void> sendOTP(String phoneNumber) async {
    LoggingService.logInfo('Sending OTP to $phoneNumber');
    _pendingPhoneNumber = phoneNumber;

    if (_isTestMode) {
      await Future.delayed(const Duration(seconds: 1));
      _verificationId = 'test_verification_${DateTime.now().millisecondsSinceEpoch}';
      LoggingService.logInfo('Mock OTP sent to $phoneNumber. Use code: 123456');
      return;
    }

    final completer = Completer<void>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          try {
            final UserCredential userCredential = await _auth.signInWithCredential(credential);

            // Check if user profile exists, if not create it
            final userExists = await this.userExists(userCredential.user!.uid);
            if (!userExists) {
              await _createUserProfile(
                userCredential.user!,
                userCredential.user!.phoneNumber ?? _pendingPhoneNumber ?? '',
              );
            } else {
              await updateLastLogin(userCredential.user!.uid);
            }

            LoggingService.logInfo('Auto-verification completed successfully for ${userCredential.user!.uid}');
          } catch (e) {
            LoggingService.logError('Auto-verification failed: $e');
            // Don't throw here, let user manually enter OTP
          }
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          LoggingService.logError('Verification failed: ${e.code} - ${e.message}');
          if (!completer.isCompleted) {
            completer.completeError(FirebaseAuthException(
              code: e.code,
              message: _getErrorMessage(e.code),
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          LoggingService.logInfo('OTP sent successfully to $phoneNumber');
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          LoggingService.logWarning('Auto-retrieval timeout, manual entry required');
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      LoggingService.logError('Firebase Auth Exception in sendOTP: ${e.code} - ${e.message}');
      if (!completer.isCompleted) {
        completer.completeError(FirebaseAuthException(
          code: e.code,
          message: _getErrorMessage(e.code),
        ));
      }
    }

    return completer.future;
  }

  Future<UserCredential> verifyOTP(String smsCode) async {
    if (_isTestMode) {
      if (smsCode == '123456' && _pendingPhoneNumber != null) {
        var uid = _mockDb.getUidForPhone(_pendingPhoneNumber!);
        
        // If user doesn't exist, create new user
        if (uid == null) {
          uid = 'mock_${_pendingPhoneNumber!.replaceAll('+91', '')}';
          final newUser = UserModel(
            uid: uid,
            phoneNumber: _pendingPhoneNumber!,
            name: null,
            email: null,
            role: UserRole.user,
            isActive: true,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          _mockDb.addUser(newUser);
        }

        _mockUser = createMockUser(uid, _pendingPhoneNumber!);
        _mockDb.updateLastLogin(uid);
        _testAuthController.add(_mockUser);

        return MockUserCredential(_mockUser!);
      } else {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Invalid OTP code. Use 123456 for testing.',
        );
      }
    }

    if (_verificationId == null) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'Verification ID not found. Please request OTP again.',
      );
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user profile exists, if not create it
      final userExists = await this.userExists(userCredential.user!.uid);
      if (!userExists) {
        await _createUserProfile(
          userCredential.user!,
          userCredential.user!.phoneNumber ?? _pendingPhoneNumber ?? '',
        );
      } else {
        await updateLastLogin(userCredential.user!.uid);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    if (_isTestMode) {
      await sendOTP(phoneNumber);
      return;
    }

    _pendingPhoneNumber = phoneNumber;

    final completer = Completer<void>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            LoggingService.logError('Auto-verification on resend failed: $e');
          }
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          LoggingService.logError('Verification failed: ${e.code} - ${e.message}');
          if (!completer.isCompleted) {
            completer.completeError(FirebaseAuthException(
              code: e.code,
              message: _getErrorMessage(e.code),
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          LoggingService.logInfo('OTP resent successfully');
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(FirebaseAuthException(
          code: e.code,
          message: _getErrorMessage(e.code),
        ));
      }
    }

    return completer.future;
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    User user,
    String phoneNumber, {
    String? name,
    String? email,
  }) async {
    final userModel = UserModel(
      uid: user.uid,
      phoneNumber: phoneNumber,
      email: email,
      name: name,
      role: UserRole.user,
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
      LoggingService.logError('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, {String? name, String? email}) async {
    if (_isTestMode) {
      final user = _mockDb.getUser(uid);
      if (user != null) {
        _mockDb._users[uid] = user.copyWith(
          name: name ?? user.name,
          email: email ?? user.email,
        );
      }
      return;
    }

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;

    await _firestore.collection('users').doc(uid).update(updateData);
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    if (_isTestMode) {
      _mockDb.updateLastLogin(uid);
      return;
    }

    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    if (_isTestMode) {
      return _mockDb.getUser(uid) != null;
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'invalid-verification-code':
        return 'Invalid OTP code.';
      case 'missing-verification-id':
        return 'Verification session expired. Please request OTP again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'missing-client-identifier':
        return 'App verification failed. Please contact support.';
      case 'session-expired':
        return 'Session expired. Please request a new OTP.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _testAuthController.close();
  }
}


