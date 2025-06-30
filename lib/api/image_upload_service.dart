import 'dart:io';
import 'package:stibe_partner/api/api_service.dart';

class ImageUploadService {
  final ApiService _apiService = ApiService();

  /// Upload multiple images and return their URLs
  Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    try {
      List<String> uploadedUrls = [];
      
      for (File image in images) {
        final url = await uploadSingleImage(image);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      print('❌ Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Upload a single image and return its URL
  Future<String?> uploadSingleImage(File image) async {
    try {
      print('📤 Uploading image: ${image.path}');

      // Upload using the salon image upload endpoint
      final response = await _apiService.uploadFile('/salon/upload-image', image, fieldName: 'image');
      
      print('📥 Image upload response: $response');

      if (response['data'] != null && response['data']['imageUrl'] != null) {
        final imageUrl = response['data']['imageUrl'];
        print('✅ Image uploaded successfully: $imageUrl');
        return imageUrl;
      }

      throw Exception('No image URL returned from server');
    } catch (e) {
      print('❌ Error uploading single image: $e');
      return null;
    }
  }

  /// Upload salon profile image
  Future<String?> uploadSalonProfileImage(File image) async {
    return await uploadSingleImage(image);
  }

  /// Upload service image
  Future<String?> uploadServiceImage(File image) async {
    return await uploadSingleImage(image);
  }
}
