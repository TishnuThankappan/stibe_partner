import 'dart:convert';
import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/utils/image_utils.dart';

class SalonDto {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String email;
  final String openingTime;  // Keep as string for display
  final String closingTime;  // Keep as string for display
  final String? businessHours; // JSON string of business hours
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePictureUrl;
  final List<String> imageUrls;

  SalonDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.email,
    required this.openingTime,
    required this.closingTime,
    this.businessHours,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.profilePictureUrl,
    this.imageUrls = const [],
  });

  factory SalonDto.fromJson(Map<String, dynamic> json) {
    // Process profile picture URL
    String? processedProfilePictureUrl;
    if (json['profilePictureUrl'] != null && json['profilePictureUrl'].toString().isNotEmpty) {
      processedProfilePictureUrl = ImageUtils.getFullImageUrl(json['profilePictureUrl']);
    }
    
    // Process image URLs
    List<String> processedImageUrls = [];
    print('🔍 Processing imageUrls: ${json['imageUrls']} (type: ${json['imageUrls'].runtimeType})');
    
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        // Handle case where imageUrls is already a List
        final rawList = json['imageUrls'] as List;
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
              // Return URL as-is if it's already complete, otherwise process it
              if (url.startsWith('http://') || url.startsWith('https://')) {
                return url;
              } else {
                return ImageUtils.getFullImageUrl(url);
              }
            })
            .toList();
      } else if (json['imageUrls'] is String && json['imageUrls'].toString().isNotEmpty) {
        // Handle case where imageUrls is a JSON string
        final imageUrlsString = json['imageUrls'].toString();
        print('📝 imageUrls is a String: "$imageUrlsString"');
        
        try {
          if (imageUrlsString.startsWith('[') && imageUrlsString.endsWith(']')) {
            // It's a JSON array string, parse it
            print('🔧 Parsing as JSON array...');
            final dynamic parsed = jsonDecode(imageUrlsString);
            if (parsed is List) {
              print('✅ Successfully parsed JSON array with ${parsed.length} items: $parsed');
              processedImageUrls = parsed
                  .where((url) => url != null && url.toString().isNotEmpty)
                  .map((url) {
                    final cleanUrl = url.toString();
                    print('🔗 Processing URL from JSON: "$cleanUrl"');
                    // Return URL as-is if it's already complete
                    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
                      return cleanUrl;
                    } else {
                      return ImageUtils.getFullImageUrl(cleanUrl);
                    }
                  })
                  .toList();
            }
          } else {
            // It's a single URL string
            print('🔗 Treating as single URL');
            final cleanUrl = imageUrlsString;
            if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
              processedImageUrls = [cleanUrl];
            } else {
              processedImageUrls = [ImageUtils.getFullImageUrl(cleanUrl)];
            }
          }
        } catch (e) {
          print('❌ Error parsing imageUrls JSON: $e');
          print('📝 Raw string was: "$imageUrlsString"');
          
          // More aggressive fallback: try to extract URLs from malformed JSON
          if (imageUrlsString.contains('http')) {
            // Extract URLs using regex
            final urlPattern = RegExp(r'https?://[^\s\]\",]+');
            final matches = urlPattern.allMatches(imageUrlsString);
            processedImageUrls = matches.map((match) => match.group(0)!).toList();
            print('🔧 Extracted URLs using regex: $processedImageUrls');
          } else {
            // Last resort: treat as single URL
            final cleanUrl = imageUrlsString;
            if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
              processedImageUrls = [cleanUrl];
            } else {
              processedImageUrls = [ImageUtils.getFullImageUrl(cleanUrl)];
            }
          }
        }
      }
    }
    
    print('✅ Final processed imageUrls: $processedImageUrls');
    
    return SalonDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      openingTime: _formatTimeSpan(json['openingTime']),
      closingTime: _formatTimeSpan(json['closingTime']),
      businessHours: json['businessHours'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isActive: json['isActive'] ?? true,
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profilePictureUrl: processedProfilePictureUrl,
      imageUrls: processedImageUrls,
    );
  }

  static String _formatTimeSpan(dynamic timeSpan) {
    if (timeSpan == null) return '09:00';
    
    // Handle different formats from API
    if (timeSpan is String) {
      if (timeSpan.contains(':')) {
        return timeSpan.substring(0, 5); // Take HH:mm
      }
      return timeSpan;
    }
    
    // Handle TimeSpan object
    return timeSpan.toString().substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'businessHours': businessHours,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'imageUrls': imageUrls,
    };
  }
}

class CreateSalonRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String email;
  final String openingTime; // Format: "09:00:00"
  final String closingTime; // Format: "18:00:00"
  final Map<String, Map<String, dynamic>>? businessHours;
  final double? currentLatitude;
  final double? currentLongitude;
  final bool useCurrentLocation;
  final List<String>? imageUrls; // Add image URLs
  final String? profilePictureUrl; // Profile picture URL

  CreateSalonRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.email,
    this.openingTime = "09:00:00",
    this.closingTime = "18:00:00",
    this.businessHours,
    this.currentLatitude,
    this.currentLongitude,
    this.useCurrentLocation = false,
    this.imageUrls, // Add to constructor
    this.profilePictureUrl,
  });
  Map<String, dynamic> toJson() {
    return {
      'name': name,  // Use camelCase for the new JSON endpoint
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'businessHours': businessHours,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'useCurrentLocation': useCurrentLocation,
      'imageUrls': imageUrls, // Add image URLs to JSON
      'profilePictureUrl': profilePictureUrl,
    };
  }
}

class UpdateSalonRequest {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String email;
  final String openingTime; // Format: "09:00:00"
  final String closingTime; // Format: "18:00:00"
  final Map<String, Map<String, dynamic>>? businessHours;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls; // Updated image URLs
  final String? profilePictureUrl; // Profile picture URL
  final bool isActive;

  UpdateSalonRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.email,
    this.openingTime = "09:00:00",
    this.closingTime = "18:00:00",
    this.businessHours,
    this.latitude,
    this.longitude,
    this.imageUrls,
    this.profilePictureUrl,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'businessHours': businessHours,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'profilePictureUrl': profilePictureUrl,
      'isActive': isActive,
    };
  }
}

class SalonService {
  final ApiService _apiService = ApiService();

  // Create a new salon using the JSON endpoint
  Future<SalonDto> createSalon(CreateSalonRequest request) async {
    print('🏢 Creating salon with SalonService');
    print('📤 Request: ${request.toJson()}');
    
    final response = await _apiService.post('/salon/create-json', data: request.toJson());
    
    print('📥 Salon creation response: $response');
    
    if (response['data'] != null) {
      return SalonDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create salon: ${response['message'] ?? 'Unknown error'}');
  }

  // Update an existing salon
  Future<SalonDto> updateSalon(UpdateSalonRequest request) async {
    print('🏢 Updating salon with SalonService');
    print('📤 Request: ${request.toJson()}');
    
    final response = await _apiService.put('/salon/${request.id}', data: request.toJson());
    
    print('📥 Salon update response: $response');
    
    if (response['data'] != null) {
      return SalonDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update salon: ${response['message'] ?? 'Unknown error'}');
  }

  // Get salon by ID
  Future<SalonDto> getSalonById(int salonId) async {
    final response = await _apiService.get('/salon/$salonId');
    
    if (response['data'] != null) {
      return SalonDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get salon');
  }

  // Get current user's salons
  Future<List<SalonDto>> getMySalons() async {
    final response = await _apiService.get('/salon');
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((salon) => SalonDto.fromJson(salon))
          .toList();
    }
    
    return [];
  }

  // Delete specific images from a salon
  Future<Map<String, dynamic>> deleteSalonImages(int salonId, List<String> imageUrls) async {
    print('🗑️ Deleting ${imageUrls.length} images from salon $salonId');
    print('📤 Images to delete: $imageUrls');
    
    final response = await _apiService.delete('/salon/$salonId/images', data: imageUrls);
    
    print('📥 Image deletion response: $response');
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    throw Exception('Failed to delete images: ${response['message'] ?? 'Unknown error'}');
  }

  // Deactivate/Activate a salon
  Future<SalonDto> toggleSalonStatus(int salonId, bool isActive) async {
    print('🏢 ${isActive ? "Activating" : "Deactivating"} salon $salonId');
    
    // First get the current salon to preserve other data
    final currentSalon = await getSalonById(salonId);
    
    // Create update request with only the status change
    final updateRequest = UpdateSalonRequest(
      id: salonId,
      name: currentSalon.name,
      description: currentSalon.description,
      address: currentSalon.address,
      city: currentSalon.city,
      state: currentSalon.state,
      zipCode: currentSalon.zipCode,
      phoneNumber: currentSalon.phoneNumber,
      email: currentSalon.email,
      openingTime: "${currentSalon.openingTime}:00",
      closingTime: "${currentSalon.closingTime}:00",
      latitude: currentSalon.latitude,
      longitude: currentSalon.longitude,
      imageUrls: currentSalon.imageUrls,
      profilePictureUrl: currentSalon.profilePictureUrl,
      isActive: isActive,
    );
    
    return await updateSalon(updateRequest);
  }

  // Delete a salon permanently
  Future<void> deleteSalon(int salonId) async {
    print('🗑️ Permanently deleting salon $salonId');
    
    final response = await _apiService.delete('/salon/$salonId');
    
    print('📥 Salon deletion response: $response');
    
    if (response['success'] != true && response['data'] == null) {
      throw Exception('Failed to delete salon: ${response['message'] ?? 'Unknown error'}');
    }
  }
}