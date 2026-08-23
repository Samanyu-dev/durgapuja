import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaveService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Downloads the image (if it's a remote URL) and saves it to the
  /// device's photo gallery.
  Future<bool> saveToGallery(String imageUrl, String imageName) async {
    try {
      final bytes = await _readBytes(imageUrl);

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          throw Exception('Permission to save photos was denied');
        }
      }

      await Gal.putImageBytes(bytes, name: imageName, album: 'Durga Idol Maker');
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
      final fileName = '$userId/${imageName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  /// Shares the image (downloading it first if it's a remote URL) along
  /// with an optional text message.
  Future<void> shareImage(String imageUrl, String message) async {
    try {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        final bytes = await _readBytes(imageUrl);
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(text: message, files: [XFile(file.path)]),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(text: message, files: [XFile(imageUrl)]),
        );
      }
    } catch (e) {
      debugPrint('Share image failed: $e');
      throw Exception('Failed to share image: $e');
    }
  }

  /// Downloads image to temporary location for editing
  Future<File> downloadForEditing(String imageUrl) async {
    try {
      final bytes = await _readBytes(imageUrl);

      // Create temporary file
      final directory = Directory.systemTemp;
      final fileName = 'edit_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      debugPrint('Download for editing failed: $e');
      throw Exception('Failed to download image for editing: $e');
    }
  }

  Future<Uint8List> _readBytes(String imageUrl) async {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      return response.bodyBytes;
    }
    return File(imageUrl).readAsBytes();
  }
}
