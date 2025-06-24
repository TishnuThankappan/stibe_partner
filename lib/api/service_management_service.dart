import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/service_model.dart';

class ServiceManagementService {
  final ApiService _apiService = ApiService();

  // Get all services
  Future<List<Service>> getAllServices() async {
    final response = await _apiService.get('/services');
    
    return (response['services'] as List)
        .map((service) => Service.fromJson(service))
        .toList();
  }

  // Add new service
  Future<Service> addService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    List<String>? images,
    List<String>? assignedStaffIds,
    required String category,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
    };
    
    if (images != null) data['images'] = images;
    if (assignedStaffIds != null) data['assignedStaffIds'] = assignedStaffIds;

    final response = await _apiService.post('/services', data: data);
    return Service.fromJson(response['service']);
  }

  // Get service details
  Future<Service> getServiceDetails({required String id}) async {
    final response = await _apiService.get('/services/$id');
    return Service.fromJson(response['service']);
  }

  // Update service
  Future<Service> updateService({
    required String id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    List<String>? images,
    List<String>? assignedStaffIds,
    String? category,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (durationMinutes != null) data['durationMinutes'] = durationMinutes;
    if (images != null) data['images'] = images;
    if (assignedStaffIds != null) data['assignedStaffIds'] = assignedStaffIds;
    if (category != null) data['category'] = category;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _apiService.put('/services/$id', data: data);
    return Service.fromJson(response['service']);
  }

  // Remove service
  Future<bool> removeService({required String id}) async {
    final response = await _apiService.delete('/services/$id');
    return response['deleted'] ?? false;
  }

  // Create service package
  Future<ServicePackage> createServicePackage({
    required String name,
    required String description,
    required double price,
    required List<String> serviceIds,
    String? image,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'serviceIds': serviceIds,
    };
    
    if (image != null) data['image'] = image;

    final response = await _apiService.post('/services/packages', data: data);
    return ServicePackage.fromJson(response['package']);
  }

  // Get all service packages
  Future<List<ServicePackage>> getAllServicePackages() async {
    final response = await _apiService.get('/services/packages');
    
    return (response['packages'] as List)
        .map((package) => ServicePackage.fromJson(package))
        .toList();
  }

  // Update service package
  Future<ServicePackage> updateServicePackage({
    required String id,
    String? name,
    String? description,
    double? price,
    List<String>? serviceIds,
    String? image,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (serviceIds != null) data['serviceIds'] = serviceIds;
    if (image != null) data['image'] = image;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _apiService.put('/services/packages/$id', data: data);
    return ServicePackage.fromJson(response['package']);
  }

  // Remove service package
  Future<bool> removeServicePackage({required String id}) async {
    final response = await _apiService.delete('/services/packages/$id');
    return response['deleted'] ?? false;
  }
}
