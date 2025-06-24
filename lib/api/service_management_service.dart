import 'package:stibe_partner/api/api_service.dart';

class CreateServiceRequest {
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final String? imageUrl;
  final int? categoryId;
  final int maxConcurrentBookings;
  final bool requiresStaffAssignment;
  final int bufferTimeBeforeMinutes;
  final int bufferTimeAfterMinutes;

  CreateServiceRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    this.imageUrl,
    this.categoryId,
    this.maxConcurrentBookings = 1,
    this.requiresStaffAssignment = true,
    this.bufferTimeBeforeMinutes = 0,
    this.bufferTimeAfterMinutes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'durationInMinutes': durationInMinutes,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'maxConcurrentBookings': maxConcurrentBookings,
      'requiresStaffAssignment': requiresStaffAssignment,
      'bufferTimeBeforeMinutes': bufferTimeBeforeMinutes,
      'bufferTimeAfterMinutes': bufferTimeAfterMinutes,
    };
  }
}

class ServiceResponseDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final bool isActive;
  final int salonId;
  final String salonName;
  final String imageUrl;
  final int? categoryId;
  final String? categoryName;
  final int maxConcurrentBookings;
  final bool requiresStaffAssignment;
  final int bufferTimeBeforeMinutes;
  final int bufferTimeAfterMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    required this.isActive,
    required this.salonId,
    required this.salonName,
    required this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.maxConcurrentBookings,
    required this.requiresStaffAssignment,
    required this.bufferTimeBeforeMinutes,
    required this.bufferTimeAfterMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceResponseDto.fromJson(Map<String, dynamic> json) {
    return ServiceResponseDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationInMinutes: json['durationInMinutes'] ?? 30,
      isActive: json['isActive'] ?? true,
      salonId: json['salonId'],
      salonName: json['salonName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      maxConcurrentBookings: json['maxConcurrentBookings'] ?? 1,
      requiresStaffAssignment: json['requiresStaffAssignment'] ?? true,
      bufferTimeBeforeMinutes: json['bufferTimeBeforeMinutes'] ?? 0,
      bufferTimeAfterMinutes: json['bufferTimeAfterMinutes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ServiceManagementService {
  final ApiService _apiService = ApiService();

  // Get all services for a salon
  Future<List<ServiceResponseDto>> getSalonServices(int salonId) async {
    print('🔧 Getting services for salon $salonId');
    
    final response = await _apiService.get('/salon/$salonId/service');
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((service) => ServiceResponseDto.fromJson(service))
          .toList();
    }
    
    return [];
  }

  // Add new service to a salon
  Future<ServiceResponseDto> createService({
    required int salonId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    String? imageUrl,
    int? categoryId,
    int maxConcurrentBookings = 1,
    bool requiresStaffAssignment = true,
    int bufferTimeBeforeMinutes = 0,
    int bufferTimeAfterMinutes = 0,
  }) async {
    print('🔧 Creating service for salon $salonId');
    
    final request = CreateServiceRequest(
      name: name,
      description: description,
      price: price,
      durationInMinutes: durationMinutes,
      imageUrl: imageUrl,
      categoryId: categoryId,
      maxConcurrentBookings: maxConcurrentBookings,
      requiresStaffAssignment: requiresStaffAssignment,
      bufferTimeBeforeMinutes: bufferTimeBeforeMinutes,
      bufferTimeAfterMinutes: bufferTimeAfterMinutes,
    );

    print('📤 Service data: ${request.toJson()}');

    final response = await _apiService.post('/salon/$salonId/service', data: request.toJson());
    
    if (response['data'] != null) {
      return ServiceResponseDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create service: ${response['message'] ?? 'Unknown error'}');
  }

  // Get service details
  Future<ServiceResponseDto> getService(int salonId, int serviceId) async {
    final response = await _apiService.get('/salon/$salonId/service/$serviceId');
    
    if (response['data'] != null) {
      return ServiceResponseDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get service');
  }

  // Update service
  Future<ServiceResponseDto> updateService({
    required int salonId,
    required int serviceId,
    String? name,
    String? description,
    double? price,
    int? durationInMinutes,
    bool? isActive,
    String? imageUrl,
    int? categoryId,
    int? maxConcurrentBookings,
    bool? requiresStaffAssignment,
    int? bufferTimeBeforeMinutes,
    int? bufferTimeAfterMinutes,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (durationInMinutes != null) data['durationInMinutes'] = durationInMinutes;
    if (isActive != null) data['isActive'] = isActive;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (maxConcurrentBookings != null) data['maxConcurrentBookings'] = maxConcurrentBookings;
    if (requiresStaffAssignment != null) data['requiresStaffAssignment'] = requiresStaffAssignment;
    if (bufferTimeBeforeMinutes != null) data['bufferTimeBeforeMinutes'] = bufferTimeBeforeMinutes;
    if (bufferTimeAfterMinutes != null) data['bufferTimeAfterMinutes'] = bufferTimeAfterMinutes;

    final response = await _apiService.put('/salon/$salonId/service/$serviceId', data: data);
    
    if (response['data'] != null) {
      return ServiceResponseDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update service');
  }

  // Delete service
  Future<bool> deleteService(int salonId, int serviceId) async {
    try {
      await _apiService.delete('/salon/$salonId/service/$serviceId');
      return true;
    } catch (e) {
      return false;
    }  }
}
