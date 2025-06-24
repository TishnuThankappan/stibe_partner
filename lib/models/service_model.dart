class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final List<String>? images;
  final List<String>? assignedStaffIds;
  final String category;
  final bool isActive;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.images,
    this.assignedStaffIds,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      durationMinutes: json['durationMinutes'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      assignedStaffIds: json['assignedStaffIds'] != null
          ? List<String>.from(json['assignedStaffIds'])
          : null,
      category: json['category'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'images': images,
      'assignedStaffIds': assignedStaffIds,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ServicePackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int totalDurationMinutes;
  final List<Service> services;
  final String? image;
  final bool isActive;
  final DateTime createdAt;

  ServicePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.totalDurationMinutes,
    required this.services,
    this.image,
    required this.isActive,
    required this.createdAt,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      totalDurationMinutes: json['totalDurationMinutes'],
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      image: json['image'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'totalDurationMinutes': totalDurationMinutes,
      'services': services.map((service) => service.toJson()).toList(),
      'image': image,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
