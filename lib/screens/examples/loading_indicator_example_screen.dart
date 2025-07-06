import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

/// Example screen that demonstrates how to use the LoadingIndicator widget
/// in different scenarios throughout the app.
class LoadingIndicatorExampleScreen extends StatefulWidget {
  const LoadingIndicatorExampleScreen({super.key});

  @override
  State<LoadingIndicatorExampleScreen> createState() => _LoadingIndicatorExampleScreenState();
}

class _LoadingIndicatorExampleScreenState extends State<LoadingIndicatorExampleScreen> {
  bool _isLoading = false;
  bool _isOverlayVisible = false;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  void _simulateAsyncOperation() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate an API call or other async operation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Indicator Examples'),
      ),
      body: LoadingOverlay(
        isLoading: _isOverlayVisible,
        message: 'Loading content...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Basic Loading Indicators
              Text(
                'Basic Loading Indicators',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildExampleCard(
                    'Small',
                    LoadingIndicator.small(),
                  ),
                  _buildExampleCard(
                    'Medium',
                    LoadingIndicator.medium(),
                  ),
                  _buildExampleCard(
                    'Large',
                    LoadingIndicator.large(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Section 2: Loading Indicator Types
              Text(
                'Loading Indicator Types',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildExampleCard(
                    'Circular',
                    const LoadingIndicator(
                      type: LoadingIndicatorType.circular,
                    ),
                  ),
                  _buildExampleCard(
                    'Linear',
                    const LoadingIndicator(
                      type: LoadingIndicatorType.linear,
                    ),
                  ),
                  _buildExampleCard(
                    'Three Dots',
                    const LoadingIndicator(
                      type: LoadingIndicatorType.threeDotsFlashing,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Section 3: With Custom Colors
              Text(
                'Custom Colors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildExampleCard(
                    'Primary',
                    const LoadingIndicator(color: AppColors.primary),
                  ),
                  _buildExampleCard(
                    'Success',
                    const LoadingIndicator(color: AppColors.success),
                  ),
                  _buildExampleCard(
                    'Error',
                    const LoadingIndicator(color: AppColors.error),
                  ),
                  _buildExampleCard(
                    'Warning',
                    const LoadingIndicator(color: AppColors.warning),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Section 4: With Container and Message
              Text(
                'With Container and Message',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              _buildExampleCard(
                'With Container',
                const LoadingIndicator(
                  withContainer: true,
                  message: 'Loading data...',
                ),
                width: double.infinity,
                height: 150,
              ),

              const SizedBox(height: 32),

              // Section 5: Demo Buttons
              Text(
                'Interactive Demo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: _toggleLoading,
                    child: Text(_isLoading ? 'Hide Loading' : 'Show Loading'),
                  ),
                  ElevatedButton(
                    onPressed: _toggleOverlay,
                    child: Text(_isOverlayVisible ? 'Hide Overlay' : 'Show Overlay'),
                  ),
                  ElevatedButton(
                    onPressed: _simulateAsyncOperation,
                    child: const Text('Simulate Async Operation'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Section 6: Conditional Loading State
              if (_isLoading) ...[
                Center(
                  child: LoadingIndicator.large(
                    withContainer: true,
                    message: 'Processing your request...',
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(String title, Widget indicator, {double? width, double? height}) {
    return Container(
      width: width ?? 150,
      height: height ?? 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(child: indicator),
          ),
        ],
      ),
    );
  }
}
