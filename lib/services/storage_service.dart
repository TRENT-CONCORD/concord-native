import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../main.dart'; // Import to access enableFirebase flag

class StorageService {
  // Only initialize Firebase Storage if Firebase is enabled
  final FirebaseStorage? _storage =
      enableFirebase ? FirebaseStorage.instance : null;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String path, File file) async {
    if (!enableFirebase) {
      // Simulate file upload for development
      debugPrint('DEV MODE: Simulating file upload to path: $path');
      // Return a mock URL
      return 'https://firebasestorage.googleapis.com/mock-storage/mock-file.jpg';
    }

    try {
      final ref = _storage!.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    if (!enableFirebase) {
      // Simulate file deletion for development
      debugPrint('DEV MODE: Simulating file deletion from path: $path');
      return;
    }

    try {
      final ref = _storage!.ref().child(path);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      // Don't throw if the file doesn't exist
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint('File not found, ignoring deletion');
        return;
      }
      throw Exception('Failed to delete file: $e');
    }
  }
}
