import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Ported from https://github.com/scotato/figma-squircle (simple mode)
const _ratio = 0.1765;

double _r2FromCurvature(int c) {
  switch (c.clamp(0, 10)) {
    case 0:  return 0.0;
    case 1:  return 0.0375;
    case 2:  return 0.0750;
    case 3:  return 0.1500;
    case 4:  return 0.2984;
    case 5:  return 0.3320;
    case 6:  return 0.3656;
    case 7:  return 0.3992;
    case 8:  return 0.4328;
    case 9:  return 0.4664;
    case 10: return 0.5000;
    default: return 0.3320;
  }
}

Path squirclePath(Rect rect, int curvature) {
  final w = rect.width;
  final h = rect.height;
  final r2 = _r2FromCurvature(curvature) * math.min(w, h);
  final r1 = r2 * _ratio;
  final l = rect.left;
  final t = rect.top;

  return Path()
    ..moveTo(l, t + r2)
    ..cubicTo(l, t + r1, l + r1, t, l + r2, t)
    ..lineTo(l + w - r2, t)
    ..cubicTo(l + w - r1, t, l + w, t + r1, l + w, t + r2)
    ..lineTo(l + w, t + h - r2)
    ..cubicTo(l + w, t + h - r1, l + w - r1, t + h, l + w - r2, t + h)
    ..lineTo(l + r2, t + h)
    ..cubicTo(l + r1, t + h, l, t + h - r1, l, t + h - r2)
    ..close();
}

class SquircleBorder extends OutlinedBorder {
  const SquircleBorder({
    required this.curvature,
    required this.strokeGradient,
    required this.strokeWidth,
    super.side = BorderSide.none,
  }) : assert(curvature >= 0 && curvature <= 10);

  final int curvature;
  final LinearGradient strokeGradient;
  final double strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      squirclePath(rect, curvature);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      squirclePath(rect.deflate(side.width), curvature);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side != BorderSide.none) {
      canvas.drawPath(getOuterPath(rect), side.toPaint());
    }
    final path = squirclePath(rect.deflate(strokeWidth / 2), curvature);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..blendMode = BlendMode.softLight
        ..shader = strokeGradient.createShader(rect),
    );
  }

  @override
  ShapeBorder scale(double t) => SquircleBorder(
        curvature: curvature,
        strokeGradient: strokeGradient,
        strokeWidth: strokeWidth * t,
        side: side.scale(t),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SquircleBorder &&
          curvature == other.curvature &&
          strokeGradient == other.strokeGradient &&
          strokeWidth == other.strokeWidth &&
          side == other.side;

  @override
  int get hashCode => Object.hash(curvature, strokeGradient, strokeWidth, side);

  @override
  SquircleBorder copyWith({
    int? curvature,
    LinearGradient? strokeGradient,
    double? strokeWidth,
    BorderSide? side,
  }) =>
      SquircleBorder(
        curvature: curvature ?? this.curvature,
        strokeGradient: strokeGradient ?? this.strokeGradient,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        side: side ?? this.side,
      );
}

class SecondaryDecoration extends Decoration {
  const SecondaryDecoration({
    required this.curvature,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final int curvature;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SecondaryBoxPainter(this, onChanged);
  }
}

class _SecondaryBoxPainter extends BoxPainter {
  _SecondaryBoxPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  final SecondaryDecoration decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    final c = decoration.curvature;

    // 1. Drop shadow: offset(1, 1), blur 2.0 (maskFilter blur radius of ~1.5)
    // Figma color: #1F1F1F @ 4% (#1F1F1F0A)
    final shadowPaint = Paint()
      ..color = const Color(0x0A1F1F1F)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5);
    canvas.drawPath(
      squirclePath(rect.shift(const Offset(1, 1)), c),
      shadowPaint,
    );

    // 2. Fill
    final fillPaint = Paint()
      ..color = decoration.fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(squirclePath(rect, c), fillPaint);

    // 3. Inner shadow: offset(-1, -1), blur 2.0. Figma color: #1F1F1F @ 6% (#1F1F1F0F)
    canvas.save();
    canvas.clipPath(squirclePath(rect, c));
    final outerRect = rect.inflate(10.0);
    final outerPath = Path()..addRect(outerRect);
    final offsetPath = squirclePath(rect.shift(const Offset(-1, -1)), c);
    final innerShadowPath = Path.combine(PathOperation.difference, outerPath, offsetPath);
    final innerShadowPaint = Paint()
      ..color = const Color(0x0F1F1F1F)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5);
    canvas.drawPath(innerShadowPath, innerShadowPaint);
    canvas.restore();

    // 4. Hairline stroke
    if (decoration.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = decoration.strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = decoration.strokeWidth;
      canvas.drawPath(squirclePath(rect.deflate(decoration.strokeWidth / 2), c), strokePaint);
    }
  }
}
