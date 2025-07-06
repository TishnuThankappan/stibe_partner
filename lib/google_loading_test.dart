import 'package:flutter/material.dart';
import 'package:stibe_partner/widgets/loading_indicator.dart';

/// A test screen to display the Google-style loading indicator
void main() {
  runApp(const GoogleLoadingTestApp());
}

class GoogleLoadingTestApp extends StatelessWidget {
  const GoogleLoadingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Loading Indicator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GoogleLoadingTestScreen(),
    );
  }
}

class GoogleLoadingTestScreen extends StatefulWidget {
  const GoogleLoadingTestScreen({super.key});

  @override
  State<GoogleLoadingTestScreen> createState() => _GoogleLoadingTestScreenState();
}

class _GoogleLoadingTestScreenState extends State<GoogleLoadingTestScreen> {
  LoadingIndicatorType _selectedType = LoadingIndicatorType.google;
  double _size = 80.0;
  Color? _customColor;
  bool _useCustomColor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Loading Indicator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main display area for the indicator
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: LoadingIndicator(
                    type: _selectedType,
                    size: _size,
                    color: _useCustomColor ? _customColor : null,
                    message: 'Loading...',
                  ),
                ),
              ),
              
              // Divider
              const Divider(height: 32),
              
              // Type selector
              const Text('Indicator Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<LoadingIndicatorType>(
                value: _selectedType,
                isExpanded: true,
                onChanged: (LoadingIndicatorType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                items: LoadingIndicatorType.values.map((LoadingIndicatorType type) {
                  return DropdownMenuItem<LoadingIndicatorType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Size slider
              Text('Size: ${_size.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _size,
                min: 20,
                max: 200,
                divisions: 18,
                label: _size.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _size = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Color toggle
              Row(
                children: [
                  Checkbox(
                    value: _useCustomColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _useCustomColor = value ?? false;
                        if (_useCustomColor && _customColor == null) {
                          _customColor = Colors.purple;
                        }
                      });
                    },
                  ),
                  const Text('Use Custom Color'),
                  const Spacer(),
                  if (_useCustomColor)
                    ElevatedButton(
                      onPressed: () {
                        _showColorPicker();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _customColor ?? Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Change Color'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showColorPicker() {
    // This is a simplified color picker
    // In a real app, you might use a library like flutter_colorpicker
    final List<Color> predefinedColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: predefinedColors.map((Color color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _customColor = color;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black,
                        width: color == _customColor ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
