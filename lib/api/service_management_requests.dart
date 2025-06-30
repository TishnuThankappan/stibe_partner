// Request DTOs for the Salon Service Management API

// ==================== SERVICE CATEGORY REQUESTS ====================

class CreateServiceCategoryRequest {
  final String name;
  final String description;
  final String? iconUrl;

  CreateServiceCategoryRequest({
    required this.name,
    required this.description,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
    };
  }
}

class UpdateServiceCategoryRequest {
  final String? name;
  final String? description;
  final String? iconUrl;
  final bool? isActive;

  UpdateServiceCategoryRequest({
    this.name,
    this.description,
    this.iconUrl,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (iconUrl != null) map['iconUrl'] = iconUrl;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}

// ==================== SERVICE REQUESTS ====================

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
  final bool isFeatured;
  final List<CreateServiceAvailabilityRequest>? availabilities;
  final List<int>? assignedStaffIds;

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
    this.isFeatured = false,
    this.availabilities,
    this.assignedStaffIds,
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
      'isFeatured': isFeatured,
      'availabilities': availabilities?.map((a) => a.toJson()).toList(),
      'assignedStaffIds': assignedStaffIds,
    };
  }
}

class UpdateServiceRequest {
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
  final bool? isFeatured;

  UpdateServiceRequest({
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
    this.isFeatured,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (durationInMinutes != null) map['durationInMinutes'] = durationInMinutes;
    if (isActive != null) map['isActive'] = isActive;
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (maxConcurrentBookings != null) map['maxConcurrentBookings'] = maxConcurrentBookings;
    if (requiresStaffAssignment != null) map['requiresStaffAssignment'] = requiresStaffAssignment;
    if (bufferTimeBeforeMinutes != null) map['bufferTimeBeforeMinutes'] = bufferTimeBeforeMinutes;
    if (bufferTimeAfterMinutes != null) map['bufferTimeAfterMinutes'] = bufferTimeAfterMinutes;
    if (tags != null) map['tags'] = tags;
    if (metadata != null) map['metadata'] = metadata;
    if (discountPercentage != null) map['discountPercentage'] = discountPercentage;
    if (isPopular != null) map['isPopular'] = isPopular;
    if (isFeatured != null) map['isFeatured'] = isFeatured;
    return map;
  }
}

// ==================== SERVICE PACKAGE REQUESTS ====================

class CreateServicePackageRequest {
  final String name;
  final String description;
  final double price;
  final List<int> serviceIds;
  final String? imageUrl;
  final double? discountPercentage;
  final bool isPopular;
  final bool isFeatured;
  final DateTime validFrom;
  final DateTime? validTo;

  CreateServicePackageRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.serviceIds,
    this.imageUrl,
    this.discountPercentage,
    this.isPopular = false,
    this.isFeatured = false,
    required this.validFrom,
    this.validTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'serviceIds': serviceIds,
      'imageUrl': imageUrl,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
    };
  }
}

class UpdateServicePackageRequest {
  final String? name;
  final String? description;
  final double? price;
  final List<int>? serviceIds;
  final String? imageUrl;
  final bool? isActive;
  final double? discountPercentage;
  final bool? isPopular;
  final bool? isFeatured;
  final DateTime? validFrom;
  final DateTime? validTo;

  UpdateServicePackageRequest({
    this.name,
    this.description,
    this.price,
    this.serviceIds,
    this.imageUrl,
    this.isActive,
    this.discountPercentage,
    this.isPopular,
    this.isFeatured,
    this.validFrom,
    this.validTo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (serviceIds != null) map['serviceIds'] = serviceIds;
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    if (isActive != null) map['isActive'] = isActive;
    if (discountPercentage != null) map['discountPercentage'] = discountPercentage;
    if (isPopular != null) map['isPopular'] = isPopular;
    if (isFeatured != null) map['isFeatured'] = isFeatured;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validTo != null) map['validTo'] = validTo!.toIso8601String();
    return map;
  }
}

// ==================== STAFF SERVICE ASSIGNMENT REQUESTS ====================

class CreateStaffServiceAssignmentRequest {
  final int staffId;
  final int serviceId;
  final bool isPrimary;
  final double skillLevel;
  final double? customRate;
  final List<CreateServiceAvailabilityRequest>? availabilities;

  CreateStaffServiceAssignmentRequest({
    required this.staffId,
    required this.serviceId,
    this.isPrimary = false,
    this.skillLevel = 1.0,
    this.customRate,
    this.availabilities,
  });

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'serviceId': serviceId,
      'isPrimary': isPrimary,
      'skillLevel': skillLevel,
      'customRate': customRate,
      'availabilities': availabilities?.map((a) => a.toJson()).toList(),
    };
  }
}

class UpdateStaffServiceAssignmentRequest {
  final bool? isPrimary;
  final double? skillLevel;
  final double? customRate;
  final bool? isActive;

  UpdateStaffServiceAssignmentRequest({
    this.isPrimary,
    this.skillLevel,
    this.customRate,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (isPrimary != null) map['isPrimary'] = isPrimary;
    if (skillLevel != null) map['skillLevel'] = skillLevel;
    if (customRate != null) map['customRate'] = customRate;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}

// ==================== SERVICE AVAILABILITY REQUESTS ====================

class CreateServiceAvailabilityRequest {
  final int serviceId;
  final int? staffId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int maxBookingsPerSlot;
  final int slotDurationMinutes;
  final int bufferTimeMinutes;
  final DateTime? overrideDate;
  final String? notes;

  CreateServiceAvailabilityRequest({
    required this.serviceId,
    this.staffId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.maxBookingsPerSlot = 1,
    this.slotDurationMinutes = 30,
    this.bufferTimeMinutes = 0,
    this.overrideDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'staffId': staffId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'maxBookingsPerSlot': maxBookingsPerSlot,
      'slotDurationMinutes': slotDurationMinutes,
      'bufferTimeMinutes': bufferTimeMinutes,
      'overrideDate': overrideDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

class UpdateServiceAvailabilityRequest {
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool? isAvailable;
  final int? maxBookingsPerSlot;
  final int? slotDurationMinutes;
  final int? bufferTimeMinutes;
  final DateTime? overrideDate;
  final String? notes;

  UpdateServiceAvailabilityRequest({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.isAvailable,
    this.maxBookingsPerSlot,
    this.slotDurationMinutes,
    this.bufferTimeMinutes,
    this.overrideDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dayOfWeek != null) map['dayOfWeek'] = dayOfWeek;
    if (startTime != null) map['startTime'] = startTime;
    if (endTime != null) map['endTime'] = endTime;
    if (isAvailable != null) map['isAvailable'] = isAvailable;
    if (maxBookingsPerSlot != null) map['maxBookingsPerSlot'] = maxBookingsPerSlot;
    if (slotDurationMinutes != null) map['slotDurationMinutes'] = slotDurationMinutes;
    if (bufferTimeMinutes != null) map['bufferTimeMinutes'] = bufferTimeMinutes;
    if (overrideDate != null) map['overrideDate'] = overrideDate!.toIso8601String();
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

// ==================== SERVICE PROMOTION REQUESTS ====================

class CreateServicePromotionRequest {
  final String name;
  final String description;
  final String type;
  final double discountPercentage;
  final double? discountAmount;
  final int? minimumServices;
  final List<int> applicableServiceIds;
  final DateTime validFrom;
  final DateTime validTo;
  final int? maxUsages;
  final String? promoCode;
  final bool requiresPromoCode;

  CreateServicePromotionRequest({
    required this.name,
    required this.description,
    required this.type,
    required this.discountPercentage,
    this.discountAmount,
    this.minimumServices,
    required this.applicableServiceIds,
    required this.validFrom,
    required this.validTo,
    this.maxUsages,
    this.promoCode,
    this.requiresPromoCode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minimumServices': minimumServices,
      'applicableServiceIds': applicableServiceIds,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'maxUsages': maxUsages,
      'promoCode': promoCode,
      'requiresPromoCode': requiresPromoCode,
    };
  }
}

class UpdateServicePromotionRequest {
  final String? name;
  final String? description;
  final String? type;
  final double? discountPercentage;
  final double? discountAmount;
  final int? minimumServices;
  final List<int>? applicableServiceIds;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool? isActive;
  final int? maxUsages;
  final String? promoCode;
  final bool? requiresPromoCode;

  UpdateServicePromotionRequest({
    this.name,
    this.description,
    this.type,
    this.discountPercentage,
    this.discountAmount,
    this.minimumServices,
    this.applicableServiceIds,
    this.validFrom,
    this.validTo,
    this.isActive,
    this.maxUsages,
    this.promoCode,
    this.requiresPromoCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (type != null) map['type'] = type;
    if (discountPercentage != null) map['discountPercentage'] = discountPercentage;
    if (discountAmount != null) map['discountAmount'] = discountAmount;
    if (minimumServices != null) map['minimumServices'] = minimumServices;
    if (applicableServiceIds != null) map['applicableServiceIds'] = applicableServiceIds;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validTo != null) map['validTo'] = validTo!.toIso8601String();
    if (isActive != null) map['isActive'] = isActive;
    if (maxUsages != null) map['maxUsages'] = maxUsages;
    if (promoCode != null) map['promoCode'] = promoCode;
    if (requiresPromoCode != null) map['requiresPromoCode'] = requiresPromoCode;
    return map;
  }
}

// ==================== BULK OPERATION REQUESTS ====================

class BulkUpdateServicesRequest {
  final List<int> serviceIds;
  final Map<String, dynamic> updates;

  BulkUpdateServicesRequest({
    required this.serviceIds,
    required this.updates,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceIds': serviceIds,
      'updates': updates,
    };
  }
}

// ==================== TEMPLATE REQUESTS ====================

class CreateServiceFromTemplateRequest {
  final String? customName;
  final double? customPrice;
  final int? customDuration;
  final int? categoryId;
  final Map<String, dynamic>? customizations;

  CreateServiceFromTemplateRequest({
    this.customName,
    this.customPrice,
    this.customDuration,
    this.categoryId,
    this.customizations,
  });

  Map<String, dynamic> toJson() {
    return {
      'customName': customName,
      'customPrice': customPrice,
      'customDuration': customDuration,
      'categoryId': categoryId,
      'customizations': customizations,
    };
  }
}

class SaveServiceAsTemplateRequest {
  final String templateName;
  final String templateDescription;
  final String category;
  final bool isPublic;

  SaveServiceAsTemplateRequest({
    required this.templateName,
    required this.templateDescription,
    required this.category,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'templateName': templateName,
      'templateDescription': templateDescription,
      'category': category,
      'isPublic': isPublic,
    };
  }
}

// ==================== IMPORT/EXPORT REQUESTS ====================

class ImportServicesRequest {
  final bool skipDuplicates;
  final bool updateExisting;
  final int? defaultCategoryId;
  final Map<String, dynamic>? fieldMapping;

  ImportServicesRequest({
    this.skipDuplicates = true,
    this.updateExisting = false,
    this.defaultCategoryId,
    this.fieldMapping,
  });

  Map<String, dynamic> toJson() {
    return {
      'skipDuplicates': skipDuplicates,
      'updateExisting': updateExisting,
      'defaultCategoryId': defaultCategoryId,
      'fieldMapping': fieldMapping,
    };
  }
}
