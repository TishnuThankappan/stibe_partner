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
    
    // Clean the URL first - remove any JSON array artifacts
    String cleanUrl = imageUrl.trim();
    
    // Remove JSON array markers if they exist
    if (cleanUrl.startsWith('[') && cleanUrl.endsWith(']')) {
      cleanUrl = cleanUrl.substring(1, cleanUrl.length - 1);
    }
    
    // Remove quotes if they exist
    if ((cleanUrl.startsWith('"') && cleanUrl.endsWith('"')) ||
        (cleanUrl.startsWith("'") && cleanUrl.endsWith("'"))) {
      cleanUrl = cleanUrl.substring(1, cleanUrl.length - 1);
    }
    
    // If the URL is already absolute, return it as is
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }
    
    // Get the server URL without the /api part
    final baseUrl = AppConfig.serverUrl;
    
    // If the URL starts with '/', use it directly, otherwise add a '/'
    final separator = cleanUrl.startsWith('/') ? '' : '/';
    
    // Combine the base URL with the image URL
    final fullUrl = '$baseUrl$separator$cleanUrl';
    
    return fullUrl;
  }
}
