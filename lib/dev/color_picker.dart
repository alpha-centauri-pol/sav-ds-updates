import 'package:flutter/material.dart';

class DevColorPicker extends StatefulWidget {
  const DevColorPicker({
    super.key,
    required this.initialColor,
    required this.onChanged,
  });

  final Color initialColor;
  final ValueChanged<Color> onChanged;

  @override
  State<DevColorPicker> createState() => _DevColorPickerState();
}

class _DevColorPickerState extends State<DevColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  void didUpdateWidget(DevColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor != widget.initialColor) {
      _hsvColor = HSVColor.fromColor(widget.initialColor);
    }
  }

  void _updateColor(HSVColor newColor) {
    setState(() {
      _hsvColor = newColor;
    });
    widget.onChanged(newColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      const Color(0xFFCFBD63), // Gold
      const Color(0xFF5B9A74), // Green (Lush Capital)
      const Color(0xFFFFFFFF), // White
      const Color(0xFF1F1F1F), // Obsidian
      const Color(0xFF7A7A7A), // Slate
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Presets row
        const Text(
          'Presets:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: presets.map((color) {
            final isSelected = color.toARGB32() == _hsvColor.toColor().toARGB32();
            return GestureDetector(
              onTap: () => _updateColor(HSVColor.fromColor(color)),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Hue slider
        Text('Hue: ${_hsvColor.hue.round()}°'),
        Slider(
          value: _hsvColor.hue,
          min: 0,
          max: 360,
          onChanged: (val) => _updateColor(_hsvColor.withHue(val)),
        ),
        // Saturation slider
        Text('Saturation: ${(_hsvColor.saturation * 100).round()}%'),
        Slider(
          value: _hsvColor.saturation,
          min: 0,
          max: 1,
          onChanged: (val) => _updateColor(_hsvColor.withSaturation(val)),
        ),
        // Value slider
        Text('Value: ${(_hsvColor.value * 100).round()}%'),
        Slider(
          value: _hsvColor.value,
          min: 0,
          max: 1,
          onChanged: (val) => _updateColor(_hsvColor.withValue(val)),
        ),
        // Alpha slider
        Text('Alpha (Opacity): ${(_hsvColor.alpha * 100).round()}%'),
        Slider(
          value: _hsvColor.alpha,
          min: 0,
          max: 1,
          onChanged: (val) => _updateColor(_hsvColor.withAlpha(val)),
        ),
      ],
    );
  }
}
