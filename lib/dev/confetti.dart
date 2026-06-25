import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/tokens.dart';

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    required this.trigger,
    this.child,
  });

  final Object trigger; // Changing this triggers a new burst
  final Widget? child;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateParticles);
    _spawnParticles();
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _spawnParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spawnParticles() {
    _particles.clear();
    if (!mounted) return;

    // Spawn 60-80 particles
    final int count = 60 + _random.nextInt(20);
    final colors = [
      AppColors.goldStandard500,
      AppColors.purplePower500,
      AppColors.lushCapital500,
      const Color(0xFFFF5A5F),
      const Color(0xFF3B5998),
      const Color(0xFF00B2B2),
    ];

    for (int i = 0; i < count; i++) {
      // Angle between -150 and -30 degrees (upwards arc)
      final double angle = -math.pi / 6 - _random.nextDouble() * (2 * math.pi / 3);
      final double speed = 3.0 + _random.nextDouble() * 7.0;
      
      _particles.add(_Particle(
        x: 0.0,
        y: 0.0,
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        color: colors[_random.nextInt(colors.length)],
        size: 4.0 + _random.nextDouble() * 6.0,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: -5.0 + _random.nextDouble() * 10.0,
        shape: _random.nextBool() ? _ParticleShape.rect : _ParticleShape.circle,
        aspectRatio: 0.5 + _random.nextDouble() * 1.0,
      ));
    }

    _controller.forward(from: 0.0);
  }

  void _updateParticles() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.child != null) widget.child!,
        if (_controller.isAnimating && !AppMotion.reduce(context))
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _ParticleShape { rect, circle }

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
    required this.aspectRatio,
  });

  double x;
  double y;
  double dx;
  double dy;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final _ParticleShape shape;
  final double aspectRatio;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double gravity = 0.2;
    final double drag = 0.02;

    for (final p in particles) {
      final double t = progress * 40.0;
      
      double x = p.x;
      double y = p.y;
      double dx = p.dx;
      double dy = p.dy;

      for (int step = 0; step < t.toInt(); step++) {
        x += dx;
        y += dy;
        dy += gravity;
        dx *= (1.0 - drag);
        dy *= (1.0 - drag);
      }

      final double currentRotation = p.rotation + p.rotationSpeed * progress;

      canvas.save();
      canvas.translate(center.dx + x, center.dy + y);
      canvas.rotate(currentRotation);

      final double opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity((p.color.opacity * opacity).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      if (p.shape == _ParticleShape.rect) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * p.aspectRatio,
            height: p.size,
          ),
          paint,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * p.aspectRatio,
            height: p.size,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
