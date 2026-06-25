import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/tokens.dart';
import 'color_picker.dart';
import 'global_config.dart';

class PropSpec {
  const PropSpec({
    required this.name,
    required this.type,
    this.options,
    required this.description,
  });
  final String name;
  final String type;
  final String? options;
  final String description;
}

class PlaygroundStage extends StatelessWidget {
  const PlaygroundStage({
    super.key,
    required this.id,
    required this.preview,
    required this.controls,
    required this.code,
    required this.props,
  });

  final String id;
  final Widget preview;
  final List<Widget> controls;
  final String code;
  final List<PropSpec> props;

  @override
  Widget build(BuildContext context) {
    // Broadcast the snippet
    PlaygroundRegistry.instance.register(id, code);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview Area
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.lumen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(child: preview),
        ),
        
        // Controls Area
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: AppColors.hairline),
              right: BorderSide(color: AppColors.hairline),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: controls,
          ),
        ),
        
        // Code Block
        _CodeBlock(code: code),
        
        // Props Table
        _PropsTable(props: props),
      ],
    );
  }
}

class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.code});
  final String code;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _expanded = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(
          left: BorderSide(color: AppColors.obsidian),
          right: BorderSide(color: AppColors.obsidian),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Code Snippet', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      widget.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(_copied ? Icons.check : Icons.copy, color: Colors.white, size: 16),
                      onPressed: _copy,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PropsTable extends StatefulWidget {
  const _PropsTable({required this.props});
  final List<PropSpec> props;

  @override
  State<_PropsTable> createState() => _PropsTableState();
}

class _PropsTableState extends State<_PropsTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: AppColors.hairline)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Props API', style: AppTextStyles.bodyBold),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.slate,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: DataTable(
                    headingRowHeight: 36,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(label: Text('Prop', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Options', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: widget.props.map((p) {
                      return DataRow(cells: [
                        DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
                        DataCell(Text(p.type, style: const TextStyle(color: AppColors.wealthWeave600, fontFamily: 'monospace'))),
                        DataCell(Text(p.options ?? '-')),
                        DataCell(Text(p.description)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Generic Property Controls ---

class PropEnum<T> extends StatelessWidget {
  const PropEnum({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption550),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((v) {
            final selected = v == value;
            return ChoiceChip(
              label: Text(labelOf(v)),
              selected: selected,
              onSelected: (s) {
                if (s) onChanged(v);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PropToggle extends StatelessWidget {
  const PropToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption550),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class PropText extends StatelessWidget {
  const PropText({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption550),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class PropSlider extends StatelessWidget {
  const PropSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}', style: AppTextStyles.caption550),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class PropColor extends StatefulWidget {
  const PropColor({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color? value;
  final ValueChanged<Color?> onChanged;

  @override
  State<PropColor> createState() => _PropColorState();
}

class _PropColorState extends State<PropColor> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: AppTextStyles.caption550),
            Row(
              children: [
                if (widget.value != null)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: widget.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairline),
                    ),
                  ),
                if (widget.value != null)
                  TextButton(
                    onPressed: () => widget.onChanged(null),
                    child: const Text('Clear'),
                  ),
                IconButton(
                  icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            )
          ],
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DevColorPicker(
              initialColor: widget.value ?? Colors.black,
              onChanged: widget.onChanged,
            ),
          ),
      ],
    );
  }
}
