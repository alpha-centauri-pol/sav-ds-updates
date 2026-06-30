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
  PerfMetrics? _appButtonResult;
  bool _appButtonTesting = false;
  PerfMetrics? _appButtonBaseline;

  // OTPInput
  bool _otpGradient = true;
  bool _otpAnimate = true;
  PerfMetrics? _otpResult;
  bool _otpTesting = false;
  PerfMetrics? _otpBaseline;
  final TextEditingController _otpController = TextEditingController(text: '123456');

  // SavChip
  bool _chipSurface = true;
  bool _chipNoise = true;
  PerfMetrics? _chipResult;
  bool _chipTesting = false;
  PerfMetrics? _chipBaseline;

  // SelectableRow
  bool _rowAnimate = true;
  bool _rowFlash = true;
  PerfMetrics? _rowResult;
  bool _rowTesting = false;
  PerfMetrics? _rowBaseline;
  bool _rowSelected = true;

  // AmountInput
  bool _amountGradient = true;
  bool _amountMotion = true;
  bool _amountTextAnimate = true;
  PerfMetrics? _amountResult;
  bool _amountTesting = false;
  PerfMetrics? _amountBaseline;
  final TextEditingController _amountController = TextEditingController(text: '1,234.56');

  // SavBadge
  bool _badgeSurface = true;
  bool _badgeAnimate = true;
  PerfMetrics? _badgeResult;
  bool _badgeTesting = false;
  PerfMetrics? _badgeBaseline;

  // InputField
  bool _inputSurface = true;
  bool _inputShadows = true;
  bool _inputLeftNoise = true;
  PerfMetrics? _inputResult;
  bool _inputTesting = false;
  PerfMetrics? _inputBaseline;

  // SegmentedControl
  bool _segSurface = true;
  bool _segAnimate = true;
  PerfMetrics? _segResult;
  bool _segTesting = false;
  PerfMetrics? _segBaseline;
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
    void Function(PerfMetrics avg) onComplete,
    void Function() onError,
  ) async {
    onStart();
    _dummyTicker.repeat();
    
    try {
      int totalBuildUs = 0;
      int totalRasterUs = 0;
      const int iterations = 5;
      
      for (int i = 0; i < iterations; i++) {
        final metrics = await PerfProbe.measure(frames: 60);
        totalBuildUs += metrics.buildTime.inMicroseconds;
        totalRasterUs += metrics.rasterTime.inMicroseconds;
      }
      
      final avgBuildUs = totalBuildUs ~/ iterations;
      final avgRasterUs = totalRasterUs ~/ iterations;
      
      onComplete(PerfMetrics(
        Duration(microseconds: avgBuildUs),
        Duration(microseconds: avgRasterUs),
      ));
    } catch (e) {
      onError();
    } finally {
      _dummyTicker.stop();
      onEnd();
    }
  }

  Widget _buildMetricText(String label, double ms, double? baselineMs) {
    final isOverBudget = ms > 16.7;
    final color = isOverBudget ? AppColors.negative : AppColors.positive;
    final weight = isOverBudget ? FontWeight.w900 : FontWeight.bold;
    
    String text = '$label: ${ms.toStringAsFixed(2)} ms';
    
    if (baselineMs != null) {
      final delta = ms - baselineMs;
      final sign = delta > 0 ? '+' : '';
      text += ' ($sign${delta.toStringAsFixed(2)} ms)';
    }

    return Text(
      text,
      style: AppTextStyles.bodyBold.copyWith(color: color, fontWeight: weight),
    );
  }

  Widget _buildResultDisplay(PerfMetrics? current, PerfMetrics? baseline, bool isTesting) {
    if (isTesting) {
      return const Text('Testing...', style: TextStyle(color: AppColors.slate));
    }
    if (current == null) {
      return const Text('--', style: TextStyle(color: AppColors.slate));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMetricText('Build (CPU)', current.buildMs, baseline?.buildMs),
        const SizedBox(height: 4),
        _buildMetricText('Raster (GPU)', current.rasterMs, baseline?.rasterMs),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget component,
    required int instanceCount,
    required List<Widget> controls,
    required PerfMetrics? result,
    required bool isTesting,
    required PerfMetrics? baseline,
    required VoidCallback onRunTest,
    required VoidCallback onSetBaseline,
  }) {
    // Generate scale list
    final components = List.generate(instanceCount, (i) => component);

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
              Text('$title (x$instanceCount)', style: AppTextStyles.calloutBold),
              if (baseline != null)
                Text(
                  'Baseline: ${baseline.buildMs.toStringAsFixed(1)}ms Build | ${baseline.rasterMs.toStringAsFixed(1)}ms Raster',
                  style: AppTextStyles.captionRegular.copyWith(color: AppColors.slate),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Component Preview (Scaled)
          Container(
            height: 200, // Fixed height with scroll for large instance counts
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lumen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _dummyTicker,
                builder: (context, child) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: components,
                  );
                }
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Controls
          ...controls,
          const SizedBox(height: 16),
          // Actions & Result
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppButton(
                key: Key('set_baseline_$title'),
                label: 'Set Baseline',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                width: AppButtonWidth.hug,
                state: isTesting ? AppButtonState.disabled : AppButtonState.normal,
                onPressed: onSetBaseline,
              ),
              const SizedBox(width: 8),
              AppButton(
                key: Key('run_test_$title'),
                label: 'Run Test',
                size: AppButtonSize.small,
                width: AppButtonWidth.hug,
                state: isTesting ? AppButtonState.loading : AppButtonState.normal,
                onPressed: isTesting ? null : onRunTest,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildResultDisplay(result, baseline, isTesting),
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
    () => setState(() { _appButtonTesting = true; _appButtonResult = null; }),
    () => setState(() => _appButtonTesting = false),
    (avg) => setState(() {
      if (asBaseline) _appButtonBaseline = avg;
      _appButtonResult = avg;
    }),
    () {},
  );

  void _runOTPInput(bool asBaseline) => _runTest(
    () => setState(() { _otpTesting = true; _otpResult = null; }),
    () => setState(() => _otpTesting = false),
    (avg) => setState(() {
      if (asBaseline) _otpBaseline = avg;
      _otpResult = avg;
    }),
    () {},
  );

  void _runSavChip(bool asBaseline) => _runTest(
    () => setState(() { _chipTesting = true; _chipResult = null; }),
    () => setState(() => _chipTesting = false),
    (avg) => setState(() {
      if (asBaseline) _chipBaseline = avg;
      _chipResult = avg;
    }),
    () {},
  );

  void _runSelectableRow(bool asBaseline) => _runTest(
    () => setState(() { _rowTesting = true; _rowResult = null; }),
    () => setState(() => _rowTesting = false),
    (avg) => setState(() {
      if (asBaseline) _rowBaseline = avg;
      _rowResult = avg;
    }),
    () {},
  );

  void _runAmountInput(bool asBaseline) => _runTest(
    () => setState(() { _amountTesting = true; _amountResult = null; }),
    () => setState(() => _amountTesting = false),
    (avg) => setState(() {
      if (asBaseline) _amountBaseline = avg;
      _amountResult = avg;
    }),
    () {},
  );

  void _runSavBadge(bool asBaseline) => _runTest(
    () => setState(() { _badgeTesting = true; _badgeResult = null; }),
    () => setState(() => _badgeTesting = false),
    (avg) => setState(() {
      if (asBaseline) _badgeBaseline = avg;
      _badgeResult = avg;
    }),
    () {},
  );

  void _runInputField(bool asBaseline) => _runTest(
    () => setState(() { _inputTesting = true; _inputResult = null; }),
    () => setState(() => _inputTesting = false),
    (avg) => setState(() {
      if (asBaseline) _inputBaseline = avg;
      _inputResult = avg;
    }),
    () {},
  );

  void _runSegmentedControl(bool asBaseline) => _runTest(
    () => setState(() { _segTesting = true; _segResult = null; }),
    () => setState(() => _segTesting = false),
    (avg) => setState(() {
      if (asBaseline) _segBaseline = avg;
      _segResult = avg;
    }),
    () {},
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Rule: Every frame has a time budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 8),
                Text('To feel smooth, the phone has to draw each frame within ~16.7 ms on a 60 Hz screen. If a frame takes longer, it is dropped and causes jank.'),
                SizedBox(height: 12),
                Text('Phase 1: Build (CPU)', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Building widgets + layout in Dart. Affected by widget tree size and rebuilds.'),
                SizedBox(height: 8),
                Text('Phase 2: Raster (GPU)', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Drawing to the screen. Affected by blur shadows, grain/noise, ShaderMask, gradients.'),
                SizedBox(height: 12),
                Text('⚠️ IMPORTANT ⚠️', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                Text('1. Debug mode numbers are lies (5-10x slower).'),
                Text('2. Simulators have fake GPUs (Raster is meaningless).'),
                Text('3. You MUST run in Profile mode on a physical device for accurate Ground Truth:'),
                SizedBox(height: 4),
                Text('   cd example && flutter run --profile', style: TextStyle(fontFamily: 'monospace', backgroundColor: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: 'AppButton',
            instanceCount: 25,
            component: AppButton(
              label: 'Primary',
              variant: AppButtonVariant.primary,
              width: AppButtonWidth.hug,
              shadows: _appButtonShadows,
              showNoise: _appButtonNoise,
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
            result: _appButtonResult,
            isTesting: _appButtonTesting,
            baseline: _appButtonBaseline,
            onSetBaseline: () => _runAppButton(true),
            onRunTest: () => _runAppButton(false),
          ),

          _buildSection(
            title: 'OTPInput',
            instanceCount: 15,
            component: SizedBox(
              width: 300,
              child: OTPInput(
                controller: _otpController,
                gradientDigits: _otpGradient,
                animateCells: _otpAnimate,
              ),
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
            result: _otpResult,
            isTesting: _otpTesting,
            baseline: _otpBaseline,
            onSetBaseline: () => _runOTPInput(true),
            onRunTest: () => _runOTPInput(false),
          ),

          _buildSection(
            title: 'SavChip',
            instanceCount: 50,
            component: SavChip(
              label: 'Noise',
              size: SavChipSize.lg,
              showLgNoise: _chipNoise,
              enableSurface: _chipSurface,
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
            result: _chipResult,
            isTesting: _chipTesting,
            baseline: _chipBaseline,
            onSetBaseline: () => _runSavChip(true),
            onRunTest: () => _runSavChip(false),
          ),

          _buildSection(
            title: 'SelectableRow',
            instanceCount: 20,
            component: SizedBox(
              width: 300,
              child: SelectableRow(
                label: 'Row',
                secondary: 'Secondary',
                selected: _rowSelected,
                animateSelection: _rowAnimate,
                enableFlash: _rowFlash,
                onTap: () {},
              ),
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
            result: _rowResult,
            isTesting: _rowTesting,
            baseline: _rowBaseline,
            onSetBaseline: () => _runSelectableRow(true),
            onRunTest: () => _runSelectableRow(false),
          ),

          _buildSection(
            title: 'AmountInput',
            instanceCount: 15,
            component: SizedBox(
              width: 300,
              child: AmountInput(
                intent: AmountInputIntent.purple,
                controller: _amountController,
                enableGradient: _amountGradient,
                enableMotion: _amountMotion,
                enableTextAnimation: _amountTextAnimate,
                onChanged: (v) {},
              ),
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
            result: _amountResult,
            isTesting: _amountTesting,
            baseline: _amountBaseline,
            onSetBaseline: () => _runAmountInput(true),
            onRunTest: () => _runAmountInput(false),
          ),

          _buildSection(
            title: 'SavBadge',
            instanceCount: 50,
            component: SavBadge(
              type: BadgeType.count,
              size: BadgeSize.lg,
              value: '42',
              enableSurface: _badgeSurface,
              enableAnimation: _badgeAnimate,
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
            result: _badgeResult,
            isTesting: _badgeTesting,
            baseline: _badgeBaseline,
            onSetBaseline: () => _runSavBadge(true),
            onRunTest: () => _runSavBadge(false),
          ),

          _buildSection(
            title: 'InputField',
            instanceCount: 15,
            component: SizedBox(
              width: 300,
              child: InputField(
                label: 'Email',
                placeholder: 'jane@example.com',
                variant: InputFieldVariant.boxed,
                showLeftSquircle: true,
                leftSquircleIcon: const Icon(Icons.person),
                enableSurface: _inputSurface,
                enableShadows: _inputShadows,
                enableLeftSquircleNoise: _inputLeftNoise,
              ),
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
            result: _inputResult,
            isTesting: _inputTesting,
            baseline: _inputBaseline,
            onSetBaseline: () => _runInputField(true),
            onRunTest: () => _runInputField(false),
          ),

          _buildSection(
            title: 'SegmentedControl',
            instanceCount: 10,
            component: SizedBox(
              width: 300,
              child: SegmentedControl(
                items: const [
                  SegmentedItem(label: 'Daily'),
                  SegmentedItem(label: 'Weekly'),
                  SegmentedItem(label: 'Monthly'),
                ],
                selected: _segSelected,
                onChanged: (v) {},
                enableSurface: _segSurface,
                enableSelectionAnimation: _segAnimate,
              ),
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
            result: _segResult,
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
