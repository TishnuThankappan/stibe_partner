# Standardized Loading Indicator Guide

## Overview

This guide establishes a standard for using loading indicators throughout the app. The goal is to create a consistent, modern loading experience for users by using the Google-style loading indicator in all appropriate places.

## How to Use Loading Indicators

### 1. Button Loading States

All buttons in the app should use the Google-style loading indicator when in a loading state. This has been automatically implemented in the `CustomButton` class.

```dart
PrimaryButton(
  text: 'Login',
  onPressed: _login,
  isLoading: authProvider.isLoading,
  loadingSize: 24.0, // Optional - adjust size if needed
)
```

### 2. Full Screen or Container Loading

For full-screen loading or loading in a container, use the `LoadingIndicator` with the Google type:

```dart
LoadingIndicator(
  type: LoadingIndicatorType.google,
  size: 56.0, // Adjust as needed
  color: AppColors.primary, // Optional
  message: 'Loading...', // Optional
)
```

### 3. Replacing CircularProgressIndicator

Instead of using `CircularProgressIndicator` directly, use the static helper method:

```dart
// Old way
CircularProgressIndicator()

// New way
LoadingIndicator.googleLoader()

// With customization
LoadingIndicator.googleLoader(
  size: 32.0,
  color: Colors.blue,
  message: 'Processing...'
)
```

### 4. LoadingOverlay

For blocking overlays, use the `LoadingOverlay` component:

```dart
LoadingOverlay(
  isLoading: _isLoading,
  child: YourWidget(),
  message: 'Please wait...', // Optional
)
```

## Guidelines

1. Always use the `LoadingIndicator` class instead of directly using `CircularProgressIndicator` or `LinearProgressIndicator`
2. Use the Google-style indicator (`LoadingIndicatorType.google`) for all primary loading states
3. For consistent sizing, use:
   - Small: 24.0 (buttons, inline loading)
   - Medium: 40.0 (default)
   - Large: 56.0 (prominent loading states)
4. Include a message when appropriate, especially for operations that might take more than 1-2 seconds

## Implementation Details

The Google-style loading indicator features:
- Rotating colored dots in Google's signature colors (blue, red, yellow, green)
- Smooth pulsing animation
- Size customization
- Color override option

## Accessibility Considerations

- Ensure loading states are accompanied by appropriate text for screen readers
- Maintain sufficient color contrast for visibility
- Consider disabling interactive elements during loading states

## Future Improvements

- Standardize all loading indicators throughout the app
- Add additional customization options as needed
- Consider themed loading indicators based on the context
