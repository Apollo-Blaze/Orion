import 'package:flutter/material.dart';
import 'dart:math';

class CustomLoader_2 extends StatefulWidget {
  final double size;
  const CustomLoader_2(int i, {Key? key, this.size = 150.0}) : super(key: key);

  @override
  _CustomLoader_2State createState() => _CustomLoader_2State();
}

class _CustomLoader_2State extends State<CustomLoader_2> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse:true); // Repeat animation indefinitely

    // Size animation
    _sizeAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 100,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6),
      ),
    );

    // Color animation
    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // Circle to ring animation
    _circleToRingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    // Split animation
    _splitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOutCubic),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WelcomePainter_2(
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

class WelcomePainter_2 extends CustomPainter {
  final double sizeValue;
  final double colorValue;
  final double circleToRingValue;
  final double splitValue;

  WelcomePainter_2({
    required this.sizeValue,
    required this.colorValue,
    required this.circleToRingValue,
    required this.splitValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) - 16.0; // Slightly reduced size for a more compact logo
    final currentRadius = maxRadius * sizeValue.clamp(0.0, 1.0);

    // Color interpolation
    final currentColor = Color.lerp(
      const Color.fromARGB(255, 17, 34, 54),
      const Color.fromARGB(255, 61, 118, 175),
      colorValue.clamp(0.0, 1.0),
    )!;

    // Circle to ring animation logic
    if (circleToRingValue < 1.0) {
      paint.style = PaintingStyle.fill;
      paint.color = currentColor.withOpacity((1 - circleToRingValue).clamp(0.0, 1.0));
      canvas.drawCircle(center, currentRadius, paint);

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 24.0 * circleToRingValue.clamp(0.0, 1.0);
      paint.color = currentColor.withOpacity(circleToRingValue.clamp(0.0, 1.0));
      canvas.drawCircle(center, currentRadius, paint);
    }

    // Split animation (effect of split rings)
    if (splitValue > 0) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 24.0;

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
  }

  @override
  bool shouldRepaint(covariant WelcomePainter_2 oldDelegate) {
    return sizeValue != oldDelegate.sizeValue ||
        colorValue != oldDelegate.colorValue ||
        circleToRingValue != oldDelegate.circleToRingValue ||
        splitValue != oldDelegate.splitValue;
  }
}
