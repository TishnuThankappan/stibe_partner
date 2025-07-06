import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stibe_partner/models/service_product.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class ProductManagementWidget extends StatefulWidget {
  final List<ServiceProduct> initialProducts;
  final Function(List<ServiceProduct>) onProductsChanged;

  const ProductManagementWidget({
    Key? key,
    required this.initialProducts,
    required this.onProductsChanged,
  }) : super(key: key);

  @override
  State<ProductManagementWidget> createState() => _ProductManagementWidgetState();
}

class _ProductManagementWidgetState extends State<ProductManagementWidget> {
  late List<ServiceProduct> _products;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _products = List.from(widget.initialProducts);
  }

  void _addNewProduct() {
    final newProduct = ServiceProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
    );
    
    setState(() {
      _products.add(newProduct);
    });
    
    widget.onProductsChanged(_products);
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
    
    widget.onProductsChanged(_products);
  }

  void _updateProductName(int index, String name) {
    if (index < _products.length) {
      setState(() {
        _products[index] = _products[index].copyWith(name: name);
      });
      
      widget.onProductsChanged(_products);
    }
  }

  void _updateProductDescription(int index, String description) {
    if (index < _products.length) {
      setState(() {
        _products[index] = _products[index].copyWith(description: description);
      });
      
      widget.onProductsChanged(_products);
    }
  }

  Future<void> _pickProductImages(int index) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFiles.isNotEmpty && index < _products.length) {
        final List<File> newImages = pickedFiles.map((file) => File(file.path)).toList();
        
        setState(() {
          _products[index] = _products[index].copyWith(
            localImageFiles: [..._products[index].localImageFiles, ...newImages],
            isUploaded: false,
          );
        });
        
        widget.onProductsChanged(_products);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickSingleProductImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null && index < _products.length) {
        setState(() {
          _products[index] = _products[index].addLocalImage(File(pickedFile.path));
        });
        
        widget.onProductsChanged(_products);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeProductImages(int index) {
    if (index < _products.length) {
      setState(() {
        _products[index] = _products[index].copyWith(
          imageUrls: [],
          localImageFiles: [],
          isUploaded: true,
        );
      });
      
      widget.onProductsChanged(_products);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Products Used',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addNewProduct,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Product'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Products List
        if (_products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No products added yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add products used in this service with names and images',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildProductCard(index),
          ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    final product = _products[index];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with delete button
          Row(
            children: [
              Icon(
                Icons.inventory_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Product ${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeProduct(index),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Product Image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [          // Images Section
          _buildProductImagesSection(index, product),
              
              const SizedBox(width: 16),
              
              // Product Details
              Expanded(
                child: Column(
                  children: [
                    // Product Name
                    TextFormField(
                      initialValue: product.name,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        hintText: 'e.g., Premium Hair Oil',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) => _updateProductName(index, value),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Product Description (Optional)
                    TextFormField(
                      initialValue: product.description ?? '',
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'e.g., Nourishing formula for all hair types',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      onChanged: (value) => _updateProductDescription(index, value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Image actions
          const SizedBox(height: 12),
          _buildImageActions(index, product),
        ],
      ),
    );
  }

  Widget _buildProductImagesSection(int index, ServiceProduct product) {
    if (!product.hasImages) {
      // No images - show placeholder with add button
      return GestureDetector(
        onTap: () => _pickSingleProductImage(index),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _buildImagePlaceholder(),
        ),
      );
    }

    // Has images - show grid
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Show all uploaded images
          ...product.imageUrls.asMap().entries.map((entry) {
            final imageIndex = entry.key;
            final imageUrl = entry.value;
            return _buildImageThumbnail(
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              ),
              onRemove: () => _removeUploadedImage(index, imageIndex),
              status: 'SAVED',
              statusColor: Colors.green,
            );
          }),
          // Show all local images
          ...product.localImageFiles.asMap().entries.map((entry) {
            final imageIndex = entry.key;
            final imageFile = entry.value;
            return _buildImageThumbnail(
              child: Image.file(
                imageFile,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              onRemove: () => _removeLocalImage(index, imageIndex),
              status: product.isUploaded ? 'SAVED' : 'NEW',
              statusColor: product.isUploaded ? Colors.green : Colors.orange,
            );
          }),
          // Add button
          if (product.totalImageCount < 5) // Limit to 5 images per product
            _buildAddImageButton(index),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail({
    required Widget child,
    required VoidCallback onRemove,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
          // Status badge
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(int index) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 20,
              color: Colors.grey.shade500,
            ),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageActions(int index, ServiceProduct product) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => _pickSingleProductImage(index),
          icon: const Icon(Icons.add_photo_alternate, size: 16),
          label: const Text('Add Image'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _pickProductImages(index),
          icon: const Icon(Icons.photo_library, size: 16),
          label: const Text('Add Multiple'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
        if (product.hasImages) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _removeProductImages(index),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Remove All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  void _showImagePickerOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickSingleProductImage(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose Multiple'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProductImages(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null && index < _products.length) {
        setState(() {
          _products[index] = _products[index].addLocalImage(File(pickedFile.path));
        });
        
        widget.onProductsChanged(_products);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeLocalImage(int productIndex, int imageIndex) {
    if (productIndex < _products.length) {
      setState(() {
        _products[productIndex] = _products[productIndex].removeLocalImage(imageIndex);
      });
      
      widget.onProductsChanged(_products);
    }
  }

  void _removeUploadedImage(int productIndex, int imageIndex) {
    if (productIndex < _products.length) {
      setState(() {
        _products[productIndex] = _products[productIndex].removeUploadedImage(imageIndex);
      });
      
      widget.onProductsChanged(_products);
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 20,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 2),
          Text(
            'Add',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
