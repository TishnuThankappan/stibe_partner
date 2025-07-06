# Common Loading Indicator Implementation

This document provides guidance on how to use the new common LoadingIndicator widget throughout the Stibe Partner app.

## Overview

The LoadingIndicator is a reusable component that provides consistent loading states across the app. It supports various configurations for different use cases, including:

- Multiple sizes (small, medium, large)
- Different types (circular, linear, three dots, pulsing circle, rotating dots, bouncing ball, gradient wave, spinning cube)
- Custom colors
- Optional text messages
- Container backdrop for emphasis
- Full screen overlay option

## Basic Usage

To use the basic loading indicator:

```dart
// Simple loading indicator with default size (medium)
LoadingIndicator()

// Small loading indicator
LoadingIndicator.small()

// Medium loading indicator
LoadingIndicator.medium()

// Large loading indicator
LoadingIndicator.large()

// Loading indicator with a message
LoadingIndicator(message: 'Loading data...')

// Loading indicator with custom color
LoadingIndicator(color: AppColors.primary)

// Loading indicator with container backdrop
LoadingIndicator(withContainer: true)
```

## Loading Types

The widget supports different loading indicator types:

```dart
// Default circular indicator
LoadingIndicator(type: LoadingIndicatorType.circular)

// Linear progress indicator
LoadingIndicator(type: LoadingIndicatorType.linear)

// Three dots animation
LoadingIndicator(type: LoadingIndicatorType.threeDotsFlashing)

// Modern pulsing circle animation
LoadingIndicator(type: LoadingIndicatorType.pulsingCircle)

// Rotating dots animation
LoadingIndicator(type: LoadingIndicatorType.rotatingDots)

// Bouncing ball animation
LoadingIndicator(type: LoadingIndicatorType.bouncingBall)

// Gradient wave animation
LoadingIndicator(type: LoadingIndicatorType.gradientWave)

// 3D spinning cube animation
LoadingIndicator(type: LoadingIndicatorType.spinningCube)

// DNA helix animation
LoadingIndicator(type: LoadingIndicatorType.dnaHelix)

// Spinning cube 3D animation
LoadingIndicator(type: LoadingIndicatorType.spinningCube)
```

## Full Screen Loading

For operations that block the entire screen:

```dart
// Option 1: Using LoadingIndicator.fullScreen
LoadingIndicator.fullScreen(message: 'Processing your request...')

// Option 2: Using LoadingOverlay
LoadingOverlay(
  isLoading: true, // Set to your loading state
  message: 'Processing your request...',
  child: YourContentWidget(),
)
```

## Button Loading States

For buttons with loading states, use the specialized button indicator:

```dart
// In an AppButton or CustomButton
LoadingIndicator.button(color: Colors.white)
```

The AppButton widget has been updated to use this loading indicator when the `isLoading` property is set to true.

## Example Screen

A complete example screen is available at:
`lib/screens/examples/loading_indicator_example_screen.dart`

This screen demonstrates all the different configurations of the LoadingIndicator and can be used as a reference for implementation.

## When to Use

1. **Page Loading**: When fetching data to populate a screen
   ```dart
   if (isLoading) {
     return const Center(child: LoadingIndicator());
   }
   ```

2. **Button Loading**: When a button action is in progress (using the `AppButton` with `isLoading` property)

3. **Form Submission**: When submitting form data
   ```dart
   LoadingOverlay(
     isLoading: isSubmitting,
     child: Form(...),
   )
   ```

4. **Partial Screen Loading**: When only part of the screen is loading
   ```dart
   Column(
     children: [
       // Always visible content
       if (isLoadingAdditionalData) 
         LoadingIndicator.small(),
       // More content
     ],
   )
   ```

## Best Practices

1. Always use the LoadingIndicator instead of directly using CircularProgressIndicator or LinearProgressIndicator for consistency

2. Include meaningful messages when the loading operation might take more than a second

3. Use the appropriate size based on the context:
   - Small: For inline or compact UI elements
   - Medium: For general page content
   - Large: For full page loading or empty states

4. For long-running operations, consider using the LoadingOverlay to block interaction while processing

5. Match the loading indicator color with your action context (use primary for general operations, success for positive actions, etc.)
