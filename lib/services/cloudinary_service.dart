import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'dc2wi71nx';
  static const String _uploadPreset = 'scholardoc_profiles';

  /// Uploads image bytes to Cloudinary and returns the secure URL.
  /// [bytes]    - Raw image bytes from FilePicker
  /// [fileName] - File name with extension (e.g., "avatar.jpg")
  /// [folder]   - Optional folder path in Cloudinary (e.g., "profile_pictures")
  Future<String> uploadProfilePicture({
    required Uint8List bytes,
    required String fileName,
    String folder = 'profile_pictures',
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final String? secureUrl = json['secure_url'] as String?;
      if (secureUrl == null) {
        throw Exception('Cloudinary upload succeeded but no URL returned.');
      }
      return secureUrl;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): '
        '${error['error']?['message'] ?? response.body}',
      );
    }
  }
}
