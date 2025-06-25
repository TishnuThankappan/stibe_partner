# Google Maps Setup Guide

## Issue
The app crashes when trying to use Google Maps because the API key is missing. The error shows:
```
API key not found. Check that <meta-data android:name="com.google.android.geo.API_KEY" android:value="your API key"/> is in the <application> element of AndroidManifest.xml
```

## Solution

### 1. Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable "Maps SDK for Android" API
4. Go to "Credentials" and create an API key
5. Restrict the API key to your app package name: `com.example.stibe_partner`

### 2. Add API Key to Android Manifest
Edit `android/app/src/main/AndroidManifest.xml` and add this inside the `<application>` tag:

```xml
<application
    android:label="stibe_partner"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Add this meta-data tag -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
    
    <!-- Rest of your existing configuration -->
    <activity
        android:name=".MainActivity"
        ...
    >
    </activity>
    
</application>
```

### 3. Alternative: Store API Key Securely
For better security, store the API key in `android/local.properties`:

1. Add to `android/local.properties`:
```
google.maps.api.key=YOUR_GOOGLE_MAPS_API_KEY_HERE
```

2. Reference it in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            googleMapsApiKey: project.findProperty("google.maps.api.key") ?: ""
        ]
    }
}
```

3. Use in `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${googleMapsApiKey}" />
```

## Current Workaround
I've created a `SimpleLocationPickerScreen` that works without Google Maps API key. It provides:
- GPS location detection
- Manual coordinate entry
- Sample location selection
- Full location management

## Files Modified
- `lib/screens/salons/simple_location_picker_screen.dart` - New simple location picker
- `lib/screens/salons/add_salon_screen.dart` - Updated to use simple picker
- `lib/screens/salons/location_picker_screen.dart` - Original Google Maps picker (for future use)

## To Use Google Maps Later
1. Follow the API key setup above
2. Change the import in `add_salon_screen.dart` from:
   ```dart
   import 'package:stibe_partner/screens/salons/simple_location_picker_screen.dart';
   ```
   to:
   ```dart
   import 'package:stibe_partner/screens/salons/location_picker_screen.dart';
   ```
3. Change `SimpleLocationPickerScreen` to `LocationPickerScreen` in the `_selectLocation()` method

## Testing
The simple location picker provides:
- ✅ GPS location detection
- ✅ Manual coordinate input
- ✅ Sample locations for testing
- ✅ Location validation
- ✅ No API key required
- ✅ No app crashes
