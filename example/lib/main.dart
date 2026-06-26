import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sav_ds/sav_ds.dart';
import 'playground_registry.dart';
import 'playgrounds.dart';

void main() => runApp(const SavApp());

class SavApp extends StatelessWidget {
  const SavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sav Design System',
      debugShowCheckedModeBanner: false,
      home: GalleryScaffold(),
    );
  }
}

class ShimmerTitle extends StatefulWidget {
  const ShimmerTitle({super.key});

  @override
  State<ShimmerTitle> createState() => _ShimmerTitleState();
}

class _ShimmerTitleState extends State<ShimmerTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerShimmer() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _triggerShimmer,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          if (progress == 0.0 || progress == 1.0) {
            return Text(
              'Sav Design System',
              style: AppTextStyles.calloutCta.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              (progress - 0.4).clamp(0.0, 1.0),
              progress.clamp(0.0, 1.0),
              (progress + 0.4).clamp(0.0, 1.0),
            ],
            colors: const [
              AppColors.obsidian,
              Color(0xFFE2D6FF),
              AppColors.obsidian,
            ],
          );

          return NoiseLayer(
            enabled: true,
            opacity: 0.25,
            scale: 0.5,
            curvature: 4,
            child: ShaderMask(
              shaderCallback: gradient.createShader,
              blendMode: BlendMode.srcIn,
              child: Text(
                'Sav Design System',
                style: AppTextStyles.calloutCta.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GalleryScaffold extends StatefulWidget {
  const GalleryScaffold({super.key});

  @override
  State<GalleryScaffold> createState() => _GalleryScaffoldState();
}

class _GalleryScaffoldState extends State<GalleryScaffold> {
  int _tabIndex = 0;
  int _prevTabIndex = 0;

  Widget _buildGlobalFab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.obsidian,
      child: const Icon(Icons.settings_outlined, color: Colors.white),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const GlobalControlsSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lumen,
      appBar: AppBar(
        backgroundColor: AppColors.lumen,
        elevation: 0,
        title: const ShimmerTitle(),
      ),
      floatingActionButton: _buildGlobalFab(context),
      bottomNavigationBar: Container(
        height: 60 + MediaQuery.of(context).padding.bottom,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.hairline),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    height: 3,
                    child: AnimatedAlign(
                      duration: AppMotion.duration(
                        context,
                        const Duration(milliseconds: 250),
                      ),
                      curve: AppMotion.curveOut,
                      alignment: Alignment(-1.0 + (_tabIndex * (2.0 / 3.0)), 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.25,
                        child: Center(
                          child: Container(
                            width: 24,
                            decoration: BoxDecoration(
                              color: AppColors.obsidian,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      final itemLabels = [
                        'Buttons',
                        'Inputs',
                        'Controls',
                        'Indicators',
                      ];
                      final itemIcons = [
                        Icons.smart_button_rounded,
                        Icons.input_rounded,
                        Icons.toggle_on_rounded,
                        Icons.label_important_rounded,
                      ];
                      final isSelected = index == _tabIndex;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _prevTabIndex = _tabIndex;
                              _tabIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                itemIcons[index],
                                color: isSelected
                                    ? AppColors.obsidian
                                    : AppColors.slate,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                itemLabels[index],
                                style: AppTextStyles.captionRegular.copyWith(
                                  fontSize: 11,
                                  color: isSelected
                                      ? AppColors.obsidian
                                      : AppColors.slate,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 300),
          ),
          switchInCurve: AppMotion.curveOut,
          switchOutCurve: AppMotion.curveGentleOut,
          transitionBuilder: (child, animation) {
            final reduceMotion = AppMotion.reduce(context);
            if (reduceMotion) {
              return FadeTransition(opacity: animation, child: child);
            }
            final isEntering = child.key == ValueKey<int>(_tabIndex);
            final directionMultiplier = (_tabIndex >= _prevTabIndex)
                ? 1.0
                : -1.0;

            final Tween<Offset> slideTween;
            if (isEntering) {
              slideTween = Tween<Offset>(
                begin: Offset(directionMultiplier * 1.0, 0),
                end: Offset.zero,
              );
            } else {
              slideTween = Tween<Offset>(
                begin: Offset(-directionMultiplier * 1.0, 0),
                end: Offset.zero,
              );
            }

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideTween.animate(animation),
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              children: <Widget>[
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          child: SizedBox(
            key: ValueKey<int>(_tabIndex),
            child: switch (_tabIndex) {
              0 => const ButtonsTab(),
              1 => const InputsTab(),
              2 => const ControlsTab(),
              _ => const IndicatorsTab(),
            },
          ),
        ),
      ),
    );
  }
}

class GlobalControlsSheet extends StatelessWidget {
  const GlobalControlsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Global Controls',
            style: AppTextStyles.calloutCta.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text('Active Playground Snippets', style: AppTextStyles.bodyBold),
          const SizedBox(height: 16),
          ValueListenableBuilder<Map<String, String>>(
            valueListenable: PlaygroundRegistry.instance.snippets,
            builder: (context, map, _) {
              if (map.isEmpty) {
                return const Text(
                  'No snippets generated yet.',
                  style: TextStyle(color: AppColors.slate),
                );
              }
              return Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lumen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: ListView(
                  children: map.entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '// ${e.key}',
                                style: AppTextStyles.captionRegular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.value,
                                style: AppTextStyles.captionRegular.copyWith(
                                  fontFamily: 'monospace',
                                  color: AppColors.obsidian,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Copy All Snippets',
            variant: AppButtonVariant.primary,
            width: AppButtonWidth.full,
            onPressed: () {
              final map = PlaygroundRegistry.instance.snippets.value;
              final buffer = StringBuffer();
              for (final e in map.entries) {
                buffer
                  ..writeln('// ${e.key}')
                  ..writeln(e.value)
                  ..writeln();
              }
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 1: BUTTONS
// ----------------------------------------------------
class ButtonsTab extends StatelessWidget {
  const ButtonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          AccordionWidget(title: 'Button Playground', child: const ButtonPlayground()),
          SectionCardWidget(title: 'Primary (Gradient)', children: [
            RowWidget(title: 'Sizes', items: [
              AppButton(
                label: 'Small',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              AppButton(
                label: 'Regular',
                variant: AppButtonVariant.primary,
                onPressed: () {},
              ),
              AppButton(
                label: 'Large',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                onPressed: () {},
              ),
            ]),
          ]),
          SectionCardWidget(title: 'Secondary (White Material)', children: [
            RowWidget(title: 'Sizes', items: [
              AppButton(
                label: 'Small',
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              AppButton(label: 'Regular', onPressed: () {}),
              AppButton(
                label: 'Large',
                size: AppButtonSize.large,
                onPressed: () {},
              ),
            ]),
          ]),
          SectionCardWidget(title: 'Inline (Green Gradient)', children: [
            RowWidget(title: 'Sizes', items: [
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
          SectionCardWidget(title: 'States & Layout', children: [
            RowWidget(title: 'Width Layouts', items: [
              AppButton(label: 'Hug Width', onPressed: () {}),
              AppButton(
                label: 'Half Width',
                width: AppButtonWidth.half,
                onPressed: () {},
              ),
              AppButton(
                label: 'Full Width',
                width: AppButtonWidth.full,
                onPressed: () {},
              ),
            ]),
            RowWidget(title: 'Icon Positions', items: [
              AppButton(
                label: 'Leading Icon',
                icon: AppButtonIcon.leading,
                onPressed: () {},
              ),
              AppButton(
                label: 'Trailing Icon',
                icon: AppButtonIcon.trailing,
                onPressed: () {},
              ),
              AppButton(
                label: '',
                icon: AppButtonIcon.iconOnly,
                onPressed: () {},
              ),
            ]),
            RowWidget(title: 'Interactive States', items: [
              AppButton(label: 'Normal', onPressed: () {}),
              AppButton(
                label: 'Disabled',
                state: AppButtonState.disabled,
                onPressed: () {},
              ),
              AppButton(
                label: 'Loading',
                state: AppButtonState.loading,
                onPressed: () {},
              ),
            ]),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 2: INPUTS
// ----------------------------------------------------
class InputsTab extends StatefulWidget {
  const InputsTab({super.key});

  @override
  State<InputsTab> createState() => _InputsTabState();
}

class _InputsTabState extends State<InputsTab> {
  final _textController = TextEditingController(text: 'Filled text');
  final _otpController = TextEditingController();
  final _amountController = TextEditingController(text: '124.50');
  final _amountController2 = TextEditingController(text: '2500.00');

  @override
  void dispose() {
    _textController.dispose();
    _otpController.dispose();
    _amountController.dispose();
    _amountController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          AccordionWidget(
            title: 'InputField Playground',
            child: const InputFieldPlayground(),
          ),
          AccordionWidget(title: 'OTPInput Playground', child: const OTPPlayground()),
          AccordionWidget(title: 'AmountInput Playground', child: const AmountPlayground()),
          SectionCardWidget(title: 'InputField (Boxed & Underline)', children: [
            const InputField(
              label: 'Email Address',
              placeholder: 'Enter your email...',
              helperText: 'We will send a code here',
            ),
            InputField(
              label: 'Phone Number',
              placeholder: '50 123 4567',
              leading: InputFieldLeading.prefix,
              prefixText: '🇦🇪 +971',
              controller: _textController,
            ),
            const InputField(
              label: 'Password Input (Error)',
              placeholder: 'Password',
              state: InputFieldState.error,
              helperText: 'Weak or invalid password details',
            ),
            const InputField(
              label: 'Username (Disabled)',
              placeholder: 'Username',
              state: InputFieldState.disabled,
            ),
            const InputField(
              label: 'Underline Variant',
              variant: InputFieldVariant.underline,
              placeholder: 'Type something...',
            ),
          ]),
          SectionCardWidget(title: 'SearchField Preset', children: [
            InputField.search(
              placeholder: 'Search banking or countries...',
            ),
          ]),
          SectionCardWidget(title: 'OTPInput Cell Grid', children: [
            Text(
              'Default Code OTP Cells (6 Length):',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            OTPInput(
              controller: _otpController,
            ),
            Text(
              'Bronze Error OTP Cells:',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            const OTPInput(
              state: OTPInputState.error,
            ),
          ]),
          SectionCardWidget(title: 'AmountInput (Obviously Numeric)', children: [
            Text(
              'Gold Standard Intent:',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            AmountInput(
              intent: AmountInputIntent.gold,
              nudgeText: '0.1791g ⓘ',
              controller: _amountController,
            ),
            const SizedBox(height: 12),
            Text(
              'Purple Power Intent:',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            AmountInput(
              currency: 'USD',
              intent: AmountInputIntent.purple,
              controller: _amountController2,
            ),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 3: CONTROLS
// ----------------------------------------------------
class ControlsTab extends StatefulWidget {
  const ControlsTab({super.key});

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab> {
  int _pillIndex = 0;
  int _underIndex = 0;

  bool _row1Selected = true;
  bool _row2Selected = false;
  bool _row3Selected = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          AccordionWidget(
            title: 'SegmentedControl Playground',
            child: const SegmentedPlayground(),
          ),
          AccordionWidget(
            title: 'SelectableRow Playground',
            child: const SelectableRowPlayground(),
          ),
          SectionCardWidget(title: 'SegmentedControl (Pill Style)', children: [
            Text(
              'Horizontal Pill tabs (md size):',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            SegmentedControl(
              items: const [
                SegmentedItem(label: 'Jan'),
                SegmentedItem(label: 'Feb'),
                SegmentedItem(label: 'Mar'),
              ],
              selected: _pillIndex,
              onChanged: (idx) => setState(() => _pillIndex = idx),
            ),
            Text(
              'Horizontal Pill tabs (sm size + icons):',
              style: AppTextStyles.captionRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            SegmentedControl(
              items: const [
                SegmentedItem(label: 'Lock', icon: Icons.lock_outline_rounded),
                SegmentedItem(label: 'Unlock', icon: Icons.lock_open_rounded),
              ],
              selected: _pillIndex == 2 ? 0 : _pillIndex,
              size: SegmentedControlSize.sm,
              content: SegmentedControlContent.iconText,
              onChanged: (idx) => setState(() => _pillIndex = idx),
            ),
          ]),
          SectionCardWidget(title: 'SegmentedControl (Underline / Tabs)', children: [
            SegmentedControl(
              items: const [
                SegmentedItem(label: 'Range 1D'),
                SegmentedItem(label: '1W'),
                SegmentedItem(label: '1M'),
                SegmentedItem(label: 'All'),
              ],
              style: SegmentedControlStyle.underline,
              selected: _underIndex,
              onChanged: (idx) => setState(() => _underIndex = idx),
            ),
          ]),
          SectionCardWidget(title: 'SelectableRow (checkmark vs radioDot)', children: [
            SelectableRow(
              label: 'United Arab Emirates',
              secondary: 'Dialing code: +971',
              leadingWidget: Text('🇦🇪', style: AppTextStyles.bodyRegular.copyWith(fontSize: 18)),
              selected: _row1Selected,
              onTap: () => setState(() => _row1Selected = !_row1Selected),
            ),
            SelectableRow(
              label: 'English Language Option',
              secondary: 'En / Translation set',
              indicator: SelectableRowIndicator.radioDot,
              selected: _row2Selected,
              onTap: () => setState(() => _row2Selected = !_row2Selected),
            ),
            SelectableRow(
              label: 'Payment Method (Disabled Row)',
              secondary: 'Apple Pay Linked',
              selected: _row3Selected,
              state: SelectableRowState.disabled,
              onTap: () => setState(() => _row3Selected = !_row3Selected),
            ),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 4: INDICATORS
// ----------------------------------------------------
class IndicatorsTab extends StatelessWidget {
  const IndicatorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          AccordionWidget(title: 'Badge Playground', child: const BadgePlayground()),
          AccordionWidget(title: 'Chip Playground', child: const ChipPlayground()),
          SectionCardWidget(title: 'Badge Indicators (Count & Dot)', children: [
            RowWidget(title: 'Dot status indicators', items: [
              const SavBadge(type: BadgeType.dot, color: AppColors.positive),
              const SavBadge(
                type: BadgeType.dot,
                size: BadgeSize.md,
                color: AppColors.negative,
              ),
              const SavBadge(
                type: BadgeType.dot,
                size: BadgeSize.lg,
                color: AppColors.info,
              ),
            ]),
            RowWidget(title: 'Count indicators (sm / md / lg)', items: [
              const SavBadge(value: '4'),
              const SavBadge(size: BadgeSize.md, value: '9+'),
              const SavBadge(size: BadgeSize.lg, value: '99+'),
            ]),
          ]),
          SectionCardWidget(title: 'SavChip Primitive', children: [
            RowWidget(title: 'Sizes (sm / lg)', items: [
              const SavChip(label: '9+'),
              const SavChip(
                label: 'En',
                size: SavChipSize.lg,
                showLgNoise: true,
              ),
            ]),
            RowWidget(title: 'Tones (success / neutral / info)', items: [
              const SavChip(label: 'Instant', tone: SavChipTone.success),
              const SavChip(label: 'Coming Soon', tone: SavChipTone.neutral),
              const SavChip(label: 'Gold price', tone: SavChipTone.info),
            ]),
            RowWidget(title: 'Negative / Overdue', items: [
              const SavChip(label: 'Overdue', tone: SavChipTone.negative),
              const SavChip(label: '1-2 Days'),
            ]),
            RowWidget(title: 'Leading Icon Container', items: [
              const SavChip(
                label: 'Merchant',
                tone: SavChipTone.neutral,
                leadingIcon: Icons.storefront_rounded,
              ),
              const SavChip(
                label: 'Bank Transfer',
                leadingIcon: Icons.account_balance_rounded,
              ),
            ]),
          ]),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// COMMON WIDGET BUILDERS
// ----------------------------------------------------
class HeadingWidget extends StatelessWidget {
  const HeadingWidget(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.calloutBold.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.obsidian,
      ),
    );
  }
}

class AccordionWidget extends StatelessWidget {
  const AccordionWidget({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: HeadingWidget(title),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          initiallyExpanded: initiallyExpanded,
          children: [child],
        ),
      ),
    );
  }
}

class SectionCardWidget extends StatelessWidget {
  const SectionCardWidget({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates the paint-heavy SavSurface shadows/noise inside
    // this card so scrolling the gallery doesn't repaint them every frame.
    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: HeadingWidget(title),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowWidget extends StatelessWidget {
  const RowWidget({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          title,
          style: AppTextStyles.captionRegular.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.slate,
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: items,
        ),
      ],
    );
  }
}
