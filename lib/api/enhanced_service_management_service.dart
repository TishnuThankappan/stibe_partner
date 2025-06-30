import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/utils/image_utils.dart';

// Service Category DTO
class ServiceCategoryDto {
  final int id;
  final String name;
  final String description;
  final String? iconUrl;
  final int salonId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.salonId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] != null ? ImageUtils.getFullImageUrl(json['iconUrl']) : null,
      salonId: json['salonId'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'salonId': salonId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Enhanced Service DTO
class ServiceDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final bool isActive;
  final int salonId;
  final String salonName;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final int maxConcurrentBookings;
  final bool requiresStaffAssignment;
  final int bufferTimeBeforeMinutes;
  final int bufferTimeAfterMinutes;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final double? discountPercentage;
  final bool isPopular;
  final int bookingCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    required this.isActive,
    required this.salonId,
    required this.salonName,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.maxConcurrentBookings,
    required this.requiresStaffAssignment,
    required this.bufferTimeBeforeMinutes,
    required this.bufferTimeAfterMinutes,
    this.tags = const [],
    this.metadata,
    this.discountPercentage,
    required this.isPopular,
    required this.bookingCount,
    required this.averageRating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationInMinutes: json['durationInMinutes'] ?? 30,
      isActive: json['isActive'] ?? true,
      salonId: json['salonId'],
      salonName: json['salonName'] ?? '',
      imageUrl: json['imageUrl'] != null ? ImageUtils.getFullImageUrl(json['imageUrl']) : null,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      maxConcurrentBookings: json['maxConcurrentBookings'] ?? 1,
      requiresStaffAssignment: json['requiresStaffAssignment'] ?? true,
      bufferTimeBeforeMinutes: json['bufferTimeBeforeMinutes'] ?? 0,
      bufferTimeAfterMinutes: json['bufferTimeAfterMinutes'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      metadata: json['metadata'],
      discountPercentage: json['discountPercentage']?.toDouble(),
      isPopular: json['isPopular'] ?? false,
      bookingCount: json['bookingCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationInMinutes': durationInMinutes,
      'isActive': isActive,
      'salonId': salonId,
      'salonName': salonName,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'maxConcurrentBookings': maxConcurrentBookings,
      'requiresStaffAssignment': requiresStaffAssignment,
      'bufferTimeBeforeMinutes': bufferTimeBeforeMinutes,
      'bufferTimeAfterMinutes': bufferTimeAfterMinutes,
      'tags': tags,
      'metadata': metadata,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
      'bookingCount': bookingCount,
      'averageRating': averageRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration {
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
  String get priceWithDiscount {
    if (discountPercentage != null && discountPercentage! > 0) {
      final discountedPrice = price * (1 - discountPercentage! / 100);
      return '\$${discountedPrice.toStringAsFixed(2)}';
    }
    return formattedPrice;
  }
}

// Service Package DTO
class ServicePackageDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int totalDurationMinutes;
  final List<ServiceDto> services;
  final String? imageUrl;
  final bool isActive;
  final int salonId;
  final double? discountPercentage;
  final bool isPopular;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePackageDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.totalDurationMinutes,
    required this.services,
    this.imageUrl,
    required this.isActive,
    required this.salonId,
    this.discountPercentage,
    required this.isPopular,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePackageDto.fromJson(Map<String, dynamic> json) {
    return ServicePackageDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalDurationMinutes: json['totalDurationMinutes'] ?? 0,
      services: json['services'] != null 
          ? (json['services'] as List).map((s) => ServiceDto.fromJson(s)).toList()
          : [],
      imageUrl: json['imageUrl'] != null ? ImageUtils.getFullImageUrl(json['imageUrl']) : null,
      isActive: json['isActive'] ?? true,
      salonId: json['salonId'],
      discountPercentage: json['discountPercentage']?.toDouble(),
      isPopular: json['isPopular'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
  double get totalOriginalPrice => services.fold(0, (sum, service) => sum + service.price);
  double get savings => totalOriginalPrice - price;
  String get savingsFormatted => '\$${savings.toStringAsFixed(2)}';
}

// Request DTOs
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
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final double? discountPercentage;
  final bool isPopular;

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
    this.tags = const [],
    this.metadata,
    this.discountPercentage,
    this.isPopular = false,
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
      'tags': tags,
      'metadata': metadata,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
    };
  }
}

class UpdateServiceRequest {
  final int id;
  final String? name;
  final String? description;
  final double? price;
  final int? durationInMinutes;
  final bool? isActive;
  final String? imageUrl;
  final int? categoryId;
  final int? maxConcurrentBookings;
  final bool? requiresStaffAssignment;
  final int? bufferTimeBeforeMinutes;
  final int? bufferTimeAfterMinutes;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final double? discountPercentage;
  final bool? isPopular;

  UpdateServiceRequest({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.durationInMinutes,
    this.isActive,
    this.imageUrl,
    this.categoryId,
    this.maxConcurrentBookings,
    this.requiresStaffAssignment,
    this.bufferTimeBeforeMinutes,
    this.bufferTimeAfterMinutes,
    this.tags,
    this.metadata,
    this.discountPercentage,
    this.isPopular,
  });

  Map<String, dynamic> toJson() {
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
    if (tags != null) data['tags'] = tags;
    if (metadata != null) data['metadata'] = metadata;
    if (discountPercentage != null) data['discountPercentage'] = discountPercentage;
    if (isPopular != null) data['isPopular'] = isPopular;
    return data;
  }
}

// Service Category Request DTOs
class CreateServiceCategoryRequest {
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;

  CreateServiceCategoryRequest({
    required this.name,
    required this.description,
    this.iconUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'isActive': isActive,
    };
  }
}

class UpdateServiceCategoryRequest {
  final int id;
  final String? name;
  final String? description;
  final String? iconUrl;
  final bool? isActive;

  UpdateServiceCategoryRequest({
    required this.id,
    this.name,
    this.description,
    this.iconUrl,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (iconUrl != null) data['iconUrl'] = iconUrl;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

// Service Package Request DTOs
class CreateServicePackageRequest {
  final String name;
  final String description;
  final double price;
  final List<int> serviceIds;
  final String? imageUrl;
  final double? discountPercentage;
  final bool isActive;

  CreateServicePackageRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.serviceIds,
    this.imageUrl,
    this.discountPercentage,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'serviceIds': serviceIds,
      'imageUrl': imageUrl,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
    };
  }
}

class UpdateServicePackageRequest {
  final int id;
  final String? name;
  final String? description;
  final double? price;
  final List<int>? serviceIds;
  final String? imageUrl;
  final double? discountPercentage;
  final bool? isActive;

  UpdateServicePackageRequest({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.serviceIds,
    this.imageUrl,
    this.discountPercentage,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (serviceIds != null) data['serviceIds'] = serviceIds;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (discountPercentage != null) data['discountPercentage'] = discountPercentage;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

// Comprehensive Service Management Service
class ServiceManagementService {
  final ApiService _apiService = ApiService();

  // ===================== SERVICES =====================

  // Get all services for a salon
  Future<List<ServiceDto>> getSalonServices(int salonId, {
    bool? isActive,
    int? categoryId,
    String? searchTerm,
    String? sortBy, // 'name', 'price', 'duration', 'popularity', 'rating'
    bool? ascending,
  }) async {
    print('🔧 Getting services for salon $salonId');
    
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['isActive'] = isActive;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (searchTerm != null && searchTerm.isNotEmpty) queryParams['search'] = searchTerm;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (ascending != null) queryParams['ascending'] = ascending;
    
    final response = await _apiService.get('/salon/$salonId/service', queryParams: queryParams);
    
    print('📥 Services response: $response');
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((service) => ServiceDto.fromJson(service))
          .toList();
    }
    
    return [];
  }

  // Get popular services
  Future<List<ServiceDto>> getPopularServices(int salonId) async {
    return getSalonServices(salonId, sortBy: 'popularity', ascending: false);
  }

  // Get service by ID
  Future<ServiceDto> getServiceById(int salonId, int serviceId) async {
    print('🔧 Getting service $serviceId for salon $salonId');
    
    final response = await _apiService.get('/salon/$salonId/service/$serviceId');
    
    if (response['data'] != null) {
      return ServiceDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get service');
  }

  // Create new service
  Future<ServiceDto> createService(int salonId, CreateServiceRequest request) async {
    print('🔧 Creating service for salon $salonId');
    print('📤 Request: ${request.toJson()}');
    
    final response = await _apiService.post('/salon/$salonId/service', data: request.toJson());
    
    print('📥 Service creation response: $response');
    
    if (response['data'] != null) {
      return ServiceDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create service: ${response['message'] ?? 'Unknown error'}');
  }

  // Update service
  Future<ServiceDto> updateService(int salonId, UpdateServiceRequest request) async {
    print('🔧 Updating service ${request.id} for salon $salonId');
    print('📤 Request: ${request.toJson()}');
    
    final response = await _apiService.put('/salon/$salonId/service/${request.id}', data: request.toJson());
    
    print('📥 Service update response: $response');
    
    if (response['data'] != null) {
      return ServiceDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update service: ${response['message'] ?? 'Unknown error'}');
  }

  // Toggle service status
  Future<ServiceDto> toggleServiceStatus(int salonId, int serviceId, bool isActive) async {
    print('🔧 ${isActive ? "Activating" : "Deactivating"} service $serviceId');
    
    final request = UpdateServiceRequest(id: serviceId, isActive: isActive);
    return await updateService(salonId, request);
  }

  // Delete service
  Future<void> deleteService(int salonId, int serviceId) async {
    print('🗑️ Deleting service $serviceId from salon $salonId');
    
    final response = await _apiService.delete('/salon/$salonId/service/$serviceId');
    
    print('📥 Service deletion response: $response');
    
    if (response['success'] != true && response['data'] == null) {
      throw Exception('Failed to delete service: ${response['message'] ?? 'Unknown error'}');
    }
  }

  // Duplicate service
  Future<ServiceDto> duplicateService(int salonId, int serviceId, String newName) async {
    print('🔧 Duplicating service $serviceId');
    
    // Get the original service
    final originalService = await getServiceById(salonId, serviceId);
    
    // Create a copy with new name
    final request = CreateServiceRequest(
      name: newName,
      description: originalService.description,
      price: originalService.price,
      durationInMinutes: originalService.durationInMinutes,
      imageUrl: originalService.imageUrl,
      categoryId: originalService.categoryId,
      maxConcurrentBookings: originalService.maxConcurrentBookings,
      requiresStaffAssignment: originalService.requiresStaffAssignment,
      bufferTimeBeforeMinutes: originalService.bufferTimeBeforeMinutes,
      bufferTimeAfterMinutes: originalService.bufferTimeAfterMinutes,
      tags: originalService.tags,
      metadata: originalService.metadata,
      discountPercentage: originalService.discountPercentage,
      isPopular: false, // New service shouldn't be popular by default
    );
    
    return await createService(salonId, request);
  }

  // ===================== SERVICE CATEGORIES =====================

  // Get all categories for a salon
  Future<List<ServiceCategoryDto>> getSalonCategories(int salonId, {bool? isActive}) async {
    print('🔧 Getting categories for salon $salonId');
    
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['isActive'] = isActive;
    
    final response = await _apiService.get('/salon/$salonId/service-category', queryParams: queryParams);
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((category) => ServiceCategoryDto.fromJson(category))
          .toList();
    }
    
    return [];
  }

  // Create service category
  Future<ServiceCategoryDto> createServiceCategory(int salonId, CreateServiceCategoryRequest request) async {
    print('🔧 Creating service category for salon $salonId');
    
    final response = await _apiService.post('/salon/$salonId/service-category', data: request.toJson());
    
    if (response['data'] != null) {
      return ServiceCategoryDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create service category: ${response['message'] ?? 'Unknown error'}');
  }

  // Update service category
  Future<ServiceCategoryDto> updateServiceCategory(int salonId, int categoryId, Map<String, dynamic> updates) async {
    final response = await _apiService.put('/salon/$salonId/service-category/$categoryId', data: updates);
    
    if (response['data'] != null) {
      return ServiceCategoryDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update service category');
  }

  // Delete service category
  Future<void> deleteServiceCategory(int salonId, int categoryId) async {
    await _apiService.delete('/salon/$salonId/service-category/$categoryId');
  }

  // ===================== SERVICE PACKAGES =====================

  // Get service packages
  Future<List<ServicePackageDto>> getServicePackages(int salonId, {bool? isActive}) async {
    print('🔧 Getting service packages for salon $salonId');
    
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['isActive'] = isActive;
    
    final response = await _apiService.get('/salon/$salonId/service-package', queryParams: queryParams);
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((package) => ServicePackageDto.fromJson(package))
          .toList();
    }
    
    return [];
  }

  // Create service package
  Future<ServicePackageDto> createServicePackage(int salonId, CreateServicePackageRequest request) async {
    print('🔧 Creating service package for salon $salonId');
    
    final response = await _apiService.post('/salon/$salonId/service-package', data: request.toJson());
    
    if (response['data'] != null) {
      return ServicePackageDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create service package: ${response['message'] ?? 'Unknown error'}');
  }

  // Update service package
  Future<ServicePackageDto> updateServicePackage(int salonId, int packageId, Map<String, dynamic> updates) async {
    final response = await _apiService.put('/salon/$salonId/service-package/$packageId', data: updates);
    
    if (response['data'] != null) {
      return ServicePackageDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update service package');
  }

  // Delete service package
  Future<void> deleteServicePackage(int salonId, int packageId) async {
    await _apiService.delete('/salon/$salonId/service-package/$packageId');
  }

  // Get service package by ID
  Future<ServicePackageDto> getServicePackageById(int salonId, int packageId) async {
    final response = await _apiService.get('/salon/$salonId/service-package/$packageId');
    
    if (response['data'] != null) {
      return ServicePackageDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get service package');
  }

  // ===================== ANALYTICS =====================

  // Get service analytics
  Future<Map<String, dynamic>> getServiceAnalytics(int salonId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('🔧 Getting service analytics for salon $salonId');
    
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    
    final response = await _apiService.get('/salon/$salonId/service/analytics', queryParams: queryParams);
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    return {};
  }

  // Get top performing services
  Future<List<ServiceDto>> getTopPerformingServices(int salonId, {int limit = 10}) async {
    final analytics = await getServiceAnalytics(salonId);
    final topServiceIds = analytics['topServices'] as List<int>? ?? [];
    
    if (topServiceIds.isEmpty) return [];
    
    // Fetch detailed service information
    final services = <ServiceDto>[];
    for (final serviceId in topServiceIds.take(limit)) {
      try {
        final service = await getServiceById(salonId, serviceId);
        services.add(service);
      } catch (e) {
        print('Error fetching service $serviceId: $e');
      }
    }
    
    return services;
  }

}
