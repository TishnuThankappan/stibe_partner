import 'package:flutter/material.dart';
import 'package:stibe_partner/api/salon_service.dart';

import 'package:stibe_partner/screens/salons/salon_detail_screen_new.dart' show SalonDetailScreen;

class SalonServiceTestScreen extends StatefulWidget {
  const SalonServiceTestScreen({super.key});

  @override
  State<SalonServiceTestScreen> createState() => _SalonServiceTestScreenState();
}

class _SalonServiceTestScreenState extends State<SalonServiceTestScreen> {
  final SalonService _salonService = SalonService();
  List<SalonDto> _salons = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading salons...';
    });

    try {
      final salons = await _salonService.getMySalons();
      setState(() {
        _salons = salons;
        _statusMessage = 'Loaded ${salons.length} salon(s)';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading salons: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSalonById(int salonId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing getSalonById($salonId)...';
    });

    try {
      final salon = await _salonService.getSalonById(salonId);
      setState(() {
        _statusMessage = '✅ getSalonById() works! Salon: ${salon.name}';
        _isLoading = false;
      });

      // Navigate to salon detail screen to test it
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salon: salon.toJson()),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ getSalonById() failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestSalon() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test salon...';
    });

    try {
      final testSalonRequest = CreateSalonRequest(
        name: 'Test Salon ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test salon created by the salon service test',
        address: '123 Test Street',
        city: 'Test City',
        state: 'Test State',
        zipCode: '12345',
        phoneNumber: '+1234567890',
        email: 'test@testsalon.com',
        openingTime: '09:00:00',
        closingTime: '18:00:00',
        useCurrentLocation: false,
        currentLatitude: 37.7749,
        currentLongitude: -122.4194,
      );

      final createdSalon = await _salonService.createSalon(testSalonRequest);
      setState(() {
        _statusMessage = '✅ Test salon created successfully! ID: ${createdSalon.id}';
        _isLoading = false;
      });
      
      // Reload salons to show the new one
      _loadSalons();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Failed to create test salon: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testToggleStatus(int salonId, bool currentStatus) async {

    try {
      final updatedSalon = await _salonService.toggleSalonStatus(salonId, !currentStatus);
      setState(() {
        _statusMessage = '✅ toggleSalonStatus() works! New status: ${updatedSalon.isActive}';
        _isLoading = false;
      });
      
      // Reload salons to show updated status
      _loadSalons();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ toggleSalonStatus() failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Service Test'),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
            stops: const [0.1, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅') 
                      ? Colors.green.shade50 
                      : _statusMessage.contains('❌')
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: _statusMessage.contains('✅') 
                        ? Colors.green.shade200 
                        : _statusMessage.contains('❌')
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                    width: 1.5,
                  ),
                ),                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _statusMessage.contains('✅') 
                              ? Icons.check_circle 
                              : _statusMessage.contains('❌')
                                  ? Icons.error
                                  : Icons.info_outline,
                          color: _statusMessage.contains('✅') 
                              ? Colors.green.shade600 
                              : _statusMessage.contains('❌')
                                  ? Colors.red.shade600
                                  : Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage.isEmpty ? 'Ready to test' : _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('✅') 
                            ? Colors.green.shade700 
                            : _statusMessage.contains('❌')
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.deepPurple,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),              // Test Buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadSalons,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load Salons'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _createTestSalon,
                            icon: const Icon(Icons.add_business),
                            label: const Text('Create Test Salon'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),              // Salons List Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.store_mall_directory,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Available Salons',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_salons.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_salons.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),              if (_salons.isEmpty && !_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.store_mall_directory_outlined,
                          size: 56,
                          color: Colors.deepPurple.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Salons Found',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a new salon to get started with testing the salon service functions',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createTestSalon,
                        icon: const Icon(Icons.add_business),
                        label: const Text('Create Test Salon'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.builder(
                        itemCount: _salons.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final salon = _salons[index];
                          return Column(
                            children: [
                              if (index > 0) 
                                Divider(height: 1, color: Colors.grey.shade200),
                              InkWell(
                                onTap: () => _testSalonById(salon.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      // Salon Status Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: salon.isActive 
                                                ? [Colors.green.shade300, Colors.green.shade600]
                                                : [Colors.red.shade300, Colors.red.shade600],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: salon.isActive 
                                                  ? Colors.green.withOpacity(0.3)
                                                  : Colors.red.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.store,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Salon Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              salon.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'ID: ${salon.id}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    salon.address,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: salon.isActive 
                                                    ? Colors.green.shade100
                                                    : Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                salon.isActive ? 'Active' : 'Inactive',
                                                style: TextStyle(
                                                  color: salon.isActive
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Action Buttons
                                      Row(
                                        children: [
                                          // View Button
                                          IconButton(
                                            onPressed: () => _testSalonById(salon.id),
                                            icon: Icon(
                                              Icons.visibility,
                                              color: Colors.deepPurple.shade400,
                                            ),
                                            tooltip: 'View Details',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.deepPurple.shade50,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Toggle Status Button
                                          IconButton(
                                            onPressed: () => _testToggleStatus(salon.id, salon.isActive),
                                            icon: Icon(
                                              salon.isActive ? Icons.pause_circle : Icons.play_circle,
                                              color: salon.isActive ? Colors.orange : Colors.green,
                                            ),
                                            tooltip: salon.isActive ? 'Deactivate' : 'Activate',
                                            style: IconButton.styleFrom(
                                              backgroundColor: salon.isActive 
                                                  ? Colors.orange.shade50
                                                  : Colors.green.shade50,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
