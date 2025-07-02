import 'package:flutter/material.dart';

/// A widget that catches errors that would otherwise crash the app
/// and displays a user-friendly error message instead.
class SafeAreaWrapper extends StatefulWidget {
  final Widget child;
  final String title;

  const SafeAreaWrapper({
    Key? key,
    required this.child,
    this.title = 'Error',
  }) : super(key: key);

  @override
  State<SafeAreaWrapper> createState() => _SafeAreaWrapperState();
}

class _SafeAreaWrapperState extends State<SafeAreaWrapper> {
  bool _hasError = false;
  String _errorMessage = '';
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Technical details:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: Text(
                  _stackTrace?.toString() ?? 'No stack trace available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        // Capture Flutter errors inside the widget tree
        FlutterError.onError = (FlutterErrorDetails details) {
          print('❌ Error caught by SafeAreaWrapper: ${details.exception}');
          print('Stack trace: ${details.stack}');
          
          // Update state to show error UI
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = details.exception.toString();
              _stackTrace = details.stack;
            });
          }
          
          // Don't report to framework to prevent default error handling
          FlutterError.presentError(details);
        };
        
        return widget.child;
      }
    );
  }
}
