import 'package:flutter/material.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/screens/salons/salon_detail_screen.dart';

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
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _statusMessage.contains('✅') 
                      ? Colors.green.shade200 
                      : _statusMessage.contains('❌')
                          ? Colors.red.shade200
                          : Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusMessage.isEmpty ? 'Ready to test' : _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('✅') 
                          ? Colors.green.shade700 
                          : _statusMessage.contains('❌')
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Test Buttons
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Salons List
            const Text(
              'Available Salons:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_salons.isEmpty && !_isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.store_mall_directory_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No salons found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a salon first to test the salon service functions',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _salons.length,
                  itemBuilder: (context, index) {
                    final salon = _salons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: salon.isActive 
                              ? Colors.green.shade100 
                              : Colors.red.shade100,
                          child: Icon(
                            Icons.store,
                            color: salon.isActive 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                          ),
                        ),
                        title: Text(
                          salon.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${salon.id} • ${salon.address}'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: salon.isActive ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                salon.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                _testSalonById(salon.id);
                                break;
                              case 'toggle':
                                _testToggleStatus(salon.id, salon.isActive);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    salon.isActive ? Icons.pause_circle : Icons.play_circle,
                                    size: 18,
                                    color: salon.isActive ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(salon.isActive ? 'Deactivate' : 'Activate'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
