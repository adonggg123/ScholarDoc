import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  /// [path] is the destination path in the bucket (e.g., 'submissions/uid/filename.pdf').
  /// [file] is the File object to upload.
  Future<String> uploadFile({
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      
      // Specify content type if possible
      final SettableMetadata metadata = SettableMetadata(
        contentType: path.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
      );

      final UploadTask uploadTask = ref.putData(bytes, metadata);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.message}');
      throw Exception(e.message ?? 'Unknown Storage Error');
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception(e.toString());
    }
  }

  /// Deletes a file from Firebase Storage given its path.
  Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}
