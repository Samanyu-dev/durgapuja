import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoggingService {
  static bool _isInitialized = false;
  static bool _isDebugMode = kDebugMode;

  static void initialize() {
    _isInitialized = true;
    _isDebugMode = kDebugMode;
    logInfo('Logging service initialized in ${_isDebugMode ? 'debug' : 'release'} mode');
  }

  static void logInfo(String message, {String? tag}) {
    if (!_isInitialized) return;
    
    final logTag = tag ?? 'INFO';
    if (_isDebugMode) {
      developer.log(message, name: logTag);
    }
    // In production, you might want to send logs to a remote service
  }

  static void logWarning(String message, {String? tag}) {
    if (!_isInitialized) return;
    
    final logTag = tag ?? 'WARNING';
    if (_isDebugMode) {
      developer.log(message, name: logTag);
    }
  }

  static void logError(String message, {String? tag, StackTrace? stackTrace}) {
    if (!_isInitialized) return;
    
    final logTag = tag ?? 'ERROR';
    if (_isDebugMode) {
      developer.log(
        message, 
        name: logTag, 
        error: stackTrace,
        stackTrace: stackTrace
      );
    }
    // In production, send to crash reporting service
  }

  static void logDebug(String message, {String? tag}) {
    if (!_isInitialized) return;
    
    if (_isDebugMode) {
      final logTag = tag ?? 'DEBUG';
      developer.log(message, name: logTag);
    }
  }

  static void logNetwork(String message, {String? tag}) {
    if (!_isInitialized) return;
    
    final logTag = tag ?? 'NETWORK';
    if (_isDebugMode) {
      developer.log(message, name: logTag);
    }
  }

  static void logPerformance(String message, {String? tag}) {
    if (!_isInitialized) return;
    
    final logTag = tag ?? 'PERFORMANCE';
    if (_isDebugMode) {
      developer.log(message, name: logTag);
    }
  }
}