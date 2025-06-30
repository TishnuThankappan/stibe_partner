import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class ServiceTemplatesScreen extends StatefulWidget {
  final int salonId;
  final String salonName;

  const ServiceTemplatesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<ServiceTemplatesScreen> createState() => _ServiceTemplatesScreenState();
}

class _ServiceTemplatesScreenState extends State<ServiceTemplatesScreen> {
  final ServiceManagementService _serviceService = ServiceManagementService();
  
  bool _isLoading = false;

  final Map<String, List<Map<String, dynamic>>> _serviceTemplates = {
    'Hair Salon': [
      {
        'name': 'Haircut & Style',
        'description': 'Professional haircut with styling',
        'price': 65.0,
        'duration': 60,
      },
      {
        'name': 'Hair Color',
        'description': 'Full hair coloring service',
        'price': 120.0,
        'duration': 120,
      },
      {
        'name': 'Hair Highlights',
        'description': 'Professional highlighting service',
        'price': 85.0,
        'duration': 90,
      },
      {
        'name': 'Blowout',
        'description': 'Professional hair washing and styling',
        'price': 45.0,
        'duration': 45,
      },
      {
        'name': 'Hair Treatment',
        'description': 'Deep conditioning hair treatment',
        'price': 55.0,
        'duration': 30,
      },
    ],
    'Nail Salon': [
      {
        'name': 'Classic Manicure',
        'description': 'Traditional manicure with polish',
        'price': 30.0,
        'duration': 45,
      },
      {
        'name': 'Gel Manicure',
        'description': 'Long-lasting gel polish manicure',
        'price': 45.0,
        'duration': 60,
      },
      {
        'name': 'Classic Pedicure',
        'description': 'Relaxing foot care and polish',
        'price': 40.0,
        'duration': 60,
      },
      {
        'name': 'Gel Pedicure',
        'description': 'Long-lasting gel polish pedicure',
        'price': 55.0,
        'duration': 75,
      },
      {
        'name': 'Nail Art',
        'description': 'Custom nail art design',
        'price': 25.0,
        'duration': 30,
      },
    ],
    'Spa Services': [
      {
        'name': 'Relaxation Massage',
        'description': 'Full body relaxation massage',
        'price': 90.0,
        'duration': 60,
      },
      {
        'name': 'Deep Tissue Massage',
        'description': 'Therapeutic deep tissue massage',
        'price': 110.0,
        'duration': 60,
      },
      {
        'name': 'Facial Treatment',
        'description': 'Cleansing and rejuvenating facial',
        'price': 75.0,
        'duration': 60,
      },
      {
        'name': 'Body Wrap',
        'description': 'Detoxifying body wrap treatment',
        'price': 85.0,
        'duration': 90,
      },
      {
        'name': 'Hot Stone Massage',
        'description': 'Relaxing hot stone therapy',
        'price': 125.0,
        'duration': 90,
      },
    ],
    'Beauty Services': [
      {
        'name': 'Eyebrow Shaping',
        'description': 'Professional eyebrow shaping and grooming',
        'price': 25.0,
        'duration': 30,
      },
      {
        'name': 'Eyelash Extensions',
        'description': 'Individual eyelash extension application',
        'price': 120.0,
        'duration': 120,
      },
      {
        'name': 'Makeup Application',
        'description': 'Professional makeup application',
        'price': 65.0,
        'duration': 45,
      },
      {
        'name': 'Facial Waxing',
        'description': 'Hair removal for face area',
        'price': 35.0,
        'duration': 30,
      },
      {
        'name': 'Lash Tint',
        'description': 'Eyelash tinting service',
        'price': 20.0,
        'duration': 20,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Service Templates',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Start Templates',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose from pre-made service templates to quickly set up your salon. You can customize prices and details after adding them.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._serviceTemplates.entries.map((entry) => _buildTemplateCategory(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCategory(String categoryName, List<Map<String, dynamic>> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ...services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                final isLast = index == services.length - 1;
                
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.spa, color: AppColors.primary),
                      ),
                      title: Text(
                        service['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['description']),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$${service['price'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${service['duration']} min',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: _isLoading 
                            ? null 
                            : () => _addServiceFromTemplate(service),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 36),
                        ),
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading 
                        ? null 
                        : () => _addAllServicesFromCategory(categoryName, services),
                    icon: const Icon(Icons.add_box),
                    label: Text('Add All $categoryName Services'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _addServiceFromTemplate(Map<String, dynamic> template) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _serviceService.createService(
        widget.salonId,
        CreateServiceRequest(
          name: template['name'],
          description: template['description'],
          price: template['price'].toDouble(),
          durationInMinutes: template['duration'],
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template['name']} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${template['name']}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addAllServicesFromCategory(String categoryName, List<Map<String, dynamic>> services) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add All $categoryName Services'),
        content: Text(
          'This will add all ${services.length} services from the $categoryName category to your salon.\n\nYou can edit the details later if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    int successCount = 0;
    int errorCount = 0;

    try {
      for (final template in services) {
        try {
          await _serviceService.createService(
            widget.salonId,
            CreateServiceRequest(
              name: template['name'],
              description: template['description'],
              price: template['price'].toDouble(),
              durationInMinutes: template['duration'],
            ),
          );
          successCount++;
        } catch (e) {
          errorCount++;
          print('Error adding service ${template['name']}: $e');
        }
      }

      if (mounted) {
        if (errorCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All $successCount services added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successCount services added, $errorCount failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
