import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/services/location_service.dart';

class LocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude, bool isDemo) onLocationSelected;
  final bool showDemoOption;
  final String? title;
  final String? subtitle;

  const LocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
    this.showDemoOption = true,
    this.title,
    this.subtitle,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  double? _latitude;
  double? _longitude;
  bool _isDemo = false;
  bool _isLoading = false;
  String? _error;
  double? _accuracy;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LocationService.getCurrentLocationWithDialog(
        context,
        timeout: const Duration(seconds: 30),
      );

      if (result.isSuccess && result.hasLocation) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _accuracy = result.accuracy;
          _isDemo = false;
          _isLoading = false;
        });

        widget.onLocationSelected(_latitude!, _longitude!, false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location obtained successfully${_accuracy != null ? ' (±${_accuracy!.toStringAsFixed(0)}m)' : ''}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _error = result.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _useDemoLocation() {
    final result = LocationService.getDemoLocation();
    
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _accuracy = result.accuracy;
      _isDemo = true;
      _error = null;
    });

    widget.onLocationSelected(_latitude!, _longitude!, true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo location set to New York City'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openLocationSettings() async {
    bool opened = await LocationService.openLocationSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open location settings'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openAppSettings() async {
    bool opened = await LocationService.openAppSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open app settings'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Current location display
            if (_latitude != null && _longitude != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isDemo ? AppColors.accent.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isDemo ? AppColors.accent.withOpacity(0.3) : AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isDemo ? Icons.location_city : Icons.my_location,
                          color: _isDemo ? AppColors.accent : AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isDemo ? 'Demo Location' : 'Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isDemo ? AppColors.accent : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${_latitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Longitude: ${_longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (_accuracy != null && !_isDemo) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Accuracy: ±${_accuracy!.toStringAsFixed(0)}m',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error display
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _isLoading 
                    ? Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Getting Location...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                ),
                if (widget.showDemoOption) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _useDemoLocation,
                      icon: const Icon(Icons.location_city),
                      label: const Text('Demo Location'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Settings buttons for error cases
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_error!.contains('Location services')) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openLocationSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Location Settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  if (_error!.contains('permission')) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openAppSettings,
                        icon: const Icon(Icons.app_settings_alt),
                        label: const Text('App Settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Help text
            const SizedBox(height: 12),
            Text(
              'Your location will be used to show your business on the map and for staff check-in validation.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
