import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'dart:math';
import 'package:stibe_partner/widgets/google_loading_indicator.dart';

/// A common loading indicator that can be used throughout the app.
/// 
/// This widget provides a consistent loading experience across the app
/// with options for different sizes, colors, and styles.
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator
  final double size;
  
  /// The color of the loading indicator
  /// If null, it will use the primary color from the theme
  final Color? color;
  
  /// The thickness of the circular progress indicator
  final double strokeWidth;
  
  /// Whether to show a container with a backdrop and elevation
  final bool withContainer;
  
  /// The type of loading indicator to show
  final LoadingIndicatorType type;
  
  /// The message to display below the loading indicator
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
    this.withContainer = false,
    this.type = LoadingIndicatorType.circular,
    this.message,
  });

  /// A small loading indicator
  factory LoadingIndicator.small({
    Color? color,
    bool withContainer = false,
    LoadingIndicatorType type = LoadingIndicatorType.circular,
    String? message,
  }) {
    return LoadingIndicator(
      size: 24.0,
      strokeWidth: 2.0,
      color: color,
      withContainer: withContainer,
      type: type,
      message: message,
    );
  }

  /// A medium loading indicator
  factory LoadingIndicator.medium({
    Color? color,
    bool withContainer = false,
    LoadingIndicatorType type = LoadingIndicatorType.circular,
    String? message,
  }) {
    return LoadingIndicator(
      size: 40.0,
      strokeWidth: 3.0,
      color: color,
      withContainer: withContainer,
      type: type,
      message: message,
    );
  }

  /// A large loading indicator
  factory LoadingIndicator.large({
    Color? color,
    bool withContainer = false,
    LoadingIndicatorType type = LoadingIndicatorType.circular,
    String? message,
  }) {
    return LoadingIndicator(
      size: 56.0,
      strokeWidth: 4.0,
      color: color,
      withContainer: withContainer,
      type: type,
      message: message,
    );
  }

  /// A full screen loading indicator with a backdrop
  factory LoadingIndicator.fullScreen({
    Color? color,
    String? message,
  }) {
    return LoadingIndicator(
      size: 56.0,
      strokeWidth: 4.0,
      color: color,
      withContainer: true,
      type: LoadingIndicatorType.circular,
      message: message,
    );
  }

  /// A button loading indicator (small, with primary color)
  factory LoadingIndicator.button({
    Color? color,
    double size = 20.0,
  }) {
    return LoadingIndicator(
      size: size,
      strokeWidth: 2.0,
      color: color ?? Colors.white,
      withContainer: false,
      type: LoadingIndicatorType.google,
    );
  }

  /// Convenience method to replace CircularProgressIndicator across the app
  /// This makes it easy to standardize loading indicators app-wide
  static Widget googleLoader({
    double size = 24.0,
    Color? color,
    String? message,
  }) {
    return LoadingIndicator(
      type: LoadingIndicatorType.google,
      size: size,
      color: color,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? AppColors.primary;
    
    Widget indicator;
    
    switch (type) {
      case LoadingIndicatorType.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        );
        break;
      case LoadingIndicatorType.linear:
        indicator = SizedBox(
          width: size * 5,  // Linear indicators are typically wider
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
          ),
        );
        break;
      case LoadingIndicatorType.threeDotsFlashing:
        // A custom three dots flashing animation
        indicator = _ThreeDotsIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.pulsingCircle:
        // A modern pulsing circle animation
        indicator = _PulsingCircleIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.rotatingDots:
        // A rotating dots circle animation
        indicator = _RotatingDotsIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.bouncingBall:
        // A bouncing ball animation
        indicator = _BouncingBallIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.gradientWave:
        // A gradient wave animation
        indicator = _GradientWaveIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.spinningCube:
        // A 3D spinning cube animation
        indicator = _SpinningCubeIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.dnaHelix:
        // A DNA helix animation
        indicator = _DnaHelixIndicator(
          color: indicatorColor,
          size: size,
        );
        break;
      case LoadingIndicatorType.google:
        // A Google-style loading animation
        indicator = GoogleLoadingIndicator(
          size: size,
          color: indicatorColor,
        );
        break;
    }
    
    // If a message is provided, show it below the indicator
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // If withContainer is true, wrap in a container with a backdrop
    if (withContainer) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: indicator,
        ),
      );
    }
    
    return Center(child: indicator);
  }
}

/// The type of loading indicator to display
enum LoadingIndicatorType {
  /// A circular progress indicator
  circular,
  
  /// A linear progress indicator
  linear,
  
  /// A custom three dots flashing animation
  threeDotsFlashing,
  
  /// A modern pulsing circle animation
  pulsingCircle,
  
  /// A rotating dots circle animation
  rotatingDots,
  
  /// A bouncing ball animation
  bouncingBall,
  
  /// A gradient wave animation
  gradientWave,
  
  /// A 3D spinning cube animation
  spinningCube,
  
  /// A DNA helix animation
  dnaHelix,
  
  /// A Google-style loading animation with colored dots
  google,
}

/// A custom animated loading indicator with three flashing dots
class _ThreeDotsIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _ThreeDotsIndicator({
    required this.color,
    required this.size,
  });

  @override
  _ThreeDotsIndicatorState createState() => _ThreeDotsIndicatorState();
}

class _ThreeDotsIndicatorState extends State<_ThreeDotsIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    // Start the animations with delays
    Future.delayed(Duration.zero, () {
      _animationControllers[0].repeat(reverse: true);
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationControllers[1].repeat(reverse: true);
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _animationControllers[2].repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationControllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: widget.size * _animations[index].value,
              width: widget.size * _animations[index].value,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// A modern pulsing circle animation loading indicator
class _PulsingCircleIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingCircleIndicator({
    required this.color,
    required this.size,
  });

  @override
  _PulsingCircleIndicatorState createState() => _PulsingCircleIndicatorState();
}

class _PulsingCircleIndicatorState extends State<_PulsingCircleIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
          return Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final value = (_animation.value + delay) % 1.0;
              final opacity = (1.0 - value).clamp(0.0, 1.0);
              final size = widget.size * (0.5 + (value * 0.5));
              
              return Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3),
                    border: Border.all(
                      color: widget.color,
                      width: widget.size * 0.05,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// A rotating dots circle animation loading indicator
class _RotatingDotsIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _RotatingDotsIndicator({
    required this.color,
    required this.size,
  });

  @override
  _RotatingDotsIndicatorState createState() => _RotatingDotsIndicatorState();
}

class _RotatingDotsIndicatorState extends State<_RotatingDotsIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
            painter: _RotatingDotsPainter(
              color: widget.color,
              progress: _controller.value,
              dotCount: 8,
              dotSize: widget.size * 0.15,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _RotatingDotsPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int dotCount;
  final double dotSize;

  _RotatingDotsPainter({
    required this.color,
    required this.progress,
    required this.dotCount,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - dotSize) / 2;
    
    for (int i = 0; i < dotCount; i++) {
      final angle = 2 * 3.14159 * (i / dotCount);
      final rotationAngle = 2 * 3.14159 * progress;
      final dotAngle = angle + rotationAngle;
      
      final x = center.dx + radius * cos(dotAngle);
      final y = center.dy + radius * sin(dotAngle);
      
      // Calculate dot size and opacity based on its position
      final scaleFactor = (0.3 + 0.7 * ((i / dotCount + progress) % 1.0)).clamp(0.3, 1.0);
      final opacity = scaleFactor;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y), 
        dotSize * scaleFactor, 
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RotatingDotsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A bouncing ball animation loading indicator
class _BouncingBallIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _BouncingBallIndicator({
    required this.color,
    required this.size,
  });

  @override
  _BouncingBallIndicatorState createState() => _BouncingBallIndicatorState();
}

class _BouncingBallIndicatorState extends State<_BouncingBallIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _ballCount = 3;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      _ballCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    // Start the animations with sequential delays
    for (int i = 0; i < _ballCount; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ballSize = widget.size * 0.2;
    final spacing = widget.size * 0.15;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_ballCount, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final bounce = -sin(_animations[index].value * 3.14159) * widget.size * 0.25;
                
                return Transform.translate(
                  offset: Offset(0, bounce),
                  child: Container(
                    width: ballSize,
                    height: ballSize,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.8 - (0.2 * index / _ballCount)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

/// A gradient wave animation loading indicator
class _GradientWaveIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _GradientWaveIndicator({
    required this.color,
    required this.size,
  });

  @override
  _GradientWaveIndicatorState createState() => _GradientWaveIndicatorState();
}

class _GradientWaveIndicatorState extends State<_GradientWaveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
      height: widget.size * 0.6,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              color: widget.color,
              progress: _controller.value,
            ),
            size: Size(widget.size, widget.size * 0.6),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double progress;

  _WavePainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const waveCount = 2.0;
    final baseHeight = size.height * 0.4;
    final amplitude = size.height * 0.2;
    final frequency = size.width / waveCount;
    
    final path = Path();
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.6),
          color,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Start at the bottom left
    path.moveTo(0, size.height);
    
    // Draw the wave
    for (double x = 0; x <= size.width; x++) {
      final wavePhase = x / frequency;
      final waveY = baseHeight + 
                    amplitude * sin(2 * 3.14159 * wavePhase + (progress * 2 * 3.14159));
      path.lineTo(x, size.height - waveY);
    }
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final highlightPath = Path();
    highlightPath.moveTo(0, size.height - baseHeight);
    
    for (double x = 0; x <= size.width; x += 2) {
      final wavePhase = x / frequency;
      final waveY = baseHeight + 
                    amplitude * 0.5 * sin(2 * 3.14159 * wavePhase + (progress * 2 * 3.14159) + 0.5);
      highlightPath.lineTo(x, size.height - waveY);
    }
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A widget that can be used to overlay a loading indicator on top of existing content
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the loading overlay
  final bool isLoading;
  
  /// The widget to display behind the loading overlay
  final Widget child;
  
  /// The message to display with the loading indicator
  final String? message;
  
  /// The color of the loading indicator
  final Color? color;
  
  /// The opacity of the overlay background
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.color,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(opacity),
              child: LoadingIndicator(
                color: color,
                message: message,
                withContainer: true,
              ),
            ),
          ),
      ],
    );
  }
}

/// A 3D spinning cube animation loading indicator
class _SpinningCubeIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _SpinningCubeIndicator({
    required this.color,
    required this.size,
  });

  @override
  _SpinningCubeIndicatorState createState() => _SpinningCubeIndicatorState();
}

class _SpinningCubeIndicatorState extends State<_SpinningCubeIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_controller.value * 2 * pi)
              ..rotateY(_controller.value * 2 * pi)
              ..rotateZ(_controller.value * 2 * pi),
            child: _buildCube(widget.color, widget.size),
          );
        },
      ),
    );
  }
  
  Widget _buildCube(Color color, double size) {
    return Stack(
      children: [
        // Front face
        Transform(
          transform: Matrix4.identity()
            ..translate(0.0, 0.0, size / 2),
          child: _buildFace(color, size, 1.0),
        ),
        // Back face
        Transform(
          transform: Matrix4.identity()
            ..translate(0.0, 0.0, -size / 2),
          child: _buildFace(color, size, 0.7),
        ),
        // Left face
        Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..rotateY(pi / 2)
            ..translate(-size / 2, 0.0, 0.0),
          child: _buildFace(color, size, 0.8),
        ),
        // Right face
        Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()
            ..rotateY(-pi / 2)
            ..translate(size / 2, 0.0, 0.0),
          child: _buildFace(color, size, 0.8),
        ),
        // Top face
        Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..rotateX(-pi / 2)
            ..translate(0.0, -size / 2, 0.0),
          child: _buildFace(color, size, 0.9),
        ),
        // Bottom face
        Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..rotateX(pi / 2)
            ..translate(0.0, size / 2, 0.0),
          child: _buildFace(color, size, 0.6),
        ),
      ],
    );
  }
  
  Widget _buildFace(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(opacity + 0.1),
            color.withOpacity(opacity - 0.1),
          ],
        ),
      ),
    );
  }
}

/// A DNA helix animation loading indicator
class _DnaHelixIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DnaHelixIndicator({
    required this.color,
    required this.size,
  });

  @override
  _DnaHelixIndicatorState createState() => _DnaHelixIndicatorState();
}

class _DnaHelixIndicatorState extends State<_DnaHelixIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
            painter: _DnaHelixPainter(
              color: widget.color,
              progress: _controller.value,
              size: widget.size,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _DnaHelixPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double size;
  
  // Constants for DNA helix shape
  final int particlesPerStrand = 12;
  final double strandWidth = 3.0;

  _DnaHelixPainter({
    required this.color,
    required this.progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final particleRadius = this.size * 0.04;
    final helixRadius = this.size * 0.3;
    final helixHeight = this.size * 0.8;
    
    // Calculate colors for the two strands
    final color1 = color;
    final color2 = HSVColor.fromColor(color)
                    .withHue((HSVColor.fromColor(color).hue + 180) % 360)
                    .toColor();
    
    // Draw connecting lines first (behind the particles)
    final connectingPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < particlesPerStrand; i++) {
      final t = i / particlesPerStrand;
      final angle1 = 2 * pi * t + 2 * pi * progress;
      final angle2 = 2 * pi * t + pi + 2 * pi * progress;
      
      final y = center.dy - helixHeight / 2 + helixHeight * t;
      
      final x1 = center.dx + helixRadius * cos(angle1);
      final x2 = center.dx + helixRadius * cos(angle2);
      
      // Only draw connecting lines at certain points (like DNA base pairs)
      if (i % 2 == 0) {
        canvas.drawLine(
          Offset(x1, y),
          Offset(x2, y),
          connectingPaint,
        );
      }
    }
    
    // Draw the two strands
    final strandPaint1 = Paint()
      ..color = color1
      ..strokeWidth = strandWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final strandPaint2 = Paint()
      ..color = color2
      ..strokeWidth = strandWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path1 = Path();
    final path2 = Path();
    
    // Initialize with the first point
    double firstAngle1 = 2 * pi * progress;
    double firstY = center.dy - helixHeight / 2;
    double firstX1 = center.dx + helixRadius * cos(firstAngle1);
    path1.moveTo(firstX1, firstY);
    
    double firstAngle2 = pi + 2 * pi * progress;
    double firstX2 = center.dx + helixRadius * cos(firstAngle2);
    path2.moveTo(firstX2, firstY);
    
    // Draw the helical paths
    for (int i = 1; i <= particlesPerStrand; i++) {
      final t = i / particlesPerStrand;
      final angle1 = 2 * pi * t + 2 * pi * progress;
      final angle2 = 2 * pi * t + pi + 2 * pi * progress;
      
      final y = center.dy - helixHeight / 2 + helixHeight * t;
      
      final x1 = center.dx + helixRadius * cos(angle1);
      final x2 = center.dx + helixRadius * cos(angle2);
      
      path1.lineTo(x1, y);
      path2.lineTo(x2, y);
    }
    
    canvas.drawPath(path1, strandPaint1);
    canvas.drawPath(path2, strandPaint2);
    
    // Draw particles on both strands
    for (int i = 0; i < particlesPerStrand; i++) {
      final t = i / particlesPerStrand;
      final angle1 = 2 * pi * t + 2 * pi * progress;
      final angle2 = 2 * pi * t + pi + 2 * pi * progress;
      
      final y = center.dy - helixHeight / 2 + helixHeight * t;
      
      final x1 = center.dx + helixRadius * cos(angle1);
      final x2 = center.dx + helixRadius * cos(angle2);
      
      // Create a gradient for each particle
      final particlePaint1 = Paint()
        ..shader = RadialGradient(
          colors: [
            color1,
            color1.withOpacity(0.6),
          ],
          stops: const [0.4, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(x1, y),
          radius: particleRadius * 1.5,
        ))
        ..style = PaintingStyle.fill;
      
      final particlePaint2 = Paint()
        ..shader = RadialGradient(
          colors: [
            color2,
            color2.withOpacity(0.6),
          ],
          stops: const [0.4, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(x2, y),
          radius: particleRadius * 1.5,
        ))
        ..style = PaintingStyle.fill;
      
      // Draw particles with shadow effect
      canvas.drawCircle(
        Offset(x1, y),
        particleRadius,
        particlePaint1,
      );
      
      canvas.drawCircle(
        Offset(x2, y),
        particleRadius,
        particlePaint2,
      );
      
      // Add highlight to particles
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x1 - particleRadius * 0.3, y - particleRadius * 0.3),
        particleRadius * 0.25,
        highlightPaint,
      );
      
      canvas.drawCircle(
        Offset(x2 - particleRadius * 0.3, y - particleRadius * 0.3),
        particleRadius * 0.25,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DnaHelixPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
