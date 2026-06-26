import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'squircle.dart';

Completer<ui.Image>? _loader;

class NoiseLayer extends StatefulWidget {
  const NoiseLayer({
    required this.child,
    required this.enabled,
    required this.opacity,
    required this.scale,
    required this.curvature,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double opacity;
  final double scale;
  final int curvature;

  @override
  State<NoiseLayer> createState() => _NoiseLayerState();
}

class _NoiseLayerState extends State<NoiseLayer> {
  ui.Image? _image;
  _NoisePainter? _painter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(NoiseLayer old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled ||
        old.opacity != widget.opacity ||
        old.scale != widget.scale ||
        old.curvature != widget.curvature) {
      _rebuildPainter();
    }
  }

  Future<void> _load() async {
    _loader ??= Completer()..complete(_loadImage());
    try {
      final image = await _loader!.future;
      if (mounted) {
        setState(() {
          _image = image;
          _rebuildPainter();
        });
      }
    } on Object {
      _loader = null; // allow retry on next mount
    }
  }

  static Future<ui.Image> _loadImage() async {
    // Package-qualified key so the asset resolves for any consumer of sav_ds.
    final data = await rootBundle.load(
      'packages/sav_ds/assets/images/noise.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  void _rebuildPainter() {
    _painter = (!widget.enabled || _image == null)
        ? null
        : _NoisePainter(
            _image!,
            widget.opacity,
            widget.scale,
            widget.curvature,
          );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: _painter != null,
      foregroundPainter: _painter,
      child: widget.child,
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter(this.image, this.opacity, this.scale, this.curvature);

  final ui.Image image;
  final double opacity;
  final double scale;
  final int curvature;

  late final Float64List _matrix = Matrix4.diagonal3Values(
    scale,
    scale,
    1,
  ).storage;

  late final _shader = ui.ImageShader(
    image,
    TileMode.repeated,
    TileMode.repeated,
    _matrix,
  );

  late final _paint = Paint()
    ..blendMode = BlendMode.softLight
    ..shader = _shader
    ..colorFilter = ColorFilter.mode(
      Color.fromRGBO(255, 255, 255, opacity),
      BlendMode.modulate,
    );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipPath(squirclePath(Offset.zero & size, curvature))
      ..drawRect(Offset.zero & size, _paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_NoisePainter old) =>
      old.opacity != opacity ||
      old.scale != scale ||
      old.image != image ||
      old.curvature != curvature;
}
