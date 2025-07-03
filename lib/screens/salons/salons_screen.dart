import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';

import 'package:stibe_partner/screens/salons/add_salon_screen.dart';
import 'package:stibe_partner/screens/salons/salon_detail_screen_new.dart';
import 'package:stibe_partner/screens/salons/salon_image_preview_screen.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/utils/debug_helper.dart';

class SalonsScreen extends StatefulWidget {
  const SalonsScreen({super.key});

  @override
  State<SalonsScreen> createState() => _SalonsScreenState();
}

class _SalonsScreenState extends State<SalonsScreen> {
  bool _isLoading = true;
  List<SalonDto> _salons = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final salonService = SalonService();
      final salons = await salonService.getMySalons();
      
      // Debug logging to see what data we're getting
      print('🐛 DEBUG: Loaded ${salons.length} salons from API');
      await DebugHelper.testSalonData();
      
      setState(() {
        _salons = salons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading salons: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshSalons() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSalons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Salons',
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSalonScreen(),
                ),
              ).then((_) => _refreshSalons());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshSalons,
              child: _salons.isEmpty
                  ? _buildEmptyState()
                  : _buildSalonsList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Salons Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your salon empire by adding your first location.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSalonScreen(),
                  ),
                ).then((_) => _refreshSalons());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Salon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _salons.length,
      itemBuilder: (context, index) {
        final salon = _salons[index];
        return _buildSalonCard(salon);
      },
    );
  }

  Widget _buildSalonCard(SalonDto salon) {
    return Opacity(
      opacity: salon.isActive ? 1.0 : 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: salon.isActive ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalonDetailScreen(salon: salon.toJson()),
                ),
              ).then((_) => _refreshSalons());
            },
            onLongPress: () => _showSalonContextMenu(context, salon),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Image
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Image or placeholder
                    GestureDetector(
                      onTap: () {
                        if (salon.imageUrls.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalonImagePreviewScreen(
                                imageUrls: salon.imageUrls,
                                initialIndex: 0,
                                salonName: salon.name,
                              ),
                            ),
                          );
                        } else if (salon.profilePictureUrl != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalonImagePreviewScreen(
                                imageUrls: [salon.profilePictureUrl!],
                                initialIndex: 0,
                                salonName: salon.name,
                              ),
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: salon.imageUrls.isNotEmpty
                            ? Hero(
                                tag: 'salon_image_${salon.name}_0',
                                child: Image.network(
                                  salon.imageUrls.first,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildImagePlaceholder();
                                  },
                                ),
                              )
                            : salon.profilePictureUrl != null
                                ? Hero(
                                    tag: 'salon_image_${salon.name}_0',
                                    child: Image.network(
                                      salon.profilePictureUrl!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildImagePlaceholder();
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return _buildImagePlaceholder();
                                      },
                                    ),
                                  )
                                : _buildImagePlaceholder(),
                      ),
                    ),
                    
                    // Status indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: salon.isActive ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              salon.isActive ? Icons.check_circle : Icons.pause_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              salon.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Image count indicator (if multiple images or has images)
                    if (salon.imageUrls.isNotEmpty || salon.profilePictureUrl != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_camera,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                salon.imageUrls.length > 1 
                                    ? '${salon.imageUrls.length}'
                                    : salon.imageUrls.isNotEmpty 
                                        ? '1'
                                        : '1',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Tap hint overlay (shows user can tap to view)
                    if (salon.imageUrls.isNotEmpty || salon.profilePictureUrl != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Status badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: salon.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          salon.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Salon Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Profile Picture Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: salon.profilePictureUrl != null && 
                                          salon.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(salon.profilePictureUrl!)
                              : null,
                          child: salon.profilePictureUrl == null || 
                                 salon.profilePictureUrl!.isEmpty
                              ? Icon(
                                  Icons.store,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salon.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${salon.address}, ${salon.city}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Remove hardcoded rating until real rating data is available
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: salon.isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: salon.isActive ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            salon.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: salon.isActive ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${salon.address}, ${salon.city}, ${salon.state}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Business Hours
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${salon.openingTime} - ${salon.closingTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: salon.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: salon.isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                salon.isActive ? Icons.store : Icons.store_mall_directory_outlined,
                                size: 12,
                                color: salon.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                salon.isActive ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: salon.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalonDetailScreen(
                                    salon: salon.toJson(),
                                    initialTab: 1, // Services tab
                                  ),
                                ),
                              ).then((_) => _refreshSalons());
                            },
                            icon: const Icon(Icons.spa, size: 16),
                            label: const Text('Services'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalonDetailScreen(
                                    salon: salon.toJson(),
                                    initialTab: 2, // Staff tab
                                  ),
                                ),
                              ).then((_) => _refreshSalons());
                            },
                            icon: const Icon(Icons.people, size: 16),
                            label: const Text('Staff'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )); // Close Opacity
  }

  void _showSalonContextMenu(BuildContext context, SalonDto salon) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: salon.profilePictureUrl != null
                        ? NetworkImage(salon.profilePictureUrl!)
                        : null,
                    child: salon.profilePictureUrl == null
                        ? const Icon(Icons.store, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${salon.city}, ${salon.state}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Actions
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Salon'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalonDetailScreen(salon: salon.toJson()),
                  ),
                ).then((_) => _refreshSalons());
              },
            ),
            ListTile(
              leading: Icon(
                salon.isActive ? Icons.pause_circle : Icons.play_circle,
                color: salon.isActive ? Colors.orange : Colors.green,
              ),
              title: Text(salon.isActive ? 'Deactivate' : 'Activate'),
              onTap: () {
                Navigator.pop(context);
                _toggleSalonStatusFromList(salon);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Salon',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteSalonFromList(salon);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSalonStatusFromList(SalonDto salon) async {
    try {
      final salonService = SalonService();
      await salonService.toggleSalonStatus(salon.id, !salon.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Salon ${!salon.isActive ? "activated" : "deactivated"} successfully!',
            ),
            backgroundColor: !salon.isActive ? Colors.green : Colors.orange,
          ),
        );
        _refreshSalons();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSalonFromList(SalonDto salon) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Salon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete "${salon.name}"?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final salonService = SalonService();
      await salonService.deleteSalon(salon.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salon deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshSalons();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting salon: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
