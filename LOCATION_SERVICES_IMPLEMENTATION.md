# Real-time GPS Location Implementation

This document describes the complete implementation of real-time GPS location fetching for the Stibe Partner app.

## Overview

The implementation provides both frontend (Flutter) and backend (.NET API) location services with the following features:

- Real-time GPS location fetching using device GPS
- Permission handling for Android and iOS
- Fallback to demo/mock locations
- Integration with Google Maps API (backend)
- Distance calculations using Haversine formula
- Location validation for staff check-ins

## Frontend Implementation (Flutter)

### 1. Location Service (`lib/services/location_service.dart`)

**Features:**
- GPS location fetching with permission handling
- Timeout management for location requests
- Error handling with user-friendly messages
- Demo location mode for testing
- Integration with device settings

**Key Methods:**
- `getCurrentLocation()` - Get current GPS coordinates
- `getCurrentLocationWithDialog()` - Get location with loading UI
- `checkLocationPermission()` - Check current permission status
- `requestLocationPermission()` - Request location permissions
- `openLocationSettings()` - Open device location settings
- `openAppSettings()` - Open app permission settings

### 2. Location Picker Widget (`lib/widgets/location_picker.dart`)

**Features:**
- Interactive UI for location selection
- Real-time GPS button with loading states
- Demo location option for testing
- Error display with actionable suggestions
- Location accuracy display
- History of location attempts

**Usage:**
```dart
LocationPicker(
  title: 'Business Location',
  subtitle: 'Get your current location or use demo coordinates.',
  onLocationSelected: (latitude, longitude, isDemo) {
    // Handle location selection
  },
  showDemoOption: true,
)
```

### 3. Business Profile Integration

The location picker is integrated into the business profile setup screen, replacing manual coordinate entry with:
- One-click GPS location detection
- Visual feedback during location requests
- Automatic form validation
- Fallback to demo mode

### 4. Permissions Setup

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to set up your business profile and enable location-based features.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to set up your business profile and enable location-based features.</string>
```

### 5. Dependencies

**Added to `pubspec.yaml`:**
```yaml
dependencies:
  geolocator: ^11.0.0          # GPS location services
  google_maps_flutter: ^2.6.0  # Google Maps integration
```

## Backend Implementation (.NET API)

### 1. Interface Definition (`ILocationService.cs`)

```csharp
public interface ILocationService
{
    Task<(decimal? Latitude, decimal? Longitude)> GetCoordinatesAsync(string address, string city, string state, string zipCode);
    double CalculateDistance(decimal lat1, decimal lon1, decimal lat2, decimal lon2);
    Task<bool> ValidateCoordinatesAsync(decimal latitude, decimal longitude);
    string FormatAddress(string address, string city, string state, string zipCode);
}
```

### 2. Google Location Service (`GoogleLocationService.cs`)

**Features:**
- Google Maps Geocoding API integration
- Fallback to mock data when API fails
- Feature flag support for easy switching
- Comprehensive error handling and logging
- Address formatting and validation

**Configuration:**
```json
{
  "FeatureFlags": {
    "UseRealLocationService": true
  },
  "GoogleMaps": {
    "ApiKey": "YOUR_GOOGLE_MAPS_API_KEY_HERE"
  }
}
```

### 3. Mock Location Service (`MockLocationService.cs`)

**Features:**
- Pre-defined coordinates for major Indian cities
- Random variation for realistic testing
- Fast response times for development
- Comprehensive logging

**Supported Cities:**
- Mumbai, Delhi, Bangalore, Chennai, Kolkata
- Hyderabad, Pune, Ahmedabad, Kochi, Kerala

### 4. Service Registration

The backend automatically selects the appropriate service based on feature flags:

```csharp
if (builder.Configuration.GetValue<bool>("FeatureFlags:UseRealLocationService"))
{
    builder.Services.AddHttpClient<ILocationService, GoogleLocationService>();
}
else
{
    builder.Services.AddScoped<ILocationService, MockLocationService>();
}
```

### 5. Staff Location Validation

The `StaffWorkService` uses location services for:
- **Clock-in validation**: Staff must be within 200m of salon
- **Location status**: "At salon premises" (50m), "Near salon" (200m)
- **Distance calculation**: Haversine formula for accurate results

## Testing and Development

### 1. Location Test Screen (`lib/screens/location_test_screen.dart`)

A comprehensive test screen accessible via Settings > Developer Options that provides:
- Interactive location picker testing
- Manual location service testing
- Permission status checking
- Location history tracking
- Service information display

### 2. Developer Options

Added to Settings screen:
- **Location Service Test**: Interactive testing interface
- **API Configuration**: View current API settings
- **Debug Information**: App and package versions

### 3. Testing Workflow

1. **Development Mode**: Use mock location service with predefined cities
2. **GPS Testing**: Use location test screen to verify GPS functionality
3. **Permission Testing**: Test various permission scenarios
4. **Production**: Enable real location service with Google Maps API

## Configuration Guide

### 1. Development Setup

1. **Enable location permissions** in Android/iOS manifests
2. **Set feature flag** `UseRealLocationService: false` for mock mode
3. **Use Location Test Screen** for testing GPS functionality
4. **Test permission scenarios** on real devices

### 2. Production Setup

1. **Get Google Maps API key** from Google Cloud Console
2. **Enable Geocoding API** in Google Cloud Console
3. **Add API key** to `appsettings.json`
4. **Set feature flag** `UseRealLocationService: true`
5. **Test with real addresses** and verify billing setup

### 3. API Key Security

- Store API keys in secure configuration
- Use environment variables for production
- Restrict API key to specific services and domains
- Monitor API usage and set billing alerts

## Error Handling

### Frontend Error Scenarios

- **Location services disabled**: Guide user to device settings
- **Permission denied**: Guide user to app settings  
- **GPS timeout**: Offer retry or demo mode
- **No GPS signal**: Suggest moving to open area

### Backend Error Scenarios

- **API key missing**: Fall back to mock service
- **API quota exceeded**: Fall back to mock service
- **Network errors**: Return cached or default coordinates
- **Invalid addresses**: Use closest match or default location

## Performance Considerations

### Frontend
- **Timeout management**: 30-second GPS timeout
- **Permission caching**: Avoid repeated permission checks
- **Error recovery**: Graceful fallback to demo mode
- **UI responsiveness**: Non-blocking location requests

### Backend
- **HTTP client reuse**: Shared HttpClient for Google API calls
- **Response caching**: Cache successful geocoding results
- **Rate limiting**: Respect Google API rate limits
- **Fallback strategy**: Quick fallback to mock data

## Security Considerations

- **Permission justification**: Clear explanation for location access
- **Data minimization**: Only collect necessary location data
- **Secure transmission**: HTTPS for all API communications
- **API key protection**: Secure storage and rotation of API keys

## Future Enhancements

1. **Offline support**: Cache location data for offline use
2. **Background location**: For staff tracking (with explicit consent)
3. **Geofencing**: Automatic check-in when entering salon area
4. **Location history**: Track staff movement patterns
5. **Multi-language support**: Localized location names and messages

## Troubleshooting

### Common Issues

1. **GPS not working on emulator**: Use physical device for GPS testing
2. **Permission denied**: Check app settings and re-request
3. **API key errors**: Verify key is valid and APIs are enabled
4. **Mock data in production**: Check feature flag configuration
5. **Slow GPS acquisition**: Ensure device has clear sky view

### Debug Tools

- **Location Test Screen**: Comprehensive testing interface
- **Developer Options**: Quick access to debug information
- **Console Logging**: Detailed logs for troubleshooting
- **API Response Inspection**: View Google API responses

This implementation provides a robust, scalable location service architecture that supports both development and production scenarios while maintaining excellent user experience and error handling.
