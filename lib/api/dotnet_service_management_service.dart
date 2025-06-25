import 'package:stibe_partner/api/api_service.dart';

class DotNetServiceManagementService {
  final ApiService _apiService = ApiService();

  // Add service to salon
  Future<Map<String, dynamic>> addService({
    required int salonId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    String? category,
    String? imageUrl,
  }) async {
    final response = await _apiService.post('/service', data: {
      'salonId': salonId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'imageUrl': imageUrl,
    });

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to add service');
  }

  // Get service by ID
  Future<Map<String, dynamic>> getService(int serviceId) async {
    final response = await _apiService.get('/service/$serviceId');

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to get service');
  }

  // Get all services for a salon
  Future<List<Map<String, dynamic>>> getSalonServices(int salonId) async {
    final response = await _apiService.get('/service/salon/$salonId');

    if (response['successful'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to get salon services');
  }

  // Update service
  Future<Map<String, dynamic>> updateService({
    required int serviceId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    String? imageUrl,
    bool? isActive,
  }) async {
    final Map<String, dynamic> data = {};
    
    // Only include fields that are not null
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (durationMinutes != null) data['durationMinutes'] = durationMinutes;
    if (category != null) data['category'] = category;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _apiService.put('/service/$serviceId', data: data);

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to update service');
  }

  // Delete service
  Future<bool> deleteService(int serviceId) async {
    final response = await _apiService.delete('/service/$serviceId');
    return response['successful'] == true;
  }

  // Assign service to staff
  Future<bool> assignServiceToStaff({
    required int serviceId,
    required int staffId,
  }) async {
    final response = await _apiService.post('/service/$serviceId/assign/$staffId', data: {});
    return response['successful'] == true;
  }

  // Remove service from staff
  Future<bool> removeServiceFromStaff({
    required int serviceId,
    required int staffId,
  }) async {
    final response = await _apiService.delete('/service/$serviceId/assign/$staffId');
    return response['successful'] == true;
  }

  // Get service categories
  Future<List<String>> getServiceCategories(int salonId) async {
    final response = await _apiService.get('/service/salon/$salonId/categories');

    if (response['successful'] == true && response['data'] != null) {
      return List<String>.from(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to get service categories');
  }
}
