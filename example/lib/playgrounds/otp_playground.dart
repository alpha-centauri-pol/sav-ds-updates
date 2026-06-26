import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import '../playground.dart';

class OTPPlayground extends StatefulWidget {
  const OTPPlayground({super.key});
  @override
  State<OTPPlayground> createState() => _OTPPlaygroundState();
}

class _OTPPlaygroundState extends State<OTPPlayground> {
  int _length = 6;
  OTPInputState _state = OTPInputState.normal;
  late final TextEditingController _controller = TextEditingController(text: '123');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('OTPInput(\n');
    if (_length != 6) buffer.writeln('  length: $_length,');
    if (_state != OTPInputState.normal) {
      buffer.writeln('  state: OTPInputState.${_state.name},');
    }
    buffer
      ..writeln('  onCompleted: (val) {},')
      ..write(')');

    return PlaygroundStage(
      id: 'OTPInput',
      preview: OTPInput(
        length: _length,
        state: _state,
        controller: _controller,
        onCompleted: (_) {},
      ),
      code: buffer.toString(),
      props: const [
        PropSpec(
          name: 'length',
          type: 'int',
          description: 'Number of digits (4-8)',
        ),
        PropSpec(
          name: 'state',
          type: 'OTPInputState',
          options: 'normal, error, disabled',
          description: 'Interactive state',
        ),
        PropSpec(
          name: 'onCompleted',
          type: 'ValueChanged<String>',
          description: 'Callback when all digits are filled',
        ),
      ],
      controls: [
        PropSlider(
          label: 'Length',
          value: _length.toDouble(),
          min: 4,
          max: 8,
          divisions: 4,
          onChanged: (v) => setState(() => _length = v.toInt()),
        ),
        PropEnum<OTPInputState>(
          label: 'State',
          value: _state,
          values: OTPInputState.values,
          labelOf: (v) => v.name,
          onChanged: (v) => setState(() => _state = v),
        ),
      ],
    );
  }
}
