import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';
import 'package:stibe_partner/widgets/custom_button.dart';
import 'package:stibe_partner/widgets/app_button.dart';

/// A test screen to demonstrate the various loading indicators.
/// Can be accessed in debug mode through settings or a debug menu.
class LoadingIndicatorTestScreen extends StatefulWidget {
  const LoadingIndicatorTestScreen({super.key});

  @override
  State<LoadingIndicatorTestScreen> createState() => _LoadingIndicatorTestScreenState();
}

class _LoadingIndicatorTestScreenState extends State<LoadingIndicatorTestScreen> {
  bool _isLoading = false;
  bool _isOverlayVisible = false;
  LoadingIndicatorType _selectedType = LoadingIndicatorType.circular;
  
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
        title: const Text('Loading Indicator Test'),
      ),
      body: LoadingOverlay(
        isLoading: _isOverlayVisible,
        message: 'Full screen loading overlay...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common Loading Indicator',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'A consistent loading experience throughout the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Type Selector
              Text(
                'Indicator Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                children: [
                  _buildTypeChip(LoadingIndicatorType.circular, 'Circular'),
                  _buildTypeChip(LoadingIndicatorType.linear, 'Linear'),
                  _buildTypeChip(LoadingIndicatorType.threeDotsFlashing, 'Three Dots'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Size Variants
              Text(
                'Size Variants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSizeExample('Small', LoadingIndicator.small(type: _selectedType)),
                  _buildSizeExample('Medium', LoadingIndicator.medium(type: _selectedType)),
                  _buildSizeExample('Large', LoadingIndicator.large(type: _selectedType)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Color Variants
              Text(
                'Color Variants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorExample('Primary', AppColors.primary),
                  _buildColorExample('Success', AppColors.success),
                  _buildColorExample('Error', AppColors.error),
                  _buildColorExample('Warning', AppColors.warning),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // With Container and Message
              Text(
                'With Container and Message',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: LoadingIndicator(
                  type: _selectedType,
                  withContainer: true,
                  message: 'Loading your data...',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Button Examples
              Text(
                'Button Loading States',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'App Button',
                      onPressed: () {},
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Custom Button',
                      onPressed: () {},
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Test Actions
              Text(
                'Test Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: _toggleLoading,
                    child: Text(_isLoading ? 'Hide Button Loading' : 'Show Button Loading'),
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
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(LoadingIndicatorType type, String label) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
      backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }
  
  Widget _buildSizeExample(String label, Widget indicator) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(child: indicator),
        ),
      ],
    );
  }
  
  Widget _buildColorExample(String label, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: LoadingIndicator(
              color: color,
              type: _selectedType,
            ),
          ),
        ),
      ],
    );
  }
}
