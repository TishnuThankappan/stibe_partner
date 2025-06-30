import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/utils/image_utils.dart';
import 'service_management_dtos.dart';
import 'service_management_requests.dart';

// ==================== COMPREHENSIVE SERVICE MANAGEMENT API ====================
class SalonServiceManagementApi {
  final ApiService _apiService = ApiService();

  // ==================== SERVICE CATEGORIES ====================
  
  /// Get all service categories for a salon with enhanced metadata
  Future<List<ServiceCategoryDto>> getServiceCategories(
    int salonId, {
    bool includeInactive = false,
    bool includeServiceCount = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'includeInactive': includeInactive,
        'includeServiceCount': includeServiceCount,
      };

      final response = await _apiService.get(
        '/salon/$salonId/service-categories',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServiceCategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service categories: ${e.toString()}');
    }
  }

  /// Create a new service category with validation
  Future<ServiceCategoryDto> createServiceCategory(
    int salonId,
    CreateServiceCategoryRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/service-categories',
        data: request.toJson(),
      );

      return ServiceCategoryDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create service category: ${e.toString()}');
    }
  }

  /// Update an existing service category
  Future<ServiceCategoryDto> updateServiceCategory(
    int salonId,
    int categoryId,
    UpdateServiceCategoryRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/service-categories/$categoryId',
        data: request.toJson(),
      );

      return ServiceCategoryDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update service category: ${e.toString()}');
    }
  }

  /// Delete a service category (with safety checks)
  Future<void> deleteServiceCategory(int salonId, int categoryId) async {
    try {
      await _apiService.delete('/salon/$salonId/service-categories/$categoryId');
    } catch (e) {
      throw Exception('Failed to delete service category: ${e.toString()}');
    }
  }

  // ==================== SERVICES ====================
  
  /// Get salon services with comprehensive filtering and sorting
  Future<List<EnhancedServiceDto>> getServices(
    int salonId, {
    bool? isActive,
    int? categoryId,
    List<int>? staffIds,
    String? searchTerm,
    String sortBy = 'name',
    bool ascending = true,
    int? limit,
    int? offset,
    bool includeAnalytics = false,
    bool includeAvailability = false,
    bool includeStaffAssignments = false,
    bool includePromotions = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'ascending': ascending,
        'includeAnalytics': includeAnalytics,
        'includeAvailability': includeAvailability,
        'includeStaffAssignments': includeStaffAssignments,
        'includePromotions': includePromotions,
      };

      if (isActive != null) queryParams['isActive'] = isActive;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (staffIds != null && staffIds.isNotEmpty) {
        queryParams['staffIds'] = staffIds.join(',');
      }
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
      }
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '/salon/$salonId/services',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => EnhancedServiceDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: ${e.toString()}');
    }
  }

  /// Get a single service by ID with full details
  Future<EnhancedServiceDto> getServiceById(
    int salonId,
    int serviceId, {
    bool includeAll = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'includeAnalytics': includeAll,
        'includeAvailability': includeAll,
        'includeStaffAssignments': includeAll,
        'includePromotions': includeAll,
        'includeReviews': includeAll,
      };

      final response = await _apiService.get(
        '/salon/$salonId/services/$serviceId',
        queryParams: queryParams,
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch service: ${e.toString()}');
    }
  }

  /// Create a new service with comprehensive options
  Future<EnhancedServiceDto> createService(
    int salonId,
    CreateServiceRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services',
        data: request.toJson(),
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  /// Update an existing service
  Future<EnhancedServiceDto> updateService(
    int salonId,
    int serviceId,
    UpdateServiceRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/services/$serviceId',
        data: request.toJson(),
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  /// Toggle service active status
  Future<EnhancedServiceDto> toggleServiceStatus(
    int salonId,
    int serviceId,
    bool isActive,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/services/$serviceId/status',
        data: {'isActive': isActive},
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to toggle service status: ${e.toString()}');
    }
  }

  /// Duplicate an existing service
  Future<EnhancedServiceDto> duplicateService(
    int salonId,
    int serviceId,
    String newName,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/$serviceId/duplicate',
        data: {'newName': newName},
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to duplicate service: ${e.toString()}');
    }
  }

  /// Delete a service
  Future<void> deleteService(int salonId, int serviceId) async {
    try {
      await _apiService.delete('/salon/$salonId/services/$serviceId');
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }

  // ==================== SERVICE PACKAGES ====================
  
  /// Get service packages for a salon
  Future<List<ServicePackageDto>> getServicePackages(
    int salonId, {
    bool? isActive,
    String? searchTerm,
    String sortBy = 'name',
    bool includeServices = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'includeServices': includeServices,
      };

      if (isActive != null) queryParams['isActive'] = isActive;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
      }

      final response = await _apiService.get(
        '/salon/$salonId/service-packages',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServicePackageDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service packages: ${e.toString()}');
    }
  }

  /// Create a new service package
  Future<ServicePackageDto> createServicePackage(
    int salonId,
    CreateServicePackageRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/service-packages',
        data: request.toJson(),
      );

      return ServicePackageDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create service package: ${e.toString()}');
    }
  }

  /// Update a service package
  Future<ServicePackageDto> updateServicePackage(
    int salonId,
    int packageId,
    UpdateServicePackageRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/service-packages/$packageId',
        data: request.toJson(),
      );

      return ServicePackageDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update service package: ${e.toString()}');
    }
  }

  /// Delete a service package
  Future<void> deleteServicePackage(int salonId, int packageId) async {
    try {
      await _apiService.delete('/salon/$salonId/service-packages/$packageId');
    } catch (e) {
      throw Exception('Failed to delete service package: ${e.toString()}');
    }
  }

  // ==================== STAFF SERVICE ASSIGNMENTS ====================
  
  /// Get staff assignments for services
  Future<List<StaffServiceAssignmentDto>> getStaffServiceAssignments(
    int salonId, {
    int? serviceId,
    int? staffId,
    bool includeAvailability = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'includeAvailability': includeAvailability,
      };

      if (serviceId != null) queryParams['serviceId'] = serviceId;
      if (staffId != null) queryParams['staffId'] = staffId;

      final response = await _apiService.get(
        '/salon/$salonId/staff-service-assignments',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => StaffServiceAssignmentDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch staff service assignments: ${e.toString()}');
    }
  }

  /// Assign staff to a service
  Future<StaffServiceAssignmentDto> assignStaffToService(
    int salonId,
    CreateStaffServiceAssignmentRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/staff-service-assignments',
        data: request.toJson(),
      );

      return StaffServiceAssignmentDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to assign staff to service: ${e.toString()}');
    }
  }

  /// Update staff service assignment
  Future<StaffServiceAssignmentDto> updateStaffServiceAssignment(
    int salonId,
    int assignmentId,
    UpdateStaffServiceAssignmentRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/staff-service-assignments/$assignmentId',
        data: request.toJson(),
      );

      return StaffServiceAssignmentDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update staff service assignment: ${e.toString()}');
    }
  }

  /// Remove staff from service
  Future<void> removeStaffFromService(int salonId, int assignmentId) async {
    try {
      await _apiService.delete('/salon/$salonId/staff-service-assignments/$assignmentId');
    } catch (e) {
      throw Exception('Failed to remove staff from service: ${e.toString()}');
    }
  }

  // ==================== SERVICE AVAILABILITY ====================
  
  /// Get service availability schedules
  Future<List<ServiceAvailabilityDto>> getServiceAvailability(
    int salonId, {
    int? serviceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (serviceId != null) queryParams['serviceId'] = serviceId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/salon/$salonId/service-availability',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServiceAvailabilityDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service availability: ${e.toString()}');
    }
  }

  /// Set service availability
  Future<ServiceAvailabilityDto> setServiceAvailability(
    int salonId,
    CreateServiceAvailabilityRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/service-availability',
        data: request.toJson(),
      );

      return ServiceAvailabilityDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to set service availability: ${e.toString()}');
    }
  }

  /// Update service availability
  Future<ServiceAvailabilityDto> updateServiceAvailability(
    int salonId,
    int availabilityId,
    UpdateServiceAvailabilityRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/service-availability/$availabilityId',
        data: request.toJson(),
      );

      return ServiceAvailabilityDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update service availability: ${e.toString()}');
    }
  }

  /// Delete service availability
  Future<void> deleteServiceAvailability(int salonId, int availabilityId) async {
    try {
      await _apiService.delete('/salon/$salonId/service-availability/$availabilityId');
    } catch (e) {
      throw Exception('Failed to delete service availability: ${e.toString()}');
    }
  }

  // ==================== SERVICE PROMOTIONS ====================
  
  /// Get active promotions for services
  Future<List<ServicePromotionDto>> getServicePromotions(
    int salonId, {
    int? serviceId,
    bool activeOnly = true,
    DateTime? validFrom,
    DateTime? validTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'activeOnly': activeOnly,
      };

      if (serviceId != null) queryParams['serviceId'] = serviceId;
      if (validFrom != null) queryParams['validFrom'] = validFrom.toIso8601String();
      if (validTo != null) queryParams['validTo'] = validTo.toIso8601String();

      final response = await _apiService.get(
        '/salon/$salonId/service-promotions',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServicePromotionDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service promotions: ${e.toString()}');
    }
  }

  /// Create a new promotion
  Future<ServicePromotionDto> createServicePromotion(
    int salonId,
    CreateServicePromotionRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/service-promotions',
        data: request.toJson(),
      );

      return ServicePromotionDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create service promotion: ${e.toString()}');
    }
  }

  /// Update a promotion
  Future<ServicePromotionDto> updateServicePromotion(
    int salonId,
    int promotionId,
    UpdateServicePromotionRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/salon/$salonId/service-promotions/$promotionId',
        data: request.toJson(),
      );

      return ServicePromotionDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update service promotion: ${e.toString()}');
    }
  }

  /// Delete a promotion
  Future<void> deleteServicePromotion(int salonId, int promotionId) async {
    try {
      await _apiService.delete('/salon/$salonId/service-promotions/$promotionId');
    } catch (e) {
      throw Exception('Failed to delete service promotion: ${e.toString()}');
    }
  }

  // ==================== ANALYTICS & REPORTING ====================
  
  /// Get comprehensive service analytics
  Future<ServiceAnalyticsDto> getServiceAnalytics(
    int salonId, {
    DateTime? startDate,
    DateTime? endDate,
    int? serviceId,
    String period = 'month', // day, week, month, quarter, year
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (serviceId != null) queryParams['serviceId'] = serviceId;

      final response = await _apiService.get(
        '/salon/$salonId/service-analytics',
        queryParams: queryParams,
      );

      return ServiceAnalyticsDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch service analytics: ${e.toString()}');
    }
  }

  /// Get top performing services
  Future<List<ServicePerformanceDto>> getTopPerformingServices(
    int salonId, {
    int limit = 10,
    String metric = 'revenue', // revenue, bookings, rating
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'metric': metric,
      };

      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/salon/$salonId/service-performance',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServicePerformanceDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch top performing services: ${e.toString()}');
    }
  }

  // ==================== SERVICE REVIEWS & FEEDBACK ====================
  
  /// Get service reviews
  Future<List<ServiceReviewDto>> getServiceReviews(
    int salonId, {
    int? serviceId,
    int? rating,
    int? limit,
    int? offset,
    String sortBy = 'created_date',
    bool ascending = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'ascending': ascending,
      };

      if (serviceId != null) queryParams['serviceId'] = serviceId;
      if (rating != null) queryParams['rating'] = rating;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '/salon/$salonId/service-reviews',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServiceReviewDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service reviews: ${e.toString()}');
    }
  }

  /// Get service review statistics
  Future<ServiceReviewStatsDto> getServiceReviewStats(
    int salonId, {
    int? serviceId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (serviceId != null) queryParams['serviceId'] = serviceId;

      final response = await _apiService.get(
        '/salon/$salonId/service-review-stats',
        queryParams: queryParams,
      );

      return ServiceReviewStatsDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch service review stats: ${e.toString()}');
    }
  }

  // ==================== BULK OPERATIONS ====================
  
  /// Bulk update services
  Future<BulkOperationResultDto> bulkUpdateServices(
    int salonId,
    BulkUpdateServicesRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/bulk-update',
        data: request.toJson(),
      );

      return BulkOperationResultDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to bulk update services: ${e.toString()}');
    }
  }

  /// Bulk delete services
  Future<BulkOperationResultDto> bulkDeleteServices(
    int salonId,
    List<int> serviceIds,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/bulk-delete',
        data: {'serviceIds': serviceIds},
      );

      return BulkOperationResultDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to bulk delete services: ${e.toString()}');
    }
  }

  /// Bulk activate/deactivate services
  Future<BulkOperationResultDto> bulkToggleServicesStatus(
    int salonId,
    List<int> serviceIds,
    bool isActive,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/bulk-status',
        data: {
          'serviceIds': serviceIds,
          'isActive': isActive,
        },
      );

      return BulkOperationResultDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to bulk toggle services status: ${e.toString()}');
    }
  }

  // ==================== SERVICE TEMPLATES ====================
  
  /// Get service templates
  Future<List<ServiceTemplateDto>> getServiceTemplates(
    int salonId, {
    String? category,
    String? industry,
    bool includeCustom = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'includeCustom': includeCustom,
      };

      if (category != null) queryParams['category'] = category;
      if (industry != null) queryParams['industry'] = industry;

      final response = await _apiService.get(
        '/salon/$salonId/service-templates',
        queryParams: queryParams,
      );

      return (response['data'] as List<dynamic>)
          .map((json) => ServiceTemplateDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service templates: ${e.toString()}');
    }
  }

  /// Create service from template
  Future<EnhancedServiceDto> createServiceFromTemplate(
    int salonId,
    int templateId,
    CreateServiceFromTemplateRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/from-template/$templateId',
        data: request.toJson(),
      );

      return EnhancedServiceDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create service from template: ${e.toString()}');
    }
  }

  /// Save service as template
  Future<ServiceTemplateDto> saveServiceAsTemplate(
    int salonId,
    int serviceId,
    SaveServiceAsTemplateRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/$serviceId/save-as-template',
        data: request.toJson(),
      );

      return ServiceTemplateDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to save service as template: ${e.toString()}');
    }
  }

  // ==================== IMPORT / EXPORT ====================
  
  /// Export services data
  Future<String> exportServicesData(
    int salonId, {
    String format = 'csv', // csv, json, xlsx
    List<int>? serviceIds,
    bool includeAnalytics = false,
    bool includeReviews = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'format': format,
        'includeAnalytics': includeAnalytics,
        'includeReviews': includeReviews,
      };

      if (serviceIds != null && serviceIds.isNotEmpty) {
        queryParams['serviceIds'] = serviceIds.join(',');
      }

      final response = await _apiService.get(
        '/salon/$salonId/services/export',
        queryParams: queryParams,
      );

      return response['data']['downloadUrl'] as String;
    } catch (e) {
      throw Exception('Failed to export services data: ${e.toString()}');
    }
  }

  /// Import services data
  Future<ImportResultDto> importServicesData(
    int salonId,
    String fileUrl,
    ImportServicesRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/salon/$salonId/services/import',
        data: {
          'fileUrl': fileUrl,
          'options': request.toJson(),
        },
      );

      return ImportResultDto.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to import services data: ${e.toString()}');
    }
  }
}

// ==================== DATA TRANSFER OBJECTS (DTOs) ====================

/// Enhanced Service Category DTO with comprehensive information
class ServiceCategoryDto {
  final int id;
  final String name;
  final String description;
  final String? iconUrl;
  final int salonId;
  final bool isActive;
  final int serviceCount;
  final double totalRevenue;
  final int totalBookings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.salonId,
    required this.isActive,
    required this.serviceCount,
    required this.totalRevenue,
    required this.totalBookings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] != null ? ImageUtils.getFullImageUrl(json['iconUrl'] as String) : null,
      salonId: json['salonId'] as int,
      isActive: json['isActive'] as bool? ?? true,
      serviceCount: json['serviceCount'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'serviceCount': serviceCount,
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Enhanced Service DTO with comprehensive features
class EnhancedServiceDto {
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
  final bool isFeatured;
  final int bookingCount;
  final double averageRating;
  final int reviewCount;
  final double totalRevenue;
  final List<StaffServiceAssignmentDto> staffAssignments;
  final List<ServiceAvailabilityDto> availabilities;
  final List<ServicePromotionDto> activePromotions;
  final ServiceAnalyticsDto? analytics;
  final DateTime createdAt;
  final DateTime updatedAt;

  EnhancedServiceDto({
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
    required this.isFeatured,
    required this.bookingCount,
    required this.averageRating,
    required this.reviewCount,
    required this.totalRevenue,
    this.staffAssignments = const [],
    this.availabilities = const [],
    this.activePromotions = const [],
    this.analytics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EnhancedServiceDto.fromJson(Map<String, dynamic> json) {
    return EnhancedServiceDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationInMinutes: json['durationInMinutes'] as int? ?? 30,
      isActive: json['isActive'] as bool? ?? true,
      salonId: json['salonId'] as int,
      salonName: json['salonName'] as String? ?? '',
      imageUrl: json['imageUrl'] != null ? ImageUtils.getFullImageUrl(json['imageUrl'] as String) : null,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      maxConcurrentBookings: json['maxConcurrentBookings'] as int? ?? 1,
      requiresStaffAssignment: json['requiresStaffAssignment'] as bool? ?? true,
      bufferTimeBeforeMinutes: json['bufferTimeBeforeMinutes'] as int? ?? 0,
      bufferTimeAfterMinutes: json['bufferTimeAfterMinutes'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      isPopular: json['isPopular'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      bookingCount: json['bookingCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      staffAssignments: (json['staffAssignments'] as List<dynamic>?)
          ?.map((x) => StaffServiceAssignmentDto.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
      availabilities: (json['availabilities'] as List<dynamic>?)
          ?.map((x) => ServiceAvailabilityDto.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
      activePromotions: (json['activePromotions'] as List<dynamic>?)
          ?.map((x) => ServicePromotionDto.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
      analytics: json['analytics'] != null 
          ? ServiceAnalyticsDto.fromJson(json['analytics'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'isFeatured': isFeatured,
      'bookingCount': bookingCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'totalRevenue': totalRevenue,
      'staffAssignments': staffAssignments.map((x) => x.toJson()).toList(),
      'availabilities': availabilities.map((x) => x.toJson()).toList(),
      'activePromotions': activePromotions.map((x) => x.toJson()).toList(),
      'analytics': analytics?.toJson(),
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

  bool get hasActivePromotions => activePromotions.isNotEmpty;
  double get currentDiscountPercentage {
    if (activePromotions.isEmpty) return 0.0;
    return activePromotions.map((p) => p.discountPercentage).reduce((a, b) => a > b ? a : b);
  }
}

// Continue with remaining DTOs...
// [Additional DTOs will be created in separate files for better organization]
