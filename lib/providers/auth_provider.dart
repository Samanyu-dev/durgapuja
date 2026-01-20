import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
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
      print('AuthProvider: User changed: ${user?.uid}');
      _firebaseUser = user;
      if (user != null) {
        print('AuthProvider: Loading user profile for ${user.uid}');
        _userModel = await _authService.getUserProfile(user.uid);
        print('AuthProvider: User model loaded: ${_userModel?.name}');
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