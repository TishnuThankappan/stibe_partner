import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static const double _defaultLatitude = 40.7128;
  static const double _defaultLongitude = -74.0060;

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location with permission handling
  static Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error(
          'Location services are disabled. Please enable location services in your device settings.'
        );
      }

      // Check and request permissions
      LocationPermission permission = await checkLocationPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.error(
            'Location permissions are denied. Please grant location access to continue.'
          );
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error(
          'Location permissions are permanently denied. Please enable them in app settings.'
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

    } catch (e) {
      String errorMessage = 'Failed to get location: ${e.toString()}';
      
      // Handle specific errors
      if (e is TimeoutException) {
        errorMessage = 'Location request timed out. Please try again.';
      } else if (e is LocationServiceDisabledException) {
        errorMessage = 'Location services are disabled. Please enable them in settings.';
      } else if (e is PermissionDeniedException) {
        errorMessage = 'Location permission denied. Please grant access to continue.';
      }
      
      return LocationResult.error(errorMessage);
    }
  }

  /// Get location with a loading dialog
  static Future<LocationResult> getCurrentLocationWithDialog(
    BuildContext context, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return await showDialog<LocationResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationLoadingDialog(timeout: timeout),
    ) ?? LocationResult.error('Location request cancelled');
  }

  /// Open device location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  /// Get demo location for testing
  static LocationResult getDemoLocation() {
    return LocationResult.success(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      accuracy: 5.0,
      isDemo: true,
    );
  }
}

/// Result class for location operations
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? error;
  final bool isDemo;

  LocationResult._({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.error,
    this.isDemo = false,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isDemo = false,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      isDemo: isDemo,
    );
  }

  factory LocationResult.error(String error) {
    return LocationResult._(
      isSuccess: false,
      error: error,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
}

/// Loading dialog for location requests
class LocationLoadingDialog extends StatefulWidget {
  final Duration timeout;

  const LocationLoadingDialog({
    super.key,
    required this.timeout,
  });

  @override
  State<LocationLoadingDialog> createState() => _LocationLoadingDialogState();
}

class _LocationLoadingDialogState extends State<LocationLoadingDialog> {
  String _status = 'Getting your location...';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      setState(() {
        _status = 'Checking location services...';
      });

      final result = await LocationService.getCurrentLocation(
        timeout: widget.timeout,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(
          LocationResult.error('Failed to get location: ${e.toString()}')
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Getting Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_status),
          const SizedBox(height: 16),
          Text(
            'This may take up to ${widget.timeout.inSeconds} seconds',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              LocationResult.error('Location request cancelled')
            );
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
