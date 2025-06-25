import 'package:stibe_partner/constants/app_theme.dart';

class ImageUtils {
  /// Converts a relative image URL to an absolute URL
  /// 
  /// This helps handle cases where the API returns relative paths or paths
  /// without the full domain name
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    // If the URL is already absolute, return it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Get the server URL without the /api part
    final baseUrl = AppConfig.serverUrl;
    
    // If the URL starts with '/', use it directly, otherwise add a '/'
    final separator = imageUrl.startsWith('/') ? '' : '/';
    
    // Combine the base URL with the image URL
    final fullUrl = '$baseUrl$separator$imageUrl';
    
    // Debug output
    print('🔍 Image URL processing:');
    print('  - Original URL: $imageUrl');
    print('  - Base URL: $baseUrl');
    print('  - Full URL: $fullUrl');
    
    return fullUrl;
  }
}
