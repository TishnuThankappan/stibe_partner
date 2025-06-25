import 'package:stibe_partner/api/api_service.dart';

class DotNetSalonService {
  final ApiService _apiService = ApiService();

  // Create a new salon
  Future<Map<String, dynamic>> createSalon({
    required String name,
    required String description,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    required String phoneNumber,
    required String email,
    String? website,
    String? logoUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.post('/salon', data: {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
    });

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to create salon');
  }

  // Get salon by ID
  Future<Map<String, dynamic>> getSalon(int salonId) async {
    final response = await _apiService.get('/salon/$salonId');

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to get salon');
  }

  // Get salons for the current user
  Future<List<Map<String, dynamic>>> getMySalons() async {
    final response = await _apiService.get('/salon/mysalons');

    if (response['successful'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to get salons');
  }

  // Update salon
  Future<Map<String, dynamic>> updateSalon({
    required int salonId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> data = {};
    
    // Only include fields that are not null
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (zipCode != null) data['zipCode'] = zipCode;
    if (country != null) data['country'] = country;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (email != null) data['email'] = email;
    if (website != null) data['website'] = website;
    if (logoUrl != null) data['logoUrl'] = logoUrl;
    if (images != null) data['images'] = images;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    final response = await _apiService.put('/salon/$salonId', data: data);

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to update salon');
  }

  // Delete salon
  Future<bool> deleteSalon(int salonId) async {
    final response = await _apiService.delete('/salon/$salonId');
    return response['successful'] == true;
  }
}
