import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/utils/image_utils.dart';

class ImageUrlDebugScreen extends StatelessWidget {
  const ImageUrlDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Test URLs
    const testUrl1 = 'uploads/profile-images/1_a75d08c5-fa60-43f4-87c1-f9dfe7e4fe9d.jpg';
    const testUrl2 = '/uploads/profile-images/1_a75d08c5-fa60-43f4-87c1-f9dfe7e4fe9d.jpg';
    const testUrl3 = 'http://192.168.41.23:5074/uploads/profile-images/1_a75d08c5-fa60-43f4-87c1-f9dfe7e4fe9d.jpg';
    
    // Process URLs
    final processedUrl1 = ImageUtils.getFullImageUrl(testUrl1);
    final processedUrl2 = ImageUtils.getFullImageUrl(testUrl2);
    final processedUrl3 = ImageUtils.getFullImageUrl(testUrl3);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image URL Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUrlSection('Base URL', AppConfig.baseUrl),
            _buildUrlSection('Server URL', AppConfig.serverUrl),
            const Divider(height: 32),
            
            _buildUrlSection('Test URL 1 (Original)', testUrl1),
            _buildUrlSection('Test URL 1 (Processed)', processedUrl1),
            _buildImageTest('Test Image 1', processedUrl1),
            const Divider(height: 32),
            
            _buildUrlSection('Test URL 2 (Original)', testUrl2),
            _buildUrlSection('Test URL 2 (Processed)', processedUrl2),
            _buildImageTest('Test Image 2', processedUrl2),
            const Divider(height: 32),
            
            _buildUrlSection('Test URL 3 (Original)', testUrl3),
            _buildUrlSection('Test URL 3 (Processed)', processedUrl3),
            _buildImageTest('Test Image 3', processedUrl3),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUrlSection(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            url,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageTest(String label, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading $label: $error');
              print('URL: $imageUrl');
              print('StackTrace: $stackTrace');
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
