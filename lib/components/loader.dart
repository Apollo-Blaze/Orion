import 'package:flutter/material.dart';
import 'dart:math';

class CustomLoader extends StatefulWidget {
  final double size;
  const CustomLoader({Key? key, this.size = 150.0}) : super(key: key);

  @override
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _colorAnimation;
  late Animation<double> _circleToRingAnimation;
  late Animation<double> _splitAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _sizeAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 100,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6),
      ),
    );

    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, 
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _circleToRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _splitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WelcomePainter(
            sizeValue: _sizeAnimation.value,
            colorValue: _colorAnimation.value,
            circleToRingValue: _circleToRingAnimation.value,
            splitValue: _splitAnimation.value,
          ),
        );
      },
    );
  }
}

class WelcomePainter extends CustomPainter {
  final double sizeValue;
  final double colorValue;
  final double circleToRingValue;
  final double splitValue;

  WelcomePainter({
    required this.sizeValue,
    required this.colorValue,
    required this.circleToRingValue,
    required this.splitValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) - 16.0; // Reduced the size further for a smaller logo
    final currentRadius = maxRadius * sizeValue.clamp(0.0, 1.0);

    // Color interpolation
    final currentColor = Color.lerp(
      const Color.fromARGB(255, 17, 34, 54),
      const Color.fromARGB(255, 61, 118, 175),
      colorValue.clamp(0.0, 1.0),
    )!;

    // Initial circle animationR
    if (circleToRingValue < 1.0) {
      // Gradually transition from filled circle to ring
      paint.style = PaintingStyle.fill;
      paint.color = currentColor.withOpacity(
        (1 - circleToRingValue).clamp(0.0, 1.0),
      );
      canvas.drawCircle(center, currentRadius, paint);

      // Gradually increase stroke width as circle transforms to ring
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 24.0 * circleToRingValue.clamp(0.0, 1.0); // Increased thickness
      paint.color = currentColor.withOpacity(
        circleToRingValue.clamp(0.0, 1.0),
      );
      canvas.drawCircle(center, currentRadius, paint);
    }

    // Split animation (fading out effect)
    if (splitValue > 0) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 24.0; // Increased thickness of split rings

      // Split rings (fading out effect)
      paint.color = const Color.fromARGB(255, 61, 118, 175).withOpacity(splitValue);

      // Right half
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius),
        -pi / 2,
        pi,
        false,
        paint,
      );

      // Left half
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius),
        pi / 2,
        pi,
        false,
        paint,
      );
    }

    // Add final "U" shaped logo or any additional details here
  }

  @override
  bool shouldRepaint(covariant WelcomePainter oldDelegate) {
    return sizeValue != oldDelegate.sizeValue ||
        colorValue != oldDelegate.colorValue ||
        circleToRingValue != oldDelegate.circleToRingValue ||
        splitValue != oldDelegate.splitValue;
  }
}
