// Supporting DTOs for the Salon Service Management API

// ==================== SERVICE PACKAGE DTOs ====================

class ServicePackageDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int totalDurationMinutes;
  final List<int> serviceIds;
  final String? imageUrl;
  final bool isActive;
  final int salonId;
  final double? discountPercentage;
  final bool isPopular;
  final bool isFeatured;
  final int bookingCount;
  final double averageRating;
  final double totalRevenue;
  final DateTime validFrom;
  final DateTime? validTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePackageDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.totalDurationMinutes,
    required this.serviceIds,
    this.imageUrl,
    required this.isActive,
    required this.salonId,
    this.discountPercentage,
    required this.isPopular,
    required this.isFeatured,
    required this.bookingCount,
    required this.averageRating,
    required this.totalRevenue,
    required this.validFrom,
    this.validTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePackageDto.fromJson(Map<String, dynamic> json) {
    return ServicePackageDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalDurationMinutes: json['totalDurationMinutes'] as int? ?? 0,
      serviceIds: (json['serviceIds'] as List<dynamic>?)?.cast<int>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      salonId: json['salonId'] as int,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      isPopular: json['isPopular'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      bookingCount: json['bookingCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo'] as String) : null,
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
      'totalDurationMinutes': totalDurationMinutes,
      'serviceIds': serviceIds,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'salonId': salonId,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'bookingCount': bookingCount,
      'averageRating': averageRating,
      'totalRevenue': totalRevenue,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
  
  double get savings => 0.0; // Will be calculated with actual service prices
  String get savingsFormatted => '\$${savings.toStringAsFixed(2)}';
  double get savingsPercentage => 0.0; // Will be calculated with actual service prices
}

// ==================== STAFF SERVICE ASSIGNMENT DTOs ====================

class StaffServiceAssignmentDto {
  final int id;
  final int staffId;
  final String staffName;
  final String? staffImageUrl;
  final int serviceId;
  final String serviceName;
  final bool isPrimary;
  final double skillLevel; // 1-5 rating
  final double? customRate;
  final bool isActive;
  final List<ServiceAvailabilityDto> availabilities;
  final int totalBookings;
  final double averageRating;
  final DateTime assignedAt;
  final DateTime updatedAt;

  StaffServiceAssignmentDto({
    required this.id,
    required this.staffId,
    required this.staffName,
    this.staffImageUrl,
    required this.serviceId,
    required this.serviceName,
    required this.isPrimary,
    required this.skillLevel,
    this.customRate,
    required this.isActive,
    this.availabilities = const [],
    required this.totalBookings,
    required this.averageRating,
    required this.assignedAt,
    required this.updatedAt,
  });

  factory StaffServiceAssignmentDto.fromJson(Map<String, dynamic> json) {
    return StaffServiceAssignmentDto(
      id: json['id'] as int,
      staffId: json['staffId'] as int,
      staffName: json['staffName'] as String? ?? '',
      staffImageUrl: json['staffImageUrl'] as String?,
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      skillLevel: (json['skillLevel'] as num?)?.toDouble() ?? 1.0,
      customRate: (json['customRate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      availabilities: (json['availabilities'] as List<dynamic>?)
          ?.map((a) => ServiceAvailabilityDto.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      totalBookings: json['totalBookings'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'staffImageUrl': staffImageUrl,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'isPrimary': isPrimary,
      'skillLevel': skillLevel,
      'customRate': customRate,
      'isActive': isActive,
      'availabilities': availabilities.map((a) => a.toJson()).toList(),
      'totalBookings': totalBookings,
      'averageRating': averageRating,
      'assignedAt': assignedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get skillLevelText {
    switch (skillLevel.round()) {
      case 1: return 'Beginner';
      case 2: return 'Novice';
      case 3: return 'Intermediate';
      case 4: return 'Advanced';
      case 5: return 'Expert';
      default: return 'Unknown';
    }
  }
}

// ==================== SERVICE AVAILABILITY DTOs ====================

class ServiceAvailabilityDto {
  final int id;
  final int serviceId;
  final int? staffId;
  final String? staffName;
  final int dayOfWeek; // 0-6, 0 = Sunday
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final bool isAvailable;
  final int maxBookingsPerSlot;
  final int slotDurationMinutes;
  final int bufferTimeMinutes;
  final DateTime? overrideDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceAvailabilityDto({
    required this.id,
    required this.serviceId,
    this.staffId,
    this.staffName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.maxBookingsPerSlot,
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
    this.overrideDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return ServiceAvailabilityDto(
      id: json['id'] as int,
      serviceId: json['serviceId'] as int,
      staffId: json['staffId'] as int?,
      staffName: json['staffName'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      maxBookingsPerSlot: json['maxBookingsPerSlot'] as int? ?? 1,
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int? ?? 0,
      overrideDate: json['overrideDate'] != null 
          ? DateTime.parse(json['overrideDate'] as String) 
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'staffId': staffId,
      'staffName': staffName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'maxBookingsPerSlot': maxBookingsPerSlot,
      'slotDurationMinutes': slotDurationMinutes,
      'bufferTimeMinutes': bufferTimeMinutes,
      'overrideDate': overrideDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get dayOfWeekName {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
  }

  String get timeRange => '$startTime - $endTime';
}

// ==================== SERVICE PROMOTION DTOs ====================

class ServicePromotionDto {
  final int id;
  final String name;
  final String description;
  final String type; // percentage, fixed_amount, buy_one_get_one
  final double discountPercentage;
  final double? discountAmount;
  final int? minimumServices;
  final List<int> applicableServiceIds;
  final List<String> applicableServiceNames;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;
  final int usageCount;
  final int? maxUsages;
  final String? promoCode;
  final bool requiresPromoCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePromotionDto({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.discountPercentage,
    this.discountAmount,
    this.minimumServices,
    required this.applicableServiceIds,
    required this.applicableServiceNames,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
    required this.usageCount,
    this.maxUsages,
    this.promoCode,
    required this.requiresPromoCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePromotionDto.fromJson(Map<String, dynamic> json) {
    return ServicePromotionDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'percentage',
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      minimumServices: json['minimumServices'] as int?,
      applicableServiceIds: (json['applicableServiceIds'] as List<dynamic>?)?.cast<int>() ?? [],
      applicableServiceNames: (json['applicableServiceNames'] as List<dynamic>?)?.cast<String>() ?? [],
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      isActive: json['isActive'] as bool? ?? true,
      usageCount: json['usageCount'] as int? ?? 0,
      maxUsages: json['maxUsages'] as int?,
      promoCode: json['promoCode'] as String?,
      requiresPromoCode: json['requiresPromoCode'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minimumServices': minimumServices,
      'applicableServiceIds': applicableServiceIds,
      'applicableServiceNames': applicableServiceNames,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'isActive': isActive,
      'usageCount': usageCount,
      'maxUsages': maxUsages,
      'promoCode': promoCode,
      'requiresPromoCode': requiresPromoCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isCurrentlyValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(validFrom) && 
           now.isBefore(validTo) &&
           (maxUsages == null || usageCount < maxUsages!);
  }

  String get formattedDiscount {
    switch (type) {
      case 'percentage':
        return '${discountPercentage.toInt()}% off';
      case 'fixed_amount':
        return '\$${discountAmount?.toStringAsFixed(2)} off';
      case 'buy_one_get_one':
        return 'Buy one, get one free';
      default:
        return 'Special offer';
    }
  }
}

// ==================== ANALYTICS DTOs ====================

class ServiceAnalyticsDto {
  final int serviceId;
  final String serviceName;
  final double totalRevenue;
  final int totalBookings;
  final double averageRating;
  final int reviewCount;
  final double cancellationRate;
  final double noShowRate;
  final Map<String, double> revenueByPeriod;
  final Map<String, int> bookingsByPeriod;
  final Map<int, int> bookingsByDayOfWeek;
  final Map<int, int> bookingsByHour;
  final List<ServiceTrendDto> trends;
  final DateTime periodStart;
  final DateTime periodEnd;

  ServiceAnalyticsDto({
    required this.serviceId,
    required this.serviceName,
    required this.totalRevenue,
    required this.totalBookings,
    required this.averageRating,
    required this.reviewCount,
    required this.cancellationRate,
    required this.noShowRate,
    required this.revenueByPeriod,
    required this.bookingsByPeriod,
    required this.bookingsByDayOfWeek,
    required this.bookingsByHour,
    required this.trends,
    required this.periodStart,
    required this.periodEnd,
  });

  factory ServiceAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return ServiceAnalyticsDto(
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String? ?? '',
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      cancellationRate: (json['cancellationRate'] as num?)?.toDouble() ?? 0.0,
      noShowRate: (json['noShowRate'] as num?)?.toDouble() ?? 0.0,
      revenueByPeriod: Map<String, double>.from(json['revenueByPeriod'] as Map? ?? {}),
      bookingsByPeriod: Map<String, int>.from(json['bookingsByPeriod'] as Map? ?? {}),
      bookingsByDayOfWeek: Map<int, int>.from(json['bookingsByDayOfWeek'] as Map? ?? {}),
      bookingsByHour: Map<int, int>.from(json['bookingsByHour'] as Map? ?? {}),
      trends: (json['trends'] as List<dynamic>?)
          ?.map((t) => ServiceTrendDto.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookings,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'cancellationRate': cancellationRate,
      'noShowRate': noShowRate,
      'revenueByPeriod': revenueByPeriod,
      'bookingsByPeriod': bookingsByPeriod,
      'bookingsByDayOfWeek': bookingsByDayOfWeek,
      'bookingsByHour': bookingsByHour,
      'trends': trends.map((t) => t.toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  double get averageBookingsPerDay {
    final daysDiff = periodEnd.difference(periodStart).inDays;
    return daysDiff > 0 ? totalBookings / daysDiff : 0;
  }

  double get conversionRate => totalBookings > 0 ? (totalBookings - (totalBookings * cancellationRate)) / totalBookings : 0;
}

class ServicePerformanceDto {
  final int serviceId;
  final String serviceName;
  final double revenue;
  final int bookings;
  final double averageRating;
  final double growthRate;
  final int rank;

  ServicePerformanceDto({
    required this.serviceId,
    required this.serviceName,
    required this.revenue,
    required this.bookings,
    required this.averageRating,
    required this.growthRate,
    required this.rank,
  });

  factory ServicePerformanceDto.fromJson(Map<String, dynamic> json) {
    return ServicePerformanceDto(
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      bookings: json['bookings'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'revenue': revenue,
      'bookings': bookings,
      'averageRating': averageRating,
      'growthRate': growthRate,
      'rank': rank,
    };
  }
}

class ServiceTrendDto {
  final String period;
  final double value;
  final String metric;
  final double changePercentage;

  ServiceTrendDto({
    required this.period,
    required this.value,
    required this.metric,
    required this.changePercentage,
  });

  factory ServiceTrendDto.fromJson(Map<String, dynamic> json) {
    return ServiceTrendDto(
      period: json['period'] as String,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      metric: json['metric'] as String,
      changePercentage: (json['changePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
      'metric': metric,
      'changePercentage': changePercentage,
    };
  }
}

// ==================== REVIEW DTOs ====================

class ServiceReviewDto {
  final int id;
  final int serviceId;
  final String serviceName;
  final int customerId;
  final String customerName;
  final String? customerImageUrl;
  final int rating;
  final String? comment;
  final List<String> tags;
  final DateTime bookingDate;
  final DateTime reviewDate;
  final bool isVerified;
  final String? staffResponse;
  final DateTime? staffResponseDate;

  ServiceReviewDto({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.customerId,
    required this.customerName,
    this.customerImageUrl,
    required this.rating,
    this.comment,
    required this.tags,
    required this.bookingDate,
    required this.reviewDate,
    required this.isVerified,
    this.staffResponse,
    this.staffResponseDate,
  });

  factory ServiceReviewDto.fromJson(Map<String, dynamic> json) {
    return ServiceReviewDto(
      id: json['id'] as int,
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String? ?? '',
      customerId: json['customerId'] as int,
      customerName: json['customerName'] as String? ?? '',
      customerImageUrl: json['customerImageUrl'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      reviewDate: DateTime.parse(json['reviewDate'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      staffResponse: json['staffResponse'] as String?,
      staffResponseDate: json['staffResponseDate'] != null 
          ? DateTime.parse(json['staffResponseDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'customerId': customerId,
      'customerName': customerName,
      'customerImageUrl': customerImageUrl,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'bookingDate': bookingDate.toIso8601String(),
      'reviewDate': reviewDate.toIso8601String(),
      'isVerified': isVerified,
      'staffResponse': staffResponse,
      'staffResponseDate': staffResponseDate?.toIso8601String(),
    };
  }

  String get timeAgo {
    final difference = DateTime.now().difference(reviewDate);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}

class ServiceReviewStatsDto {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final List<String> topPositiveTags;
  final List<String> topNegativeTags;
  final double responseRate;
  final double averageResponseTime;

  ServiceReviewStatsDto({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.topPositiveTags,
    required this.topNegativeTags,
    required this.responseRate,
    required this.averageResponseTime,
  });

  factory ServiceReviewStatsDto.fromJson(Map<String, dynamic> json) {
    return ServiceReviewStatsDto(
      totalReviews: json['totalReviews'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] as Map? ?? {}),
      topPositiveTags: (json['topPositiveTags'] as List<dynamic>?)?.cast<String>() ?? [],
      topNegativeTags: (json['topNegativeTags'] as List<dynamic>?)?.cast<String>() ?? [],
      responseRate: (json['responseRate'] as num?)?.toDouble() ?? 0.0,
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'topPositiveTags': topPositiveTags,
      'topNegativeTags': topNegativeTags,
      'responseRate': responseRate,
      'averageResponseTime': averageResponseTime,
    };
  }
}

// ==================== TEMPLATE DTOs ====================

class ServiceTemplateDto {
  final int id;
  final String name;
  final String description;
  final double suggestedPrice;
  final int suggestedDuration;
  final String category;
  final String industry;
  final List<String> tags;
  final bool isCustom;
  final int usageCount;
  final double rating;
  final DateTime createdAt;

  ServiceTemplateDto({
    required this.id,
    required this.name,
    required this.description,
    required this.suggestedPrice,
    required this.suggestedDuration,
    required this.category,
    required this.industry,
    required this.tags,
    required this.isCustom,
    required this.usageCount,
    required this.rating,
    required this.createdAt,
  });

  factory ServiceTemplateDto.fromJson(Map<String, dynamic> json) {
    return ServiceTemplateDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0.0,
      suggestedDuration: json['suggestedDuration'] as int? ?? 30,
      category: json['category'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isCustom: json['isCustom'] as bool? ?? false,
      usageCount: json['usageCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'suggestedPrice': suggestedPrice,
      'suggestedDuration': suggestedDuration,
      'category': category,
      'industry': industry,
      'tags': tags,
      'isCustom': isCustom,
      'usageCount': usageCount,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// ==================== BULK OPERATION DTOs ====================

class BulkOperationResultDto {
  final int totalProcessed;
  final int successful;
  final int failed;
  final List<String> errors;
  final List<int> successfulIds;
  final List<int> failedIds;
  final DateTime processedAt;

  BulkOperationResultDto({
    required this.totalProcessed,
    required this.successful,
    required this.failed,
    required this.errors,
    required this.successfulIds,
    required this.failedIds,
    required this.processedAt,
  });

  factory BulkOperationResultDto.fromJson(Map<String, dynamic> json) {
    return BulkOperationResultDto(
      totalProcessed: json['totalProcessed'] as int? ?? 0,
      successful: json['successful'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      successfulIds: (json['successfulIds'] as List<dynamic>?)?.cast<int>() ?? [],
      failedIds: (json['failedIds'] as List<dynamic>?)?.cast<int>() ?? [],
      processedAt: DateTime.parse(json['processedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProcessed': totalProcessed,
      'successful': successful,
      'failed': failed,
      'errors': errors,
      'successfulIds': successfulIds,
      'failedIds': failedIds,
      'processedAt': processedAt.toIso8601String(),
    };
  }

  bool get hasErrors => failed > 0;
  double get successRate => totalProcessed > 0 ? successful / totalProcessed : 0;
}

// ==================== IMPORT/EXPORT DTOs ====================

class ImportResultDto {
  final int totalRows;
  final int importedServices;
  final int skippedServices;
  final int errorCount;
  final List<String> errors;
  final List<String> warnings;
  final DateTime importedAt;

  ImportResultDto({
    required this.totalRows,
    required this.importedServices,
    required this.skippedServices,
    required this.errorCount,
    required this.errors,
    required this.warnings,
    required this.importedAt,
  });

  factory ImportResultDto.fromJson(Map<String, dynamic> json) {
    return ImportResultDto(
      totalRows: json['totalRows'] as int? ?? 0,
      importedServices: json['importedServices'] as int? ?? 0,
      skippedServices: json['skippedServices'] as int? ?? 0,
      errorCount: json['errorCount'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      warnings: (json['warnings'] as List<dynamic>?)?.cast<String>() ?? [],
      importedAt: DateTime.parse(json['importedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRows': totalRows,
      'importedServices': importedServices,
      'skippedServices': skippedServices,
      'errorCount': errorCount,
      'errors': errors,
      'warnings': warnings,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  bool get hasErrors => errorCount > 0;
  bool get hasWarnings => warnings.isNotEmpty;
}
