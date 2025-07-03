# Service Management API Documentation

## Service Categories

### Built-in Categories

The app provides a set of predefined service categories for salons to use. These categories are available directly without requiring an API call and are guaranteed to be available even when offline.

#### Available Categories:
- Hair Care
- Facial
- Nail Care
- Massage
- Body Treatments
- Makeup
- Waxing

### API Methods

#### Get Predefined Service Categories
```dart
// Returns the built-in categories with the salon ID assigned
Future<List<ServiceCategoryDto>> getPredefinedServiceCategories(int salonId)
```

**Example Usage:**
```dart
final serviceManagementService = ServiceManagementService();
final categories = await serviceManagementService.getPredefinedServiceCategories(salonId);
```

#### Get Service Categories (from backend)
```dart
// Tries to fetch categories from backend, falls back to predefined categories
Future<List<ServiceCategoryDto>> getServiceCategories(int salonId, {
  bool includeInactive = false,
  bool includeServiceCount = false,
})
```

## Implementation Notes

- Each predefined category has a negative ID to prevent conflicts with backend-generated IDs
- The `add_service_screen.dart` now uses `getPredefinedServiceCategories()` to ensure consistent category options
- AI-based category suggestions have been removed in favor of these predefined categories
