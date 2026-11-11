import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class ImageUploadService {
  /// Uploads the given image and returns the public accessible URL
  Future<String> uploadImage(XFile imageFile);
}

/// Cloudinary free image hosting service (https://cloudinary.com)
///
/// Setup steps:
/// 1. Cloud Name: Found on your Cloudinary Dashboard
/// 2. Upload Preset:
///    - Go to Settings (gear icon) -> Upload -> Upload Presets
///    - Click "Add upload preset"
///    - Set "Signing Mode" to "Unsigned"
///    - Save and copy the preset name
class CloudinaryUploadService implements ImageUploadService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryUploadService({
    required this.cloudName,
    required this.uploadPreset,
  });

  @override
  Future<String> uploadImage(XFile imageFile) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary cloudName and uploadPreset must be configured.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    final bytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;
      if (secureUrl != null && secureUrl.isNotEmpty) {
        return secureUrl;
      }
      throw Exception('Cloudinary did not return a secure_url');
    } else {
      final errorBody = response.body;
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): $errorBody',
      );
    }
  }
}
