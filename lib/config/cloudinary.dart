import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryConfig {
  // Set your Cloudinary cloud name here
  static const String cloudName = 'dwox9olhr';

  // Set your unsigned upload preset here. If you leave the placeholder
  // value, the app will continue to use Firebase Storage as a fallback.
  static const String unsignedUploadPreset = 'YOUR_UPLOAD_PRESET';

  static String uploadUrl() => 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Uploads [file] to Cloudinary using an unsigned upload preset.
  /// Returns the uploaded file's secure URL on success, or an empty string
  /// on failure (or if unsignedUploadPreset is not configured).
  static Future<String> uploadImageUnsigned(File file) async {
    if (unsignedUploadPreset == 'YOUR_UPLOAD_PRESET') return '';

    final uri = Uri.parse(uploadUrl());
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = unsignedUploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['secure_url'] as String? ?? '';
    }
    return '';
  }
}
