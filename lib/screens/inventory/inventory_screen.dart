import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _activeFilter = 'All';

  // Mock data
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInventory();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _products = _getMockProducts();
      _filteredProducts = _products;
      _orders = _getMockOrders();
      _isLoading = false;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _activeFilter == 'All'
            ? _products
            : _products.where((product) => _getCategoryText(product) == _activeFilter).toList();
      } else {
        _filteredProducts = _products
            .where((product) => 
                product.name.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query) ||
                product.brand.toLowerCase().contains(query))
            .where((product) => _activeFilter == 'All' || _getCategoryText(product) == _activeFilter)
            .toList();
      }
    });
  }

  String _getCategoryText(Product product) {
    if (product.stockLevel == 0) {
      return 'Out of Stock';
    } else if (product.stockLevel <= product.reorderLevel) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inventory',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsTab(),
                      _buildOrdersTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _tabController.index == 0 ? 'Search products...' : 'Search orders...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'Orders'),
        ],
        onTap: (index) {
          // Reset filter when switching tabs
          setState(() {
            _activeFilter = 'All';
            _filterProducts();
          });
        },
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: _filteredProducts.isEmpty
              ? _buildEmptyState()
              : _buildProductsList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: filters.map((filter) {
          final isActive = _activeFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) _setFilter(filter);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final stockLevel = _getCategoryText(product);
    Color stockColor;
    
    switch (stockLevel) {
      case 'Out of Stock':
        stockColor = AppColors.error;
        break;
      case 'Low Stock':
        stockColor = AppColors.warning;
        break;
      default:
        stockColor = AppColors.success;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.brand,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: stockColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              stockLevel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: stockColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'In stock: ${product.stockLevel}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // TODO: Implement edit product
                        break;
                      case 'delete':
                        // TODO: Implement delete product
                        break;
                      case 'reorder':
                        // TODO: Implement reorder product
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'reorder',
                      child: Text('Reorder'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement adjust stock
                      _showAdjustStockDialog(product);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Adjust Stock'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.stockLevel > 0
                        ? () {
                            // TODO: Implement use product
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    label: const Text('Use Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusColor = AppColors.success;
        break;
      case 'Pending':
        statusColor = AppColors.warning;
        break;
      case 'Processing':
        statusColor = AppColors.info;
        break;
      default:
        statusColor = AppColors.error;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Supplier: ${order.supplier}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Items:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Date: ${_formatDate(order.orderDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (order.deliveryDate != null)
                      Text(
                        'Delivery Date: ${_formatDate(order.deliveryDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Implement view order details
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      color: AppColors.primary,
                      tooltip: 'View Details',
                    ),
                    if (order.status == 'Pending' || order.status == 'Processing')
                      IconButton(
                        onPressed: () {
                          // TODO: Implement update order status
                        },
                        icon: const Icon(Icons.edit_outlined),
                        color: AppColors.secondary,
                        tooltip: 'Edit Order',
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isProductsTab = _tabController.index == 0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProductsTab ? Icons.inventory_2_outlined : Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isProductsTab
                ? 'No Products Found'
                : 'No Orders Found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : isProductsTab
                    ? 'Add your first product to get started'
                    : 'Your orders will appear here',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              isProductsTab ? _showAddItemDialog() : _showAddOrderDialog();
            },
            icon: const Icon(Icons.add),
            label: Text(isProductsTab ? 'Add Product' : 'Create Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final reorderLevelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter product description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    hintText: 'Enter brand name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter product price',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Stock',
                          hintText: 'Enter quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: reorderLevelController,
                        decoration: const InputDecoration(
                          labelText: 'Reorder Level',
                          hintText: 'Min. quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement add product
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Product'),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrderDialog() {
    // TODO: Implement add order dialog
  }

  void _showAdjustStockDialog(Product product) {
    final stockController = TextEditingController(text: product.stockLevel.toString());
    int newStock = product.stockLevel;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adjust Stock: ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Current stock level:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.stockLevel}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (newStock > 0) {
                            setState(() {
                              newStock--;
                              stockController.text = newStock.toString();
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        iconSize: 36,
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: stockController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          onChanged: (value) {
                            final parsedValue = int.tryParse(value);
                            if (parsedValue != null && parsedValue >= 0) {
                              setState(() {
                                newStock = parsedValue;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            newStock++;
                            stockController.text = newStock.toString();
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        iconSize: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reason for adjustment:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'Inventory Count',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Inventory Count',
                        child: Text('Inventory Count'),
                      ),
                      DropdownMenuItem(
                        value: 'New Shipment',
                        child: Text('New Shipment'),
                      ),
                      DropdownMenuItem(
                        value: 'Damaged',
                        child: Text('Damaged'),
                      ),
                      DropdownMenuItem(
                        value: 'Used',
                        child: Text('Used'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement adjust stock
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  // Mock data generators
  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Shampoo - Professional',
        description: 'Salon-quality shampoo for all hair types.',
        brand: 'LuxeHair',
        price: 18.99,
        stockLevel: 24,
        reorderLevel: 10,
        category: 'Hair Care',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Product(
        id: '2',
        name: 'Conditioner - Color Protect',
        description: 'Protects color-treated hair while conditioning.',
        brand: 'LuxeHair',
        price: 20.99,
        stockLevel: 18,
        reorderLevel: 10,
        category: 'Hair Care',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Product(
        id: '3',
        name: 'Hair Styling Gel - Strong Hold',
        description: 'Professional strong hold styling gel.',
        brand: 'StyleMaster',
        price: 15.50,
        stockLevel: 8,
        reorderLevel: 10,
        category: 'Hair Styling',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Product(
        id: '4',
        name: 'Facial Cleanser - Gentle',
        description: 'Gentle facial cleanser for sensitive skin.',
        brand: 'PureSkin',
        price: 22.00,
        stockLevel: 12,
        reorderLevel: 8,
        category: 'Skin Care',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Product(
        id: '5',
        name: 'Nail Polish - Ruby Red',
        description: 'Long-lasting professional nail polish.',
        brand: 'NailPro',
        price: 9.99,
        stockLevel: 0,
        reorderLevel: 5,
        category: 'Nail Care',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Product(
        id: '6',
        name: 'Massage Oil - Lavender',
        description: 'Relaxing lavender massage oil.',
        brand: 'SpaEssentials',
        price: 16.75,
        stockLevel: 5,
        reorderLevel: 3,
        category: 'Massage',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  List<Order> _getMockOrders() {
    return [
      Order(
        id: '1001',
        supplier: 'Beauty Wholesale Inc.',
        orderDate: DateTime.now().subtract(const Duration(days: 15)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Delivered',
        totalAmount: 357.85,
        items: [
          OrderItem(
            name: 'Shampoo - Professional',
            quantity: 10,
            price: 14.99,
          ),
          OrderItem(
            name: 'Conditioner - Color Protect',
            quantity: 10,
            price: 16.99,
          ),
          OrderItem(
            name: 'Hair Styling Gel - Strong Hold',
            quantity: 5,
            price: 11.99,
          ),
        ],
      ),
      Order(
        id: '1002',
        supplier: 'SalonSupply Co.',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryDate: null,
        status: 'Processing',
        totalAmount: 245.50,
        items: [
          OrderItem(
            name: 'Facial Cleanser - Gentle',
            quantity: 8,
            price: 18.00,
          ),
          OrderItem(
            name: 'Massage Oil - Lavender',
            quantity: 5,
            price: 13.50,
          ),
        ],
      ),
      Order(
        id: '1003',
        supplier: 'NailPro Distributors',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryDate: null,
        status: 'Pending',
        totalAmount: 89.91,
        items: [
          OrderItem(
            name: 'Nail Polish - Ruby Red',
            quantity: 6,
            price: 7.99,
          ),
          OrderItem(
            name: 'Nail Polish - Ocean Blue',
            quantity: 5,
            price: 7.99,
          ),
        ],
      ),
    ];
  }
}

// Models
class Product {
  final String id;
  final String name;
  final String description;
  final String brand;
  final double price;
  final int stockLevel;
  final int reorderLevel;
  final String category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.price,
    required this.stockLevel,
    required this.reorderLevel,
    required this.category,
    required this.createdAt,
  });
}

class Order {
  final String id;
  final String supplier;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.supplier,
    required this.orderDate,
    this.deliveryDate,
    required this.status,
    required this.totalAmount,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
