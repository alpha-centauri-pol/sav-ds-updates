import 'package:flutter/material.dart';
import 'package:sav_ds/sav_ds.dart';
import 'perf_probe.dart';

class PerfLabScreen extends StatefulWidget {
  const PerfLabScreen({super.key});

  @override
  State<PerfLabScreen> createState() => _PerfLabScreenState();
}

class _PerfLabScreenState extends State<PerfLabScreen> with TickerProviderStateMixin {
  late final AnimationController _dummyTicker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  // AppButton
  bool _appButtonShadows = true;
  bool _appButtonNoise = true;
  String _appButtonResult = '--';
  bool _appButtonTesting = false;
  double? _appButtonBaseline;

  // OTPInput
  bool _otpGradient = true;
  bool _otpAnimate = true;
  String _otpResult = '--';
  bool _otpTesting = false;
  double? _otpBaseline;
  final TextEditingController _otpController = TextEditingController(text: '123456');

  // SavChip
  bool _chipSurface = true;
  bool _chipNoise = true;
  String _chipResult = '--';
  bool _chipTesting = false;
  double? _chipBaseline;

  // SelectableRow
  bool _rowAnimate = true;
  bool _rowFlash = true;
  String _rowResult = '--';
  bool _rowTesting = false;
  double? _rowBaseline;
  bool _rowSelected = true;

  // AmountInput
  bool _amountGradient = true;
  bool _amountMotion = true;
  bool _amountTextAnimate = true;
  String _amountResult = '--';
  bool _amountTesting = false;
  double? _amountBaseline;
  final TextEditingController _amountController = TextEditingController(text: '1,234.56');

  // SavBadge
  bool _badgeSurface = true;
  bool _badgeAnimate = true;
  String _badgeResult = '--';
  bool _badgeTesting = false;
  double? _badgeBaseline;

  // InputField
  bool _inputSurface = true;
  bool _inputShadows = true;
  bool _inputLeftNoise = true;
  String _inputResult = '--';
  bool _inputTesting = false;
  double? _inputBaseline;

  // SegmentedControl
  bool _segSurface = true;
  bool _segAnimate = true;
  String _segResult = '--';
  bool _segTesting = false;
  double? _segBaseline;
  int _segSelected = 0;

  @override
  void dispose() {
    _dummyTicker.dispose();
    _otpController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _runTest(
    VoidCallback onStart,
    VoidCallback onEnd,
    void Function(double avgMs) onComplete,
    void Function() onError,
  ) async {
    onStart();
    _dummyTicker.repeat();
    
    try {
      int totalMicroseconds = 0;
      const int iterations = 5;
      for (int i = 0; i < iterations; i++) {
        final duration = await PerfProbe.measureRasterTime(frames: 60);
        totalMicroseconds += duration.inMicroseconds;
      }
      final avgMicroseconds = totalMicroseconds / iterations;
      onComplete(avgMicroseconds / 1000.0);
    } catch (e) {
      onError();
    } finally {
      _dummyTicker.stop();
      onEnd();
    }
  }

  String _formatResult(double current, double? baseline) {
    final currentStr = '${current.toStringAsFixed(2)} ms / frame';
    if (baseline == null) {
      return currentStr;
    }
    
    final delta = current - baseline;
    final percent = (delta / baseline) * 100;
    final sign = delta > 0 ? '+' : '';
    
    // Check significance (> 10% or > 1ms)
    final isSignificant = percent.abs() > 10.0 || delta.abs() > 1.0;
    final sigTag = isSignificant ? ' [Significant]' : '';
    
    return '$currentStr\n($sign${delta.toStringAsFixed(2)} ms, $sign${percent.toStringAsFixed(1)}%)$sigTag';
  }

  Color _getResultColor(double? current, double? baseline) {
    if (current == null || baseline == null) return AppColors.obsidian;
    final delta = current - baseline;
    if (delta.abs() < 0.1) return AppColors.obsidian;
    return delta > 0 ? AppColors.negative : AppColors.positive;
  }

  Widget _buildSection({
    required String title,
    required Widget component,
    required List<Widget> controls,
    required String resultText,
    required Color resultColor,
    required bool isTesting,
    required double? baseline,
    required VoidCallback onRunTest,
    required VoidCallback onSetBaseline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyBold),
              if (baseline != null)
                Text(
                  'Baseline: ${baseline.toStringAsFixed(2)} ms',
                  style: AppTextStyles.captionRegular.copyWith(color: AppColors.slate),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Component Preview
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lumen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedBuilder(
              animation: _dummyTicker,
              builder: (context, child) {
                return component;
              }
            ),
          ),
          const SizedBox(height: 16),
          // Controls
          ...controls,
          const SizedBox(height: 16),
          // Actions & Result
          Row(
            children: [
              AppButton(
                key: Key('set_baseline_$title'),
                label: 'Set Baseline',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                state: isTesting ? AppButtonState.disabled : AppButtonState.normal,
                onPressed: onSetBaseline,
              ),
              const SizedBox(width: 8),
              AppButton(
                key: Key('run_test_$title'),
                label: isTesting ? 'Testing...' : 'Test (5x60)',
                size: AppButtonSize.small,
                state: isTesting ? AppButtonState.loading : AppButtonState.normal,
                onPressed: isTesting ? null : onRunTest,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  resultText,
                  style: AppTextStyles.captionRegular.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Handlers ---
  
  void _runAppButton(bool asBaseline) => _runTest(
    () => setState(() { _appButtonTesting = true; _appButtonResult = '--'; }),
    () => setState(() => _appButtonTesting = false),
    (avg) => setState(() {
      if (asBaseline) _appButtonBaseline = avg;
      _appButtonResult = _formatResult(avg, _appButtonBaseline);
    }),
    () => setState(() => _appButtonResult = 'Error'),
  );

  void _runOTPInput(bool asBaseline) => _runTest(
    () => setState(() { _otpTesting = true; _otpResult = '--'; }),
    () => setState(() => _otpTesting = false),
    (avg) => setState(() {
      if (asBaseline) _otpBaseline = avg;
      _otpResult = _formatResult(avg, _otpBaseline);
    }),
    () => setState(() => _otpResult = 'Error'),
  );

  void _runSavChip(bool asBaseline) => _runTest(
    () => setState(() { _chipTesting = true; _chipResult = '--'; }),
    () => setState(() => _chipTesting = false),
    (avg) => setState(() {
      if (asBaseline) _chipBaseline = avg;
      _chipResult = _formatResult(avg, _chipBaseline);
    }),
    () => setState(() => _chipResult = 'Error'),
  );

  void _runSelectableRow(bool asBaseline) => _runTest(
    () => setState(() { _rowTesting = true; _rowResult = '--'; }),
    () => setState(() => _rowTesting = false),
    (avg) => setState(() {
      if (asBaseline) _rowBaseline = avg;
      _rowResult = _formatResult(avg, _rowBaseline);
    }),
    () => setState(() => _rowResult = 'Error'),
  );

  void _runAmountInput(bool asBaseline) => _runTest(
    () => setState(() { _amountTesting = true; _amountResult = '--'; }),
    () => setState(() => _amountTesting = false),
    (avg) => setState(() {
      if (asBaseline) _amountBaseline = avg;
      _amountResult = _formatResult(avg, _amountBaseline);
    }),
    () => setState(() => _amountResult = 'Error'),
  );

  void _runSavBadge(bool asBaseline) => _runTest(
    () => setState(() { _badgeTesting = true; _badgeResult = '--'; }),
    () => setState(() => _badgeTesting = false),
    (avg) => setState(() {
      if (asBaseline) _badgeBaseline = avg;
      _badgeResult = _formatResult(avg, _badgeBaseline);
    }),
    () => setState(() => _badgeResult = 'Error'),
  );

  void _runInputField(bool asBaseline) => _runTest(
    () => setState(() { _inputTesting = true; _inputResult = '--'; }),
    () => setState(() => _inputTesting = false),
    (avg) => setState(() {
      if (asBaseline) _inputBaseline = avg;
      _inputResult = _formatResult(avg, _inputBaseline);
    }),
    () => setState(() => _inputResult = 'Error'),
  );

  void _runSegmentedControl(bool asBaseline) => _runTest(
    () => setState(() { _segTesting = true; _segResult = '--'; }),
    () => setState(() => _segTesting = false),
    (avg) => setState(() {
      if (asBaseline) _segBaseline = avg;
      _segResult = _formatResult(avg, _segBaseline);
    }),
    () => setState(() => _segResult = 'Error'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lumen,
      appBar: AppBar(
        backgroundColor: AppColors.lumen,
        title: const Text('Performance Lab'),
        elevation: 0,
        foregroundColor: AppColors.obsidian,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Measure average raster time for components. Set a Baseline first, then toggle features and Run Test to see the performance delta.',
            style: TextStyle(color: AppColors.slate),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: 'AppButton',
            component: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                AppButton(
                  label: 'Primary Variant',
                  variant: AppButtonVariant.primary,
                  shadows: _appButtonShadows,
                  showNoise: _appButtonNoise,
                ),
                AppButton(
                  label: 'Secondary Variant',
                  variant: AppButtonVariant.secondary,
                  shadows: _appButtonShadows,
                  showNoise: _appButtonNoise,
                ),
                AppButton(
                  label: 'Inline Variant',
                  variant: AppButtonVariant.inline,
                  shadows: _appButtonShadows,
                  showNoise: _appButtonNoise,
                ),
              ],
            ),
            controls: [
              SwitchListTile(
                title: const Text('Drop & Inner Shadows'),
                value: _appButtonShadows,
                onChanged: (v) => setState(() => _appButtonShadows = v),
              ),
              SwitchListTile(
                title: const Text('Noise Layer (Grain)'),
                value: _appButtonNoise,
                onChanged: (v) => setState(() => _appButtonNoise = v),
              ),
            ],
            resultText: _appButtonResult,
            resultColor: _appButtonResult.contains('+') ? AppColors.negative : (_appButtonResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _appButtonTesting,
            baseline: _appButtonBaseline,
            onSetBaseline: () => _runAppButton(true),
            onRunTest: () => _runAppButton(false),
          ),

          _buildSection(
            title: 'OTPInput',
            component: OTPInput(
              controller: _otpController,
              gradientDigits: _otpGradient,
              animateCells: _otpAnimate,
            ),
            controls: [
              SwitchListTile(
                title: const Text('Gradient Text Foreground'),
                value: _otpGradient,
                onChanged: (v) => setState(() => _otpGradient = v),
              ),
              SwitchListTile(
                title: const Text('Cell Animations (Scale/Fade)'),
                value: _otpAnimate,
                onChanged: (v) => setState(() => _otpAnimate = v),
              ),
            ],
            resultText: _otpResult,
            resultColor: _otpResult.contains('+') ? AppColors.negative : (_otpResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _otpTesting,
            baseline: _otpBaseline,
            onSetBaseline: () => _runOTPInput(true),
            onRunTest: () => _runOTPInput(false),
          ),

          _buildSection(
            title: 'SavChip',
            component: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                SavChip(
                  label: 'Small',
                  size: SavChipSize.sm,
                  enableSurface: _chipSurface,
                ),
                SavChip(
                  label: 'Large Noise',
                  size: SavChipSize.lg,
                  showLgNoise: _chipNoise,
                  enableSurface: _chipSurface,
                ),
              ],
            ),
            controls: [
              SwitchListTile(
                title: const Text('Use SavSurface (complex decoration)'),
                value: _chipSurface,
                onChanged: (v) => setState(() => _chipSurface = v),
              ),
              SwitchListTile(
                title: const Text('Lg Noise Layer'),
                value: _chipNoise,
                onChanged: (v) => setState(() => _chipNoise = v),
              ),
            ],
            resultText: _chipResult,
            resultColor: _chipResult.contains('+') ? AppColors.negative : (_chipResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _chipTesting,
            baseline: _chipBaseline,
            onSetBaseline: () => _runSavChip(true),
            onRunTest: () => _runSavChip(false),
          ),

          _buildSection(
            title: 'SelectableRow',
            component: SelectableRow(
              label: 'Interactive Row',
              secondary: 'Tap me during test',
              selected: _rowSelected,
              animateSelection: _rowAnimate,
              enableFlash: _rowFlash,
              onTap: () => setState(() => _rowSelected = !_rowSelected),
            ),
            controls: [
              SwitchListTile(
                title: const Text('Animate Selection'),
                value: _rowAnimate,
                onChanged: (v) => setState(() => _rowAnimate = v),
              ),
              SwitchListTile(
                title: const Text('Enable Press Flash'),
                value: _rowFlash,
                onChanged: (v) => setState(() => _rowFlash = v),
              ),
            ],
            resultText: _rowResult,
            resultColor: _rowResult.contains('+') ? AppColors.negative : (_rowResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _rowTesting,
            baseline: _rowBaseline,
            onSetBaseline: () => _runSelectableRow(true),
            onRunTest: () => _runSelectableRow(false),
          ),

          _buildSection(
            title: 'AmountInput',
            component: AmountInput(
              intent: AmountInputIntent.purple,
              controller: _amountController,
              enableGradient: _amountGradient,
              enableMotion: _amountMotion,
              enableTextAnimation: _amountTextAnimate,
              onChanged: (v) {},
            ),
            controls: [
              SwitchListTile(
                title: const Text('Gradient Text (ShaderMask)'),
                value: _amountGradient,
                onChanged: (v) => setState(() => _amountGradient = v),
              ),
              SwitchListTile(
                title: const Text('Motion (Shake/Scale on Error/Focus)'),
                value: _amountMotion,
                onChanged: (v) => setState(() => _amountMotion = v),
              ),
              SwitchListTile(
                title: const Text('Text Animation (Per-character fade/slide)'),
                value: _amountTextAnimate,
                onChanged: (v) => setState(() => _amountTextAnimate = v),
              ),
            ],
            resultText: _amountResult,
            resultColor: _amountResult.contains('+') ? AppColors.negative : (_amountResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _amountTesting,
            baseline: _amountBaseline,
            onSetBaseline: () => _runAmountInput(true),
            onRunTest: () => _runAmountInput(false),
          ),

          _buildSection(
            title: 'SavBadge',
            component: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                SavBadge(
                  type: BadgeType.count,
                  size: BadgeSize.lg,
                  value: '42',
                  enableSurface: _badgeSurface,
                  enableAnimation: _badgeAnimate,
                ),
                SavBadge(
                  type: BadgeType.count,
                  size: BadgeSize.sm,
                  value: '99+',
                  enableSurface: _badgeSurface,
                  enableAnimation: _badgeAnimate,
                ),
              ],
            ),
            controls: [
              SwitchListTile(
                title: const Text('Use SavSurface'),
                value: _badgeSurface,
                onChanged: (v) => setState(() => _badgeSurface = v),
              ),
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: _badgeAnimate,
                onChanged: (v) => setState(() => _badgeAnimate = v),
              ),
            ],
            resultText: _badgeResult,
            resultColor: _badgeResult.contains('+') ? AppColors.negative : (_badgeResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _badgeTesting,
            baseline: _badgeBaseline,
            onSetBaseline: () => _runSavBadge(true),
            onRunTest: () => _runSavBadge(false),
          ),

          _buildSection(
            title: 'InputField',
            component: InputField(
              label: 'Email',
              placeholder: 'jane@example.com',
              variant: InputFieldVariant.boxed,
              showLeftSquircle: true,
              leftSquircleIcon: const Icon(Icons.person),
              enableSurface: _inputSurface,
              enableShadows: _inputShadows,
              enableLeftSquircleNoise: _inputLeftNoise,
            ),
            controls: [
              SwitchListTile(
                title: const Text('Use SavSurface'),
                value: _inputSurface,
                onChanged: (v) => setState(() => _inputSurface = v),
              ),
              SwitchListTile(
                title: const Text('Enable Shadows (Inner & Drop)'),
                value: _inputShadows,
                onChanged: (v) => setState(() => _inputShadows = v),
              ),
              SwitchListTile(
                title: const Text('Left Squircle Noise Layer'),
                value: _inputLeftNoise,
                onChanged: (v) => setState(() => _inputLeftNoise = v),
              ),
            ],
            resultText: _inputResult,
            resultColor: _inputResult.contains('+') ? AppColors.negative : (_inputResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _inputTesting,
            baseline: _inputBaseline,
            onSetBaseline: () => _runInputField(true),
            onRunTest: () => _runInputField(false),
          ),

          _buildSection(
            title: 'SegmentedControl',
            component: SegmentedControl(
              items: const [
                SegmentedItem(label: 'Daily'),
                SegmentedItem(label: 'Weekly'),
                SegmentedItem(label: 'Monthly'),
              ],
              selected: _segSelected,
              onChanged: (v) => setState(() => _segSelected = v),
              enableSurface: _segSurface,
              enableSelectionAnimation: _segAnimate,
            ),
            controls: [
              SwitchListTile(
                title: const Text('Use SavSurface for Track'),
                value: _segSurface,
                onChanged: (v) => setState(() => _segSurface = v),
              ),
              SwitchListTile(
                title: const Text('Animate Selection'),
                value: _segAnimate,
                onChanged: (v) => setState(() => _segAnimate = v),
              ),
            ],
            resultText: _segResult,
            resultColor: _segResult.contains('+') ? AppColors.negative : (_segResult.contains('-') ? AppColors.positive : AppColors.obsidian),
            isTesting: _segTesting,
            baseline: _segBaseline,
            onSetBaseline: () => _runSegmentedControl(true),
            onRunTest: () => _runSegmentedControl(false),
          ),
        ],
      ),
    );
  }
}
