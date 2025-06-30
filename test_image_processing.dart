import 'dart:convert';

void main() {
  // Test data that mimics what we're seeing in the API response
  final testData = {
    'imageUrls': [["http://10.54.99.23:5074/uploads/salon-images/823a419d-449c-4fdb-9d61-9f1c1841fd0c.jpg", "http://10.54.99.23:5074/uploads/salon-images/0ac16520-585f-47dc-8a70-107dafb94ba4.jpg", "http://10.54.99.23:5074/uploads/salon-images/7857706d-a984-47c9-ab1f-0d60be292969.jpg", "http://10.54.99.23:5074/uploads/salon-images/fb859a90-84e5-430c-be5b-9c20c30acd06.jpg"]]
  };
  
  print('🧪 Testing image URL processing');
  print('📥 Input: ${testData['imageUrls']}');
  
  // Process image URLs using the same logic as in SalonDto.fromJson
  List<String> processedImageUrls = [];
  
  if (testData['imageUrls'] != null) {
    if (testData['imageUrls'] is List) {
      final rawList = testData['imageUrls'] as List;
      print('📋 imageUrls is already a List with ${rawList.length} items');
      print('📋 Raw list content: $rawList');
      
      // Recursively flatten the list and extract only valid URLs
      List<String> flattenedUrls = [];
      
      void extractUrls(dynamic item) {
        if (item is String && item.isNotEmpty) {
          // Clean up the string to remove any JSON artifacts
          String cleanUrl = item.trim();
          
          // Remove JSON array brackets and quotes
          cleanUrl = cleanUrl.replaceAll(RegExp(r'^[\[\"\s]+|[\]\"\s]+$'), '');
          
          // Only add if it looks like a valid URL
          if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://') || cleanUrl.contains('/uploads/')) {
            flattenedUrls.add(cleanUrl);
          }
        } else if (item is List) {
          for (var subItem in item) {
            extractUrls(subItem);
          }
        }
      }
      
      for (var item in rawList) {
        extractUrls(item);
      }
      
      print('📋 Extracted URLs: $flattenedUrls');
      
      processedImageUrls = flattenedUrls
          .map((url) {
            print('🔗 Processing extracted URL: "$url"');
            // Return URL as-is if it's already complete
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return url;
            } else {
              return 'http://10.54.99.23:5074$url'; // Simplified version of ImageUtils.getFullImageUrl
            }
          })
          .toList();
    }
  }
  
  print('✅ Final processed imageUrls: $processedImageUrls');
  print('');
  
  // Verify that none of the URLs are malformed
  bool allUrlsValid = true;
  for (String url in processedImageUrls) {
    if (url.contains('[') || url.contains(']') || url.contains('"')) {
      print('❌ MALFORMED URL DETECTED: $url');
      allUrlsValid = false;
    } else {
      print('✅ Valid URL: $url');
    }
  }
  
  if (allUrlsValid) {
    print('🎉 SUCCESS: All URLs are properly formatted!');
  } else {
    print('💥 FAILURE: Some URLs are still malformed!');
  }
}
