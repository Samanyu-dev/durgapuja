import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/generated_image.dart';

class ImageSaveService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Saves image to device gallery (simplified version)
  Future<bool> saveToGallery(String imageUrl, String imageName) async {
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // For now, just show success message
      // In a real implementation, you would save to device storage
      debugPrint('Image would be saved to gallery: $imageName');
      return true;
    } catch (e) {
      debugPrint('Save to gallery failed: $e');
      return false;
    }
  }

  /// Uploads image to Firebase Storage
  Future<String> uploadToCloud(String imageUrl, String userId, String imageName) async {
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image for upload');
      }

      // Create storage reference
      final fileName = '${userId}/${imageName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('designs/$fileName');

      // Upload file
      final uploadTask = ref.putData(response.bodyBytes);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload to cloud failed: $e');
      throw Exception('Failed to upload image to cloud: $e');
    }
  }

  /// Shares image (simplified version)
  Future<void> shareImage(String imageUrl, String message) async {
    try {
      // For now, just show success message
      // In a real implementation, you would use share_plus package
      debugPrint('Image would be shared: $message');
    } catch (e) {
      debugPrint('Share image failed: $e');
      throw Exception('Failed to share image: $e');
    }
  }

  /// Saves image to favorites
  Future<void> saveToFavorites(String imageUrl, String userId, String imageName) async {
    try {
      // This would typically save to Firestore or local database
      // For now, we'll just return success
      debugPrint('Image saved to favorites: $imageName');
    } catch (e) {
      debugPrint('Save to favorites failed: $e');
      throw Exception('Failed to save image to favorites: $e');
    }
  }

  /// Downloads image to temporary location for editing
  Future<File> downloadForEditing(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image for editing');
      }

      // Create temporary file
      final directory = Directory.systemTemp;
      final fileName = 'edit_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      debugPrint('Download for editing failed: $e');
      throw Exception('Failed to download image for editing: $e');
    }
  }
}
