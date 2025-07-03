# Service Categories Implementation Guide

## Overview

This document explains how service categories are implemented in the Stibe Partner application, focusing on the predefined (built-in) categories feature.

## Predefined Categories

The application includes a set of predefined service categories that are available even when the backend API doesn't return any categories. These predefined categories use negative IDs to differentiate them from backend-created categories (which use positive IDs).

### Available Predefined Categories

The following predefined categories are available:

| ID | Name | Description |
|----|------|-------------|
| -1 | Hair Care | Services for hair styling, cutting, coloring, and treatments |
| -2 | Facial | Facial treatments and skincare services |
| -3 | Nail Care | Manicure, pedicure, and nail treatments |
| -4 | Massage | Various massage therapies and treatments |
| -5 | Body Treatments | Full body treatments, wraps, and scrubs |
| -6 | Makeup | Makeup application and consultations |
| -7 | Waxing | Hair removal services |

## Implementation Details

### Access Predefined Categories

To get the predefined categories for a salon, use:

```dart
final serviceManagementService = ServiceManagementService();
final categories = await serviceManagementService.getPredefinedServiceCategories(salonId);
```

### How It Works

1. When adding/editing a service, the application always shows the predefined categories in the dropdown.
2. When creating/updating a service with a predefined category:
   - The API sends `null` as the categoryId to the backend (since backend doesn't recognize negative IDs)
   - The client-side code patches the response to maintain the selected predefined category

### Fallback Mechanism

The `getServiceCategories` method has a fallback mechanism:
- First attempts to fetch categories from the backend API
- If no categories are returned or an error occurs, returns the predefined categories

## Service Listing by Category

The services screen now displays services organized by categories with an enhanced UI:

### 1. Categorized Display

Services are displayed in groups organized by their category:

1. Each category has a visual header with:
   - Category name
   - Service count badge
   - Category-specific icon
   - Visual styling to clearly separate categories

2. Services are grouped under their respective categories with:
   - Dividers between categories for clear visual separation
   - Consistent styling within each category group

3. Uncategorized services are displayed at the bottom in their own section

### 2. Filtering Options

The services screen includes enhanced filtering options:

1. A "Show Inactive" toggle switch to control visibility of inactive services
2. A category dropdown to filter services by a specific category:
   - Shows all available categories with appropriate icons
   - "All Categories" option to show services from all categories
   - Works with both predefined and backend-created categories

3. When a category is selected, only services from that category are shown while maintaining the categorized display

## Implementation Details

- `_buildServicesList()` groups services by their category ID
- `_buildCategoryHeader()` creates a visual header with icons for each category
- `_getCategoryIcon()` provides appropriate icons based on category names
- Category filtering works client-side, enabling filtering by predefined categories

## Integration Points

- `enhanced_service_management_service.dart`: Contains the predefined categories and related methods
- `add_service_screen.dart`: Uses the predefined categories for the category dropdown
- `services_screen.dart`: Implements the categorized list display and filtering options

## Backend Integration

When creating or updating a service with a predefined category:

1. The client sends:
   - `categoryId: null` - Since the backend doesn't recognize negative IDs
   - `category: "Category Name"` - So the backend can try to find a matching category

2. The backend:
   - Accepts the request without validating the category ID
   - Tries to find a matching category by name if provided
   - If found, assigns that category ID to the service
   - If not found, creates the service without a category

3. When the response comes back:
   - The client patches the response to include the original predefined category information
   - This ensures the UI always shows the correct category, even though it's managed client-side

## Important Notes

- Predefined category IDs are negative integers (-1 to -7) to avoid conflicts with backend-generated IDs
- When displaying services with predefined categories, the UI will show the predefined category name
- Backend API doesn't store the predefined category IDs, so this information is managed client-side
- Category filtering and organization in the services list is done client-side to support both backend and predefined categories
- The services list provides enhanced organization with visual category headers and icons
