# Salon Service Function Testing Guide

## Overview
This guide demonstrates how to test the salon service functions with real examples using the built-in test screen.

## Access the Test Screen

1. **Run the Flutter app**
2. **Login to your account**
3. **Open the navigation drawer** (hamburger menu)
4. **Scroll down to "Development Tools"**
5. **Tap "Salon Service Test"**

## Available Test Functions

### 1. Load Salons (`getMySalons()`)
- **Purpose**: Retrieve all salons belonging to the current user
- **Test**: Click the "Load Salons" button
- **Expected Result**: Shows list of your salons or "No salons found" message

### 2. Create Test Salon (`createSalon()`)
- **Purpose**: Create a new salon with test data
- **Test**: Click the "Create Test Salon" button
- **Expected Result**: Creates a new salon with auto-generated name
- **Test Data Used**:
  ```dart
  Name: "Test Salon [timestamp]"
  Description: "This is a test salon created by the salon service test"
  Address: "123 Test Street, Test City, Test State 12345"
  Phone: "+1234567890"
  Email: "test@testsalon.com"
  Hours: "09:00:00 - 18:00:00"
  ```

### 3. Get Salon by ID (`getSalonById()`)
- **Purpose**: Retrieve detailed information for a specific salon
- **Test**: Tap "View Details" on any salon in the list
- **Expected Result**: Opens the salon detail screen with full functionality

### 4. Toggle Salon Status (`toggleSalonStatus()`)
- **Purpose**: Activate or deactivate a salon
- **Test**: Tap the menu (⋮) → "Activate" or "Deactivate"
- **Expected Result**: Changes salon status and updates the UI

### 5. Salon Detail Screen Functions
When you tap "View Details", you access the salon detail screen which tests:

#### Navigation Functions:
- **Edit Salon**: Tests `getSalonById()` and navigation to edit screen
- **View Services**: Tests navigation to services screen
- **Staff Management**: Tests staff-related functionality

#### Status Management:
- **Activate/Deactivate**: Tests `toggleSalonStatus()`
- **Delete Salon**: Tests `deleteSalon()` with confirmation dialogs

#### Display Functions:
- **Salon Information**: Tests data display and formatting
- **Image Handling**: Tests profile picture and gallery images
- **Stats Display**: Shows services count, staff count, bookings

## Test Scenarios

### Scenario 1: Fresh Account (No Salons)
1. Load salons → Shows "No salons found"
2. Create test salon → Creates new salon
3. Load salons again → Shows the new salon
4. Test salon functions → All functions work with the new salon

### Scenario 2: Existing Salons
1. Load salons → Shows existing salons
2. View details → Opens salon detail screen
3. Toggle status → Changes active/inactive status
4. Test all salon detail functions

### Scenario 3: Service Integration Test
1. Create/select a salon
2. View salon details
3. Go to "Salon Works" tab
4. Navigate to services → Tests service integration
5. Create/manage services → Tests service management

## Real API Integration

All tests use **real API calls** to your backend server:
- **Base URL**: `http://10.52.70.23:5074/api`
- **Authentication**: Uses your actual login token
- **Data Persistence**: All changes are saved to the database

## Expected API Responses

### Successful Salon Creation:
```json
{
  "success": true,
  "data": {
    "id": 123,
    "name": "Test Salon 1704123456789",
    "description": "This is a test salon...",
    "address": "123 Test Street",
    "isActive": true,
    "createdAt": "2024-01-01T12:00:00Z",
    // ... other salon fields
  }
}
```

### Successful Status Toggle:
```json
{
  "success": true,
  "data": {
    "id": 123,
    "isActive": false,  // Changed status
    // ... other salon fields
  }
}
```

## Troubleshooting

### If Tests Fail:
1. **Check API Server**: Ensure `http://10.52.70.23:5074` is running
2. **Check Authentication**: Re-login if getting 401 errors
3. **Check Network**: Ensure device can reach the API server
4. **Check Logs**: Look at the test screen status messages for details

### Common Error Messages:
- `"Error loading salons: Failed to get salon"` → API connection issue
- `"Error creating salon: Failed to create salon"` → Validation or server error
- `"Error: 401 Unauthorized"` → Authentication token expired

## Status Messages

The test screen shows real-time status:
- ✅ **Green checkmark**: Success
- ❌ **Red X**: Error
- 🔄 **Blue loading**: In progress

## Next Steps

After testing basic salon functions, you can:
1. Test service management functions
2. Test staff management functions
3. Test booking management functions
4. Test image upload functionality

All salon service functions are working correctly and integrated with the real API backend!
