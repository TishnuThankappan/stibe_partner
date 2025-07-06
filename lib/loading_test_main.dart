import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

/// This is a test main entry point to focus specifically on testing the LoadingIndicator widget
/// To use this file, run:
/// flutter run -t lib/loading_test_main.dart
void main() {
  runApp(const LoadingIndicatorTestApp());
}

class LoadingIndicatorTestApp extends StatelessWidget {
  const LoadingIndicatorTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loading Indicator Test',
      theme: AppTheme.lightTheme,
      home: const LoadingIndicatorTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoadingIndicatorTestScreen extends StatefulWidget {
  const LoadingIndicatorTestScreen({super.key});

  @override
  State<LoadingIndicatorTestScreen> createState() => _LoadingIndicatorTestScreenState();
}

class _LoadingIndicatorTestScreenState extends State<LoadingIndicatorTestScreen> {
  bool _isLoading = false;
  bool _isOverlayVisible = false;
  LoadingIndicatorType _selectedType = LoadingIndicatorType.circular;
  double _selectedSize = 40.0;
  bool _withContainer = false;
  String? _message;
  Color _selectedColor = AppColors.primary;

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
        message: 'Loading content...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Live Preview
              Text(
                'Live Preview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: _isLoading 
                      ? LoadingIndicator(
                          size: _selectedSize,
                          color: _selectedColor,
                          type: _selectedType,
                          withContainer: _withContainer,
                          message: _message,
                        )
                      : const Text('Press "Show Loading" to test'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 2: Controls
              Text(
                'Configuration',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              // Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTypeOption(
                            'Circular', 
                            LoadingIndicatorType.circular,
                          ),
                          _buildTypeOption(
                            'Linear', 
                            LoadingIndicatorType.linear,
                          ),
                          _buildTypeOption(
                            'Three Dots', 
                            LoadingIndicatorType.threeDotsFlashing,
                          ),
                          _buildTypeOption(
                            'Pulsing Circle', 
                            LoadingIndicatorType.pulsingCircle,
                          ),
                          _buildTypeOption(
                            'Rotating Dots', 
                            LoadingIndicatorType.rotatingDots,
                          ),
                          _buildTypeOption(
                            'Bouncing Ball', 
                            LoadingIndicatorType.bouncingBall,
                          ),
                          _buildTypeOption(
                            'Gradient Wave', 
                            LoadingIndicatorType.gradientWave,
                          ),
                          _buildTypeOption(
                            'Spinning Cube', 
                            LoadingIndicatorType.spinningCube,
                          ),
                          _buildTypeOption(
                            'DNA Helix', 
                            LoadingIndicatorType.dnaHelix,
                          ),
                          _buildTypeOption(
                            'Spinning Cube', 
                            LoadingIndicatorType.spinningCube,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Size Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _selectedSize,
                        min: 10,
                        max: 100,
                        divisions: 18,
                        label: _selectedSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                        },
                      ),
                      Text('Current size: ${_selectedSize.round()}px'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Color Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildColorOption('Primary', AppColors.primary),
                          _buildColorOption('Secondary', AppColors.secondary),
                          _buildColorOption('Success', AppColors.success),
                          _buildColorOption('Error', AppColors.error),
                          _buildColorOption('Warning', AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Options',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('With Container'),
                        value: _withContainer,
                        onChanged: (value) {
                          setState(() {
                            _withContainer = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Message (optional)',
                          hintText: 'Enter a message to display',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _message = value.isEmpty ? null : value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 3: Actions
              Text(
                'Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleLoading,
                      child: Text(_isLoading ? 'Hide Loading' : 'Show Loading'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleOverlay,
                      child: Text(_isOverlayVisible ? 'Hide Overlay' : 'Show Overlay'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateAsyncOperation,
                      child: const Text('Simulate Async'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 4: Presets
              Text(
                'Presets',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildPresetButton('Small', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 24;
                      _selectedType = LoadingIndicatorType.circular;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Medium', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 40;
                      _selectedType = LoadingIndicatorType.circular;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Large', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 56;
                      _selectedType = LoadingIndicatorType.circular;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('With Message', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 40;
                      _selectedType = LoadingIndicatorType.circular;
                      _message = 'Loading content...';
                    });
                  }),
                  _buildPresetButton('With Container', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = true;
                      _selectedSize = 40;
                      _selectedType = LoadingIndicatorType.circular;
                      _message = 'Loading content...';
                    });
                  }),
                  _buildPresetButton('Pulsing Circle', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.pulsingCircle;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Rotating Dots', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.rotatingDots;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Bouncing Ball', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.bouncingBall;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Gradient Wave', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.gradientWave;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Spinning Cube', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.spinningCube;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('DNA Helix', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.dnaHelix;
                      _message = null;
                    });
                  }),
                  _buildPresetButton('Spinning Cube', () {
                    setState(() {
                      _isLoading = true;
                      _withContainer = false;
                      _selectedSize = 60;
                      _selectedType = LoadingIndicatorType.spinningCube;
                      _message = null;
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, LoadingIndicatorType type) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? AppColors.primary : null,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
    );
  }

  Widget _buildColorOption(String label, Color color) {
    final isSelected = _selectedColor == color;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: color,
          radius: 10,
        ),
        label: Text(label),
        backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        side: isSelected 
          ? BorderSide(color: AppColors.primary) 
          : const BorderSide(color: Colors.transparent),
      ),
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
