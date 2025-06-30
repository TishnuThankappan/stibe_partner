import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/utils/image_utils.dart';

// Enhanced Service Management API with comprehensive features
class ComprehensiveServiceManagementService {
  final ApiService _apiService = ApiService();

  // ==================== SERVICE CATEGORIES ====================
  
  Future<List<ServiceCategoryDto>> getSalonCategories(int salonId) async {
    final response = await _apiService.get('/salon/$salonId/categories');
    return (response['data'] as List)
        .map((json) => ServiceCategoryDto.fromJson(json))
        .toList();
  }

  Future<ServiceCategoryDto> createServiceCategory(
    int salonId,
    CreateServiceCategoryRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/categories',
      data: request.toJson(),
    );
    return ServiceCategoryDto.fromJson(response['data']);
  }

  Future<ServiceCategoryDto> updateServiceCategory(
    int salonId,
    int categoryId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiService.put(
      '/salon/$salonId/categories/$categoryId',
      data: updates,
    );
    return ServiceCategoryDto.fromJson(response['data']);
  }

  Future<void> deleteServiceCategory(int salonId, int categoryId) async {
    await _apiService.delete('/salon/$salonId/categories/$categoryId');
  }

  // ==================== SERVICES ====================
  
  Future<List<ComprehensiveServiceDto>> getSalonServices(
    int salonId, {
    bool? isActive,
    int? categoryId,
    List<int>? staffIds,
    String? searchTerm,
    String? sortBy,
    bool includeStaff = false,
    bool includeAvailability = false,
    bool includeReviews = false,
    bool includeAnalytics = false,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (isActive != null) queryParams['isActive'] = isActive;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (staffIds != null && staffIds.isNotEmpty) {
      queryParams['staffIds'] = staffIds.join(',');
    }
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['search'] = searchTerm;
    }
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (includeStaff) queryParams['includeStaff'] = true;
    if (includeAvailability) queryParams['includeAvailability'] = true;
    if (includeReviews) queryParams['includeReviews'] = true;
    if (includeAnalytics) queryParams['includeAnalytics'] = true;

    final response = await _apiService.get(
      '/salon/$salonId/services',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => ComprehensiveServiceDto.fromJson(json))
        .toList();
  }

  Future<ComprehensiveServiceDto> createService(
    int salonId,
    CreateComprehensiveServiceRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services',
      data: request.toJson(),
    );
    return ComprehensiveServiceDto.fromJson(response['data']);
  }

  Future<ComprehensiveServiceDto> updateService(
    int salonId,
    int serviceId,
    UpdateServiceRequest request,
  ) async {
    final response = await _apiService.put(
      '/salon/$salonId/services/$serviceId',
      data: request.toJson(),
    );
    return ComprehensiveServiceDto.fromJson(response['data']);
  }

  Future<void> deleteService(int salonId, int serviceId) async {
    await _apiService.delete('/salon/$salonId/services/$serviceId');
  }

  Future<ComprehensiveServiceDto> duplicateService(
    int salonId,
    int serviceId,
    String newName,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/$serviceId/duplicate',
      data: {'name': newName},
    );
    return ComprehensiveServiceDto.fromJson(response['data']);
  }

  // ==================== SERVICE PACKAGES ====================
  
  Future<List<ServicePackageDto>> getServicePackages(int salonId) async {
    final response = await _apiService.get('/salon/$salonId/packages');
    return (response['data'] as List)
        .map((json) => ServicePackageDto.fromJson(json))
        .toList()
        .cast<ServicePackageDto>();
  }

  Future<ServicePackageDto> createServicePackage(
    int salonId,
    CreateServicePackageRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/packages',
      data: request.toJson(),
    );
    return ServicePackageDto.fromJson(response['data']);
  }

  Future<ServicePackageDto> updateServicePackage(
    int salonId,
    int packageId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiService.put(
      '/salon/$salonId/packages/$packageId',
      data: updates,
    );
    return ServicePackageDto.fromJson(response['data']);
  }

  Future<void> deleteServicePackage(int salonId, int packageId) async {
    await _apiService.delete('/salon/$salonId/packages/$packageId');
  }

  // ==================== STAFF-SERVICE ASSIGNMENTS ====================
  
  Future<List<StaffServiceAssignmentDto>> getStaffServiceAssignments(
    int salonId, {
    int? staffId,
    int? serviceId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (staffId != null) queryParams['staffId'] = staffId;
    if (serviceId != null) queryParams['serviceId'] = serviceId;

    final response = await _apiService.get(
      '/salon/$salonId/staff-service-assignments',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => StaffServiceAssignmentDto.fromJson(json))
        .toList()
        .cast<StaffServiceAssignmentDto>();
  }

  Future<StaffServiceAssignmentDto> assignStaffToService(
    int salonId,
    AssignStaffToServiceRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/staff-service-assignments',
      data: request.toJson(),
    );
    return StaffServiceAssignmentDto.fromJson(response['data']);
  }

  Future<void> removeStaffFromService(
    int salonId,
    int staffId,
    int serviceId,
  ) async {
    await _apiService.delete(
      '/salon/$salonId/staff-service-assignments/staff/$staffId/service/$serviceId',
    );
  }

  // ==================== SERVICE AVAILABILITY ====================
  
  Future<List<ServiceAvailabilityDto>> getServiceAvailability(
    int salonId,
    int serviceId,
  ) async {
    final response = await _apiService.get(
      '/salon/$salonId/services/$serviceId/availability',
    );
    return (response['data'] as List)
        .map((json) => ServiceAvailabilityDto.fromJson(json))
        .toList()
        .cast<ServiceAvailabilityDto>();
  }

  Future<ServiceAvailabilityDto> createServiceAvailability(
    int salonId,
    int serviceId,
    CreateServiceAvailabilityRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/$serviceId/availability',
      data: request.toJson(),
    );
    return ServiceAvailabilityDto.fromJson(response['data']);
  }

  Future<void> updateServiceAvailability(
    int salonId,
    int serviceId,
    int availabilityId,
    Map<String, dynamic> updates,
  ) async {
    await _apiService.put(
      '/salon/$salonId/services/$serviceId/availability/$availabilityId',
       data:updates,
    );
  }

  // ==================== PRICING & PROMOTIONS ====================
  
  Future<List<ServicePromotionDto>> getServicePromotions(
    int salonId, {
    int? serviceId,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{};
    if (serviceId != null) queryParams['serviceId'] = serviceId;
    if (isActive != null) queryParams['isActive'] = isActive;

    final response = await _apiService.get(
      '/salon/$salonId/promotions',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => ServicePromotionDto.fromJson(json))
        .toList()
        .cast<ServicePromotionDto>();
  }

  Future<ServicePromotionDto> createServicePromotion(
    int salonId,
    CreateServicePromotionRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/promotions',
      data: request.toJson(),
    );
    return ServicePromotionDto.fromJson(response['data']);
  }

  // ==================== ANALYTICS ====================
  
  Future<ServiceAnalyticsDto> getServiceAnalytics(
    int salonId, {
    int? serviceId,
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    final queryParams = <String, dynamic>{
      'groupBy': groupBy,
    };
    
    if (serviceId != null) queryParams['serviceId'] = serviceId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final response = await _apiService.get(
      '/salon/$salonId/analytics/services',
      queryParams: queryParams,
    );
    return ServiceAnalyticsDto.fromJson(response['data']);
  }

  Future<List<ServicePerformanceDto>> getTopPerformingServices(
    int salonId, {
    int limit = 10,
    String metric = 'revenue',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'metric': metric,
    };
    
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final response = await _apiService.get(
      '/salon/$salonId/analytics/services/top-performing',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => ServicePerformanceDto.fromJson(json))
        .toList()
        .cast<ServicePerformanceDto>();
  }

  // ==================== REVIEWS & RATINGS ====================
  
  Future<List<ServiceReviewDto>> getServiceReviews(
    int salonId,
    int serviceId, {
    int page = 1,
    int limit = 20,
    double? minRating,
    bool includeResponses = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (minRating != null) queryParams['minRating'] = minRating;
    if (includeResponses) queryParams['includeResponses'] = true;

    final response = await _apiService.get(
      '/salon/$salonId/services/$serviceId/reviews',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => ServiceReviewDto.fromJson(json))
        .toList()
        .cast<ServiceReviewDto>();
  }

  Future<ServiceReviewSummaryDto> getServiceReviewSummary(
    int salonId,
    int serviceId,
  ) async {
    final response = await _apiService.get(
      '/salon/$salonId/services/$serviceId/reviews/summary',
    );
    return ServiceReviewSummaryDto.fromJson(response['data']);
  }

  // ==================== BULK OPERATIONS ====================
  
  Future<BulkOperationResultDto> bulkUpdateServices(
    int salonId,
    BulkServiceUpdateRequest request,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/bulk-update',
     data: request.toJson(),
    );
    return BulkOperationResultDto.fromJson(response['data']);
  }

  Future<BulkOperationResultDto> bulkDeleteServices(
    int salonId,
    List<int> serviceIds,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/bulk-delete',
      data: {'serviceIds': serviceIds},
    );
    return BulkOperationResultDto.fromJson(response['data']);
  }

  // ==================== SERVICE TEMPLATES ====================
  
  Future<List<ServiceTemplateDto>> getServiceTemplates({
    String? category,
    String? industryType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (industryType != null) queryParams['industryType'] = industryType;

    final response = await _apiService.get(
      '/service-templates',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => ServiceTemplateDto.fromJson(json))
        .toList()
        .cast<ServiceTemplateDto>();
  }

  Future<ComprehensiveServiceDto> createServiceFromTemplate(
    int salonId,
    int templateId,
    Map<String, dynamic>? customizations,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/from-template/$templateId',
      data: customizations ?? {},
    );
    return ComprehensiveServiceDto.fromJson(response['data']);
  }

  // ==================== EXPORT & IMPORT ====================
  
  Future<ExportResultDto> exportServices(
    int salonId, {
    String format = 'csv',
    List<int>? serviceIds,
    bool includeAnalytics = false,
  }) async {
    final queryParams = <String, dynamic>{
      'format': format,
    };
    
    if (serviceIds != null && serviceIds.isNotEmpty) {
      queryParams['serviceIds'] = serviceIds.join(',');
    }
    if (includeAnalytics) queryParams['includeAnalytics'] = true;

    final response = await _apiService.get(
      '/salon/$salonId/services/export',
      queryParams: queryParams,
    );
    return ExportResultDto.fromJson(response['data']);
  }

  Future<ImportResultDto> importServices(
    int salonId,
    String fileUrl,
    String format,
  ) async {
    final response = await _apiService.post(
      '/salon/$salonId/services/import',
      data: {
        'fileUrl': fileUrl,
        'format': format,
      },
    );
    return ImportResultDto.fromJson(response['data']);
  }
}

// ==================== ENHANCED DTOs ====================

class ServiceCategoryDto {
  final int id;
  final String name;
  final String description;
  final String? iconUrl;
  final String? color;
  final int salonId;
  final int? parentCategoryId;
  final bool isActive;
  final int serviceCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.color,
    required this.salonId,
    this.parentCategoryId,
    required this.isActive,
    required this.serviceCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] != null ? ImageUtils.getFullImageUrl(json['iconUrl']) : null,
      color: json['color'],
      salonId: json['salonId'],
      parentCategoryId: json['parentCategoryId'],
      isActive: json['isActive'] ?? true,
      serviceCount: json['serviceCount'] ?? 0,
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
      'color': color,
      'salonId': salonId,
      'parentCategoryId': parentCategoryId,
      'isActive': isActive,
      'serviceCount': serviceCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ComprehensiveServiceDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final bool isActive;
  final int salonId;
  final String salonName;
  final String? imageUrl;
  final List<String> imageUrls;
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
  final int reviewCount;
  final List<StaffServiceAssignmentDto> staffAssignments;
  final List<ServiceAvailabilityDto> availabilities;
  final ServiceAnalyticsDto? analytics;
  final ServiceReviewSummaryDto? reviewSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComprehensiveServiceDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    required this.isActive,
    required this.salonId,
    required this.salonName,
    this.imageUrl,
    this.imageUrls = const [],
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
    required this.reviewCount,
    this.staffAssignments = const [],
    this.availabilities = const [],
    this.analytics,
    this.reviewSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComprehensiveServiceDto.fromJson(Map<String, dynamic> json) {
    return ComprehensiveServiceDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationInMinutes: json['durationInMinutes'] ?? 30,
      isActive: json['isActive'] ?? true,
      salonId: json['salonId'],
      salonName: json['salonName'] ?? '',
      imageUrl: json['imageUrl'] != null ? ImageUtils.getFullImageUrl(json['imageUrl']) : null,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']).map((url) => ImageUtils.getFullImageUrl(url)).toList()
          : [],
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
      reviewCount: json['reviewCount'] ?? 0,
      staffAssignments: json['staffAssignments'] != null
          ? (json['staffAssignments'] as List).map((x) => StaffServiceAssignmentDto.fromJson(x)).toList().cast<StaffServiceAssignmentDto>()
          : [],
      availabilities: json['availabilities'] != null
          ? (json['availabilities'] as List).map((x) => ServiceAvailabilityDto.fromJson(x)).toList().cast<ServiceAvailabilityDto>()
          : [],
      analytics: json['analytics'] != null ? ServiceAnalyticsDto.fromJson(json['analytics']) : null,
      reviewSummary: json['reviewSummary'] != null ? ServiceReviewSummaryDto.fromJson(json['reviewSummary']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convenience getters
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration => '${durationInMinutes}min';
  String get priceWithDiscount => discountPercentage != null 
      ? '\$${(price * (1 - discountPercentage! / 100)).toStringAsFixed(2)}'
      : formattedPrice;

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
      'imageUrls': imageUrls,
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
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Additional DTOs would be defined here for:
// - ServicePackageDto
// - StaffServiceAssignmentDto  
// - ServiceAvailabilityDto
// - ServicePromotionDto
// - ServiceAnalyticsDto
// - ServicePerformanceDto
// - ServiceReviewDto
// - ServiceReviewSummaryDto
// - ServiceTemplateDto
// - BulkOperationResultDto
// - ExportResultDto
// - ImportResultDto
// - Various request DTOs

// ==================== REQUEST DTOs ====================

class CreateServiceCategoryRequest {
  final String name;
  final String description;
  final String? iconUrl;
  final String? color;
  final int? parentCategoryId;

  CreateServiceCategoryRequest({
    required this.name,
    required this.description,
    this.iconUrl,
    this.color,
    this.parentCategoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'color': color,
      'parentCategoryId': parentCategoryId,
    };
  }
}

class CreateComprehensiveServiceRequest {
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final String? imageUrl;
  final List<String> imageUrls;
  final int? categoryId;
  final int maxConcurrentBookings;
  final bool requiresStaffAssignment;
  final int bufferTimeBeforeMinutes;
  final int bufferTimeAfterMinutes;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final List<int> staffIds;
  final List<CreateServiceAvailabilityRequest> availabilities;

  CreateComprehensiveServiceRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    this.imageUrl,
    this.imageUrls = const [],
    this.categoryId,
    this.maxConcurrentBookings = 1,
    this.requiresStaffAssignment = true,
    this.bufferTimeBeforeMinutes = 0,
    this.bufferTimeAfterMinutes = 0,
    this.tags = const [],
    this.metadata,
    this.staffIds = const [],
    this.availabilities = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'durationInMinutes': durationInMinutes,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'maxConcurrentBookings': maxConcurrentBookings,
      'requiresStaffAssignment': requiresStaffAssignment,
      'bufferTimeBeforeMinutes': bufferTimeBeforeMinutes,
      'bufferTimeAfterMinutes': bufferTimeAfterMinutes,
      'tags': tags,
      'metadata': metadata,
      'staffIds': staffIds,
      'availabilities': availabilities.map((a) => a.toJson()).toList(),
    };
  }
}

// Placeholder classes for additional DTOs that would be fully implemented
class ServicePackageDto {
  static fromJson(json) => ServicePackageDto();
}

class StaffServiceAssignmentDto {
  static fromJson(json) => StaffServiceAssignmentDto();
}

class ServiceAvailabilityDto {
  static fromJson(json) => ServiceAvailabilityDto();
}

class ServicePromotionDto {
  static fromJson(json) => ServicePromotionDto();
}

class ServiceAnalyticsDto {
  static fromJson(json) => ServiceAnalyticsDto();
}

class ServicePerformanceDto {
  static fromJson(json) => ServicePerformanceDto();
}

class ServiceReviewDto {
  static fromJson(json) => ServiceReviewDto();
}

class ServiceReviewSummaryDto {
  static fromJson(json) => ServiceReviewSummaryDto();
}

class ServiceTemplateDto {
  static fromJson(json) => ServiceTemplateDto();
}

class BulkOperationResultDto {
  static fromJson(json) => BulkOperationResultDto();
}

class ExportResultDto {
  static fromJson(json) => ExportResultDto();
}

class ImportResultDto {
  static fromJson(json) => ImportResultDto();
}

// Additional request DTOs
class UpdateServiceRequest {
  Map<String, dynamic> toJson() => {};
}

class CreateServicePackageRequest {
  Map<String, dynamic> toJson() => {};
}

class AssignStaffToServiceRequest {
  Map<String, dynamic> toJson() => {};
}

class CreateServiceAvailabilityRequest {
  Map<String, dynamic> toJson() => {};
}

class CreateServicePromotionRequest {
  Map<String, dynamic> toJson() => {};
}

class BulkServiceUpdateRequest {
  Map<String, dynamic> toJson() => {};
}
