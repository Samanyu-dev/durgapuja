import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/logging_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null && _userModel != null;

  // Role-based getters
  bool get isAdmin => _userModel?.role == UserRole.admin;
  bool get isIdolMaker => _userModel?.role == UserRole.idolMaker;
  bool get isUser => _userModel?.role == UserRole.user;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      LoggingService.logInfo('AuthProvider: User changed: ${user?.uid}');
      _firebaseUser = user;
      if (user != null) {
        LoggingService.logInfo('AuthProvider: Loading user profile for ${user.uid}');
        _userModel = await _authService.getUserProfile(user.uid);
        LoggingService.logInfo('AuthProvider: User model loaded: ${_userModel?.name}');
        if (_userModel != null) {
          await _authService.updateLastLogin(user.uid);
        }
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // OTP Authentication Methods
  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.sendOTP(phoneNumber);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential> verifyOTP(String smsCode) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      return await _authService.verifyOTP(smsCode);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    await _authService.resendOTP(phoneNumber);
  }

  // Direct sign-in method (bypasses OTP)
  Future<void> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // In test mode, directly create a mock user
      if (_authService.isTestMode) {
        final mockUser = _authService.createMockUser(
          'mock_${phoneNumber.replaceAll('+91', '')}', 
          phoneNumber
        );
        _authService.mockUser = mockUser;
        _authService.testAuthController.add(mockUser);
        
        // Load or create user profile
        _userModel = await _authService.getUserProfile(mockUser.uid);
        if (_userModel == null) {
          _userModel = UserModel(
            uid: mockUser.uid,
            phoneNumber: phoneNumber,
            name: null,
            email: null,
            role: UserRole.user,
            isActive: true,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          await _authService.updateUserProfile(
            mockUser.uid,
            name: _userModel?.name,
            email: _userModel?.email,
          );
        } else {
          await _authService.updateLastLogin(mockUser.uid);
        }
      } else {
        // In production mode, still use OTP flow
        await _authService.sendOTP(phoneNumber);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateUserProfile({String? name, String? email}) async {
    if (_firebaseUser != null) {
      await _authService.updateUserProfile(_firebaseUser!.uid, name: name, email: email);
      _userModel = await _authService.getUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  AuthService get authService => _authService;
}