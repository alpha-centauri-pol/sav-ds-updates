import 'package:flutter/material.dart';
import 'core/tokens.dart';
import 'components/app_button.dart';
import 'dev/color_picker.dart';

void main() => runApp(const SavApp());

class SavApp extends StatelessWidget {
  const SavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sav Design System',
      debugShowCheckedModeBanner: false,
      home: ButtonGallery(),
    );
  }
}

class ButtonGallery extends StatelessWidget {
  const ButtonGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lumen,
      appBar: AppBar(
        backgroundColor: AppColors.lumen,
        elevation: 0,
        title: Text('Sav Button System Gallery', style: AppTextStyles.headline),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                // Live Color Picker Preview Section
                const LivePreviewDemo(),

                const Divider(height: 32),

                // Variants x Sizes Grid
                Text('Variants × Sizes', style: AppTextStyles.headline),
                _buildSectionCard([
                  _buildSubSection('Primary (small / regular / large)', [
                    AppButton(
                      label: 'Primary Small',
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.small,
                      onPressed: () {},
                    ),
                    AppButton(
                      label: 'Primary Regular',
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.regular,
                      onPressed: () {},
                    ),
                    AppButton(
                      label: 'Primary Large',
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.large,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Secondary (small / regular / large)', [
                    AppButton(
                      label: 'Secondary Small',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      onPressed: () {},
                    ),
                    AppButton(
                      label: 'Secondary Regular',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.regular,
                      onPressed: () {},
                    ),
                    AppButton(
                      label: 'Secondary Large',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.large,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Inline / Link (small / regular / large)', [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        label: '+ Buy Small',
                        variant: AppButtonVariant.inline,
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        label: '+ Buy Regular',
                        variant: AppButtonVariant.inline,
                        size: AppButtonSize.regular,
                        onPressed: () {},
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        label: '+ Buy Large',
                        variant: AppButtonVariant.inline,
                        size: AppButtonSize.large,
                        onPressed: () {},
                      ),
                    ),
                  ]),
                ]),

                // Layout Width Options
                Text('Layout Widths (Secondary Regular)', style: AppTextStyles.headline),
                _buildSectionCard([
                  _buildSubSection('Hug Content', [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        label: 'Hug Width',
                        variant: AppButtonVariant.secondary,
                        width: AppButtonWidth.hug,
                        onPressed: () {},
                      ),
                    ),
                  ]),
                  _buildSubSection('Half Width', [
                    AppButton(
                      label: 'Half Width',
                      variant: AppButtonVariant.secondary,
                      width: AppButtonWidth.half,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Full Width', [
                    AppButton(
                      label: 'Full Width',
                      variant: AppButtonVariant.secondary,
                      width: AppButtonWidth.full,
                      onPressed: () {},
                    ),
                  ]),
                ]),

                // Icon Slots Options
                Text('Icon Layouts (Primary Regular)', style: AppTextStyles.headline),
                _buildSectionCard([
                  _buildSubSection('None', [
                    AppButton(
                      label: 'No Icon',
                      variant: AppButtonVariant.primary,
                      icon: AppButtonIcon.none,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Leading Icon', [
                    AppButton(
                      label: 'Leading Icon',
                      variant: AppButtonVariant.primary,
                      icon: AppButtonIcon.leading,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Trailing Icon', [
                    AppButton(
                      label: 'Trailing Icon',
                      variant: AppButtonVariant.primary,
                      icon: AppButtonIcon.trailing,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Icon Only (Square)', [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        label: '',
                        variant: AppButtonVariant.primary,
                        icon: AppButtonIcon.iconOnly,
                        onPressed: () {},
                      ),
                    ),
                  ]),
                ]),

                // States
                Text('States (Secondary Large)', style: AppTextStyles.headline),
                _buildSectionCard([
                  _buildSubSection('Normal', [
                    AppButton(
                      label: 'Active Button',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.large,
                      state: AppButtonState.normal,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Disabled (40% Opacity)', [
                    AppButton(
                      label: 'Disabled Button',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.large,
                      state: AppButtonState.disabled,
                      onPressed: () {},
                    ),
                  ]),
                  _buildSubSection('Loading (Holds size)', [
                    AppButton(
                      label: 'Loading Button',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.large,
                      state: AppButtonState.loading,
                      onPressed: () {},
                    ),
                  ]),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(title, style: AppTextStyles.captionRegular),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: buttons,
        ),
      ],
    );
  }
}

class LivePreviewDemo extends StatefulWidget {
  const LivePreviewDemo({super.key});

  @override
  State<LivePreviewDemo> createState() => _LivePreviewDemoState();
}

class _LivePreviewDemoState extends State<LivePreviewDemo> {
  String _target = 'Fill';
  Color _fillColor = const Color(0xFFFFFFFF);
  Color _labelColor = const Color(0xFF1F1F1F);
  Color _strokeColor = const Color(0xFFE6E6E9);

  @override
  Widget build(BuildContext context) {
    final currentColor = switch (_target) {
      'Fill' => _fillColor,
      'Label' => _labelColor,
      'Stroke' => _strokeColor,
      _ => Colors.white,
    };

    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Customization Preview', style: AppTextStyles.calloutBold),
            const SizedBox(height: 16),
            Center(
              child: AppButton(
                label: 'Preview Button',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.large,
                fillColor: _fillColor,
                labelColor: _labelColor,
                strokeColor: _strokeColor,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Override Target:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: ['Fill', 'Label', 'Stroke'].map((t) {
                final isSelected = t == _target;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _target = t);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DevColorPicker(
              initialColor: currentColor,
              onChanged: (color) {
                setState(() {
                  switch (_target) {
                    case 'Fill':
                      _fillColor = color;
                      break;
                    case 'Label':
                      _labelColor = color;
                      break;
                    case 'Stroke':
                      _strokeColor = color;
                      break;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
