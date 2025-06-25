import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/services/location_service.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/widgets/location_picker.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  LocationResult? _lastResult;
  final List<LocationResult> _locationHistory = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Location Service Test',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Picker Demo
            const Text(
              'Location Picker Widget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            LocationPicker(
              title: 'Test Location Picker',
              subtitle: 'This demonstrates the location picker widget with GPS and demo options.',
              onLocationSelected: (latitude, longitude, isDemo) {
                setState(() {
                  _lastResult = LocationResult.success(
                    latitude: latitude,
                    longitude: longitude,
                    isDemo: isDemo,
                  );
                  _locationHistory.insert(0, _lastResult!);
                  if (_locationHistory.length > 10) {
                    _locationHistory.removeLast();
                  }
                });
              },
              showDemoOption: true,
            ),
            
            const SizedBox(height: 32),
            
            // Manual Location Test
            const Text(
              'Manual Location Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test location services directly:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testLocationService,
                            icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.gps_fixed),
                            label: Text(_isLoading ? 'Getting Location...' : 'Get Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _testPermissions,
                            icon: const Icon(Icons.security),
                            label: const Text('Check Permissions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Location History
            if (_locationHistory.isNotEmpty) ...[
              const Text(
                'Location History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._locationHistory.map((result) => _buildLocationHistoryItem(result)),
            ],
            
            const SizedBox(height: 32),
            
            // Service Info
            const Text(
              'Service Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('GPS Package', 'geolocator: ^11.0.0'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Permissions', 'Android: ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION'),
                    const SizedBox(height: 8),
                    _buildInfoRow('iOS Permissions', 'NSLocationWhenInUseUsageDescription'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Backend Integration', 'Mock Location Service with Indian Cities'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Features', 'Real GPS, Demo Mode, Distance Calculation'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHistoryItem(LocationResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result.isDemo 
            ? AppColors.accent.withOpacity(0.2)
            : AppColors.success.withOpacity(0.2),
          child: Icon(
            result.isDemo ? Icons.location_city : Icons.my_location,
            color: result.isDemo ? AppColors.accent : AppColors.success,
            size: 20,
          ),
        ),
        title: Text(
          result.isDemo ? 'Demo Location' : 'GPS Location',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lat: ${result.latitude?.toStringAsFixed(6) ?? 'N/A'}'),
            Text('Lng: ${result.longitude?.toStringAsFixed(6) ?? 'N/A'}'),
            if (result.accuracy != null && !result.isDemo)
              Text('Accuracy: ±${result.accuracy!.toStringAsFixed(0)}m'),
          ],
        ),
        trailing: result.isDemo 
          ? const Icon(Icons.info_outline, color: AppColors.accent)
          : const Icon(Icons.check_circle, color: AppColors.success),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _testLocationService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await LocationService.getCurrentLocation();
      
      setState(() {
        _lastResult = result;
        _locationHistory.insert(0, result);
        if (_locationHistory.length > 10) {
          _locationHistory.removeLast();
        }
        _isLoading = false;
      });

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location obtained: ${result.latitude?.toStringAsFixed(6)}, ${result.longitude?.toStringAsFixed(6)}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to get location'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _testPermissions() async {
    final serviceEnabled = await LocationService.isLocationServiceEnabled();
    final permission = await LocationService.checkLocationPermission();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Enabled: ${serviceEnabled ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Permission: ${permission.name}'),
            const SizedBox(height: 16),
            if (!serviceEnabled)
              const Text(
                'Location services are disabled. Please enable them in device settings.',
                style: TextStyle(color: AppColors.error),
              ),
            if (permission.name == 'denied' || permission.name == 'deniedForever')
              const Text(
                'Location permission is not granted. Please grant permission to use location features.',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        actions: [
          if (!serviceEnabled)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LocationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          if (permission.name == 'deniedForever')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LocationService.openAppSettings();
              },
              child: const Text('App Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
