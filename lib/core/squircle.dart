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

class SavSurface extends Decoration {
  const SavSurface({
    this.curvature = 10,
    this.fillColor,
    this.fillGradient,
    this.shadows,
    this.dropShadowColor,
    this.dropShadowOffset,
    this.dropShadowBlur,
    this.innerShadowColor,
    this.innerShadowOffset,
    this.innerShadowBlur,
    this.strokeColor,
    this.strokeWidth = 0.0,
    this.strokeGradient,
    this.strokeSoftLight = false,
  });

  final int curvature;
  final Color? fillColor;
  final Gradient? fillGradient;
  final List<BoxShadow>? shadows;
  final Color? dropShadowColor;
  final Offset? dropShadowOffset;
  final double? dropShadowBlur;
  final Color? innerShadowColor;
  final Offset? innerShadowOffset;
  final double? innerShadowBlur;
  final Color? strokeColor;
  final double strokeWidth;
  final Gradient? strokeGradient;
  final bool strokeSoftLight;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is SavSurface) {
      return SavSurface.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is SavSurface) {
      return SavSurface.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  static SavSurface? lerp(SavSurface? a, SavSurface? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return SavSurface(
      curvature: t < 0.5 ? a.curvature : b.curvature,
      fillColor: Color.lerp(a.fillColor, b.fillColor, t),
      fillGradient: Gradient.lerp(a.fillGradient, b.fillGradient, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      dropShadowColor: Color.lerp(a.dropShadowColor, b.dropShadowColor, t),
      dropShadowOffset: Offset.lerp(a.dropShadowOffset, b.dropShadowOffset, t),
      dropShadowBlur: ui.lerpDouble(a.dropShadowBlur, b.dropShadowBlur, t),
      innerShadowColor: Color.lerp(a.innerShadowColor, b.innerShadowColor, t),
      innerShadowOffset: Offset.lerp(a.innerShadowOffset, b.innerShadowOffset, t),
      innerShadowBlur: ui.lerpDouble(a.innerShadowBlur, b.innerShadowBlur, t),
      strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t),
      strokeWidth: ui.lerpDouble(a.strokeWidth, b.strokeWidth, t) ?? 0.0,
      strokeGradient: Gradient.lerp(a.strokeGradient, b.strokeGradient, t),
      strokeSoftLight: t < 0.5 ? a.strokeSoftLight : b.strokeSoftLight,
    );
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SavSurfacePainter(this, onChanged);
  }
}

class _SavSurfacePainter extends BoxPainter {
  _SavSurfacePainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  final SavSurface decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    final c = decoration.curvature;

    // 1. Drop shadow
    if (decoration.shadows != null) {
      for (final shadow in decoration.shadows!) {
        final shadowRect = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
        final shadowPaint = Paint()
          ..color = shadow.color
          ..maskFilter = shadow.blurRadius > 0
              ? ui.MaskFilter.blur(ui.BlurStyle.normal, shadow.blurRadius)
              : null;
        canvas.drawPath(
          squirclePath(shadowRect, c),
          shadowPaint,
        );
      }
    } else if (decoration.dropShadowColor != null &&
        decoration.dropShadowOffset != null &&
        decoration.dropShadowBlur != null) {
      final shadowPaint = Paint()
        ..color = decoration.dropShadowColor!
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, decoration.dropShadowBlur!);
      canvas.drawPath(
        squirclePath(rect.shift(decoration.dropShadowOffset!), c),
        shadowPaint,
      );
    }

    // 2. Fill (color or gradient)
    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (decoration.fillGradient != null) {
      fillPaint.shader = decoration.fillGradient!.createShader(rect);
    } else if (decoration.fillColor != null) {
      fillPaint.color = decoration.fillColor!;
    } else {
      fillPaint.color = Colors.transparent;
    }
    canvas.drawPath(squirclePath(rect, c), fillPaint);

    // 3. Inner shadow
    if (decoration.innerShadowColor != null &&
        decoration.innerShadowOffset != null &&
        decoration.innerShadowBlur != null) {
      canvas.save();
      canvas.clipPath(squirclePath(rect, c));
      final outerRect = rect.inflate(10.0);
      final outerPath = Path()..addRect(outerRect);
      final offsetPath = squirclePath(rect.shift(decoration.innerShadowOffset!), c);
      final innerShadowPath = Path.combine(PathOperation.difference, outerPath, offsetPath);
      final innerShadowPaint = Paint()
        ..color = decoration.innerShadowColor!
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, decoration.innerShadowBlur!);
      canvas.drawPath(innerShadowPath, innerShadowPaint);
      canvas.restore();
    }

    // 4. Stroke / Border (solid or gradient, optionally soft light)
    if (decoration.strokeWidth > 0 && (decoration.strokeColor != null || decoration.strokeGradient != null)) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = decoration.strokeWidth;
      if (decoration.strokeSoftLight) {
        strokePaint.blendMode = BlendMode.softLight;
      }
      if (decoration.strokeGradient != null) {
        strokePaint.shader = decoration.strokeGradient!.createShader(rect);
      } else if (decoration.strokeColor != null) {
        strokePaint.color = decoration.strokeColor!;
      }
      canvas.drawPath(squirclePath(rect.deflate(decoration.strokeWidth / 2), c), strokePaint);
    }
  }
}
