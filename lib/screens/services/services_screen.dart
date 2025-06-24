import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/models/service_model.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Service> _services = [];
  List<ServicePackage> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _services = _getMockServices();
      _packages = _getMockPackages();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Services',
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildServicesTab(),
                      _buildPackagesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Tab(text: 'Services'),
          Tab(text: 'Packages'),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return _services.isEmpty
        ? _buildEmptyState(
            icon: Icons.spa_outlined,
            title: 'No Services Yet',
            message: 'Add your first service to get started',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return _buildServiceCard(service);
            },
          );
  }

  Widget _buildPackagesTab() {
    return _packages.isEmpty
        ? _buildEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Packages Yet',
            message: 'Create your first service package',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _packages.length,
            itemBuilder: (context, index) {
              final package = _packages[index];
              return _buildPackageCard(package);
            },
          );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: service.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    // TODO: Implement service activation toggle
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: '\$${service.price.toStringAsFixed(2)}',
                ),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: '${service.durationMinutes} min',
                ),
                _buildInfoChip(
                  icon: Icons.people_outline,
                  label: '${service.assignedStaffIds?.length ?? 0} Staff',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              service.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit service
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement delete service
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(ServicePackage package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${package.services.length} services',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: package.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    // TODO: Implement package activation toggle
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: '\$${package.price.toStringAsFixed(2)}',
                ),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: '${package.totalDurationMinutes} min',
                ),
                _buildInfoChip(
                  icon: Icons.savings_outlined,
                  label: 'Save 15%',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              package.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Included Services:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: package.services.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit package
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement delete package
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement add new service/package
            },
            icon: const Icon(Icons.add),
            label: Text(_tabController.index == 0 ? 'Add Service' : 'Add Package'),
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
  
  // Mock data generators
  List<Service> _getMockServices() {
    return [
      Service(
        id: '1',
        name: 'Haircut & Styling',
        description: 'Professional haircut and styling service with consultation.',
        price: 50.0,
        durationMinutes: 45,
        assignedStaffIds: ['staff1', 'staff2'],
        category: 'Hair',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '2',
        name: 'Full Color Treatment',
        description: 'Complete hair coloring service with premium products.',
        price: 120.0,
        durationMinutes: 120,
        assignedStaffIds: ['staff1'],
        category: 'Hair',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '3',
        name: 'Manicure',
        description: 'Nail shaping, cuticle care, massage, and polish application.',
        price: 35.0,
        durationMinutes: 30,
        assignedStaffIds: ['staff3', 'staff4'],
        category: 'Nails',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Service(
        id: '4',
        name: 'Facial Treatment',
        description: 'Deep cleansing facial with premium skincare products.',
        price: 85.0,
        durationMinutes: 60,
        assignedStaffIds: ['staff5'],
        category: 'Skin',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Service(
        id: '5',
        name: 'Massage Therapy',
        description: 'Relaxing full body massage to relieve stress and tension.',
        price: 75.0,
        durationMinutes: 60,
        assignedStaffIds: ['staff6'],
        category: 'Body',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<ServicePackage> _getMockPackages() {
    final services = _getMockServices();
    
    return [
      ServicePackage(
        id: 'pkg1',
        name: 'Complete Hair Makeover',
        description: 'Transform your look with our complete hair package including cut, color, and styling.',
        price: 150.0,
        totalDurationMinutes: 180,
        services: [services[0], services[1]],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ServicePackage(
        id: 'pkg2',
        name: 'Spa Day Package',
        description: 'Treat yourself to a day of relaxation with facial, massage, and nail care.',
        price: 175.0,
        totalDurationMinutes: 150,
        services: [services[2], services[3], services[4]],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}
