import 'package:flutter/material.dart';
import 'dart:math';

/// A Google-style loading animation with colored dots
class GoogleLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const GoogleLoadingIndicator({
    super.key,
    required this.size,
    this.color,
  });

  @override
  GoogleLoadingIndicatorState createState() => GoogleLoadingIndicatorState();
}

class GoogleLoadingIndicatorState extends State<GoogleLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Google's signature colors
  final List<Color> _googleColors = [
    const Color(0xFF4285F4), // Google Blue
    const Color(0xFF34A853), // Google Green
    const Color(0xFFFBBC05), // Google Yellow
    const Color(0xFFEA4335), // Google Red
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: GoogleLoadingPainter(
              progress: _controller.value,
              colors: widget.color != null ? List.filled(4, widget.color!) : _googleColors,
              dotCount: 4,
              dotSize: widget.size * 0.12,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class GoogleLoadingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final int dotCount;
  final double dotSize;

  GoogleLoadingPainter({
    required this.progress,
    required this.colors,
    required this.dotCount,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - dotSize) * 0.35;
    
    // Google animation has two parts:
    // 1. Dots rotating around the circle
    // 2. Dots expanding and contracting
    
    for (int i = 0; i < dotCount; i++) {
      // Calculate position on the circle
      final angle = 2 * pi * ((i / dotCount) + progress);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      // Calculate dot size variation
      // Make dots grow and shrink in sequence
      final dotPhase = (progress + (i / dotCount)) % 1.0;
      final sizeFactor = 0.5 + (0.5 * sin(dotPhase * 2 * pi));
      
      // Draw dot with its respective color
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      
      // Draw the dot
      canvas.drawCircle(
        Offset(x, y),
        dotSize * sizeFactor,
        paint,
      );
      
      // Add subtle shadow
      if (sizeFactor > 0.7) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(x + 1, y + 1),
          dotSize * sizeFactor * 0.9,
          shadowPaint,
        );
      }
      
      // Add highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x - dotSize * 0.3, y - dotSize * 0.3),
        dotSize * sizeFactor * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GoogleLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
