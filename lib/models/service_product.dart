import 'dart:io';

// Product model for services
class ServiceProduct {
  final String id; // Unique identifier for local management
  final String name;
  final String? description;
  final List<String> imageUrls; // Multiple uploaded image URLs
  final List<File> localImageFiles; // Multiple new/local images
  final bool isUploaded;

  ServiceProduct({
    required this.id,
    required this.name,
    this.description,
    List<String>? imageUrls,
    List<File>? localImageFiles,
    this.isUploaded = false,
  }) : imageUrls = imageUrls ?? [],
       localImageFiles = localImageFiles ?? [];

  ServiceProduct copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? imageUrls,
    List<File>? localImageFiles,
    bool? isUploaded,
  }) {
    return ServiceProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      localImageFiles: localImageFiles ?? this.localImageFiles,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
    };
  }

  factory ServiceProduct.fromJson(Map<String, dynamic> json, String id) {
    return ServiceProduct(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']) 
          : [],
      isUploaded: true,
    );
  }

  // Convert products list to JSON format for API
  static List<Map<String, dynamic>> productsToJson(List<ServiceProduct> products) {
    return products.map((product) => product.toJson()).toList();
  }

  // Convert products list to simple string format (for backward compatibility)
  static String productsToString(List<ServiceProduct> products) {
    return products.map((product) => product.name).join(', ');
  }

  // Parse products from string format (for backward compatibility)
  static List<ServiceProduct> productsFromString(String productsString) {
    if (productsString.trim().isEmpty) return [];
    
    final productNames = productsString.split(',').map((name) => name.trim()).where((name) => name.isNotEmpty);
    return productNames.map((name) => ServiceProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + name.hashCode.toString(),
      name: name,
      isUploaded: true,
    )).toList();
  }

  // Convenience getters for multiple images
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  File? get primaryLocalImage => localImageFiles.isNotEmpty ? localImageFiles.first : null;
  
  // Get the primary image to display (local takes priority over uploaded)
  dynamic get primaryImage => primaryLocalImage ?? primaryImageUrl;
  
  // Check if product has any images
  bool get hasImages => imageUrls.isNotEmpty || localImageFiles.isNotEmpty;
  
  // Get total image count
  int get totalImageCount => imageUrls.length + localImageFiles.length;
  
  // Add a new local image
  ServiceProduct addLocalImage(File imageFile) {
    return copyWith(
      localImageFiles: [...localImageFiles, imageFile],
    );
  }
  
  // Remove a local image at index
  ServiceProduct removeLocalImage(int index) {
    final newLocalImages = List<File>.from(localImageFiles);
    if (index >= 0 && index < newLocalImages.length) {
      newLocalImages.removeAt(index);
    }
    return copyWith(localImageFiles: newLocalImages);
  }
  
  // Remove an uploaded image at index
  ServiceProduct removeUploadedImage(int index) {
    final newImageUrls = List<String>.from(imageUrls);
    if (index >= 0 && index < newImageUrls.length) {
      newImageUrls.removeAt(index);
    }
    return copyWith(imageUrls: newImageUrls);
  }
  
  // Add an uploaded image URL
  ServiceProduct addUploadedImage(String imageUrl) {
    return copyWith(
      imageUrls: [...imageUrls, imageUrl],
    );
  }
}
