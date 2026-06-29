// Render-performance stress analysis for sav_ds.
//
// SEPARATE diagnostic suite (not a gate). For every component it measures the
// per-instance render structure + build cost in the headless test binding, then
// writes a self-contained, offline `stress_report.html` (no CDN) ranking each
// component by "render weight" with the cost drivers and lightweight fixes.
//
// Run:  flutter test test/perf_stress_test.dart   ->  writes ./stress_report.html
//
// NOTE: these are widget-build + tree-structure metrics. True raster/frame cost
// (where MaskFilter.blur / shaders actually hurt) needs an on-device
// `integration_test --profile`; this is the relative, reproducible proxy.
//
// ignore_for_file: avoid_print, lines_longer_than_80_chars, cascade_invocations
// ignore_for_file: unnecessary_raw_strings, leading_newlines_in_multiline_strings
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_ds/sav_ds.dart';

/// Static description of a component to profile.
class _Spec {
  const _Spec({
    required this.name,
    required this.rootType,
    required this.build,
    required this.blurShadows, // MaskFilter.blur passes (not widget-findable)
    required this.tickers, // AnimationControllers (not widget-findable)
    required this.selfRepaintBoundary, // wraps ITSELF in a RepaintBoundary (source-level)
    required this.heavy, // plain "what makes it heavy"
    required this.fix, // plain "what helps" (one line)
    required this.detail, // HTML: the elaborated, specific explanation
  });
  final String name;
  final Type rootType;
  final Widget Function() build;
  final int blurShadows;
  final int tickers;
  final bool selfRepaintBoundary;
  final String heavy;
  final String fix;
  final String detail;
}

/// Collected measurements for a component.
class _Metric {
  _Metric(this.spec);
  final _Spec spec;
  int netElements = 0;
  int netRenderObjects = 0;
  int repaintBoundaries = 0;
  int customPaints = 0;
  int shaderMasks = 0;
  int noiseLayers = 0;
  double buildUs = 0;
  int volumeMs = 0;
  int score = 0;
  // Whether the component isolates ITSELF (source-level RepaintBoundary), not a
  // TextField's internal one. Drives the badge + score.
  bool get hasRepaintBoundary => spec.selfRepaintBoundary;
}

Widget _app(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 360, child: child))));

void main() {
  final specs = <_Spec>[
    _Spec(
      name: 'AppButton',
      rootType: AppButton,
      build: () => AppButton(label: 'Continue', onPressed: () {}),
      blurShadows: 2,
      tickers: 1,
      selfRepaintBoundary: true,
      heavy: 'The heaviest effects of any component: a grain-texture overlay plus two soft, blurred shadows — all redrawn for every button.',
      fix: 'For long lists, offer a "flat" button (no grain, a simple hard shadow). It already avoids redrawing its neighbours.',
      detail: '<p>Two things make it heavy: a <b>grain texture</b> drawn over the whole button, and <b>two soft shadows</b> (one outer, one inner) that the phone re-blurs every frame.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Add a <b>flat style</b> that turns off the grain and uses one plain (hard) shadow. Use it in lists and dense screens; keep the fancy look for hero buttons.</li>'
          '<li>It already has a <b>fence</b> around it, so tapping one button does not redraw the others — keep that.</li>'
          '<li>In long lists, build buttons lazily (see the note lower down).</li></ul>',
    ),
    _Spec(
      name: 'InputField',
      rootType: InputField,
      build: () => const InputField(label: 'Email', placeholder: 'you@x.com'),
      blurShadows: 2,
      tickers: 0,
      selfRepaintBoundary: false,
      heavy: 'Two soft blurred shadows and a grain texture on its box, plus a live text field.',
      fix: 'Add a plain (no-grain) variant for dense forms, and isolate it so typing does not redraw nearby widgets.',
      detail: '<p>Its box has the same expensive look as the button: <b>two soft blurred shadows</b> plus a <b>grain texture</b>. It also runs a real text field that updates as you type.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Add a <b>plain variant</b> (no grain, a hard shadow) for forms with many fields.</li>'
          '<li>Put a <b>fence (RepaintBoundary)</b> around it so typing in one field does not redraw the fields next to it.</li>'
          '<li>The clear (x) and dropdown-arrow animations are fine — they only run while the field is focused.</li></ul>',
    ),
    _Spec(
      name: 'OTPInput',
      rootType: OTPInput,
      build: () => const OTPInput(),
      blurShadows: 0,
      tickers: 3,
      selfRepaintBoundary: true,
      heavy: 'Built from many small animated boxes with three always-running animations — it has the most pieces of any component.',
      fix: 'Only build these when visible (lazy lists), and reduce the number of always-on animations.',
      detail: '<p>This has the most moving parts. It has <b>two animation timers</b>: a <b>shake</b> (plays only when the code is wrong) and a <b>pulse</b> (plays once when you finish typing). On their own these are cheap, because they sit idle until something triggers them.</p>'
          '<p>The real weight is the <b>boxes</b>: a 6-digit field is <b>6 little boxes</b>, and <i>each box</i> runs three small built-in animations — a <b>zoom</b> for the active box, a <b>border colour/size</b> change, and a <b>fade</b> for the digit. Six boxes times three animations is a lot of pieces, all created the moment the field appears.</p>'
          '<p><b>So, plainly:</b> "always-on" means those per-box animations exist for every box whether or not anything is moving. "Build when visible" means: if several of these can appear in a scrolling list, use a <b>lazy list</b> so only the ones on screen are created — otherwise every hidden field still builds all of its boxes and timers.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Use a <b>lazy list</b> wherever multiple OTP fields can appear.</li>'
          '<li>If you need it somewhere very dense, simplify the per-box animation (e.g. one fade instead of zoom + border + fade).</li></ul>',
    ),
    _Spec(
      name: 'OTPInput (filled)',
      rootType: OTPInput,
      build: () => OTPInput(controller: TextEditingController(text: '123456')),
      blurShadows: 0,
      tickers: 3,
      selfRepaintBoundary: true,
      heavy: 'Built from many small animated boxes with three always-running animations — it has the most pieces of any component.',
      fix: 'Only build these when visible (lazy lists), and reduce the number of always-on animations.',
      detail: '<p>Filled version to profile ShaderMask rendering overhead.</p>',
    ),
    _Spec(
      name: 'AmountInput',
      rootType: AmountInput,
      build: () => const AmountInput(),
      blurShadows: 0,
      tickers: 2,
      selfRepaintBoundary: false,
      heavy: 'Animates every digit separately and keeps two animations running the whole time.',
      fix: 'Isolate it so it does not redraw neighbours, and only add the gradient effect when a coloured intent is set.',
      detail: '<p>It has <b>two animation timers</b> — a <b>shake</b> (on error) and a tiny <b>scale bump</b> (when the value changes) — both idle until triggered. The ongoing cost is that <b>every digit animates in and out separately</b>: typing 1,234,567 spins up a little animation per character.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Put a <b>fence (RepaintBoundary)</b> around it so its digit animations do not redraw nearby widgets.</li>'
          '<li>The colourful <b>gradient</b> effect is only needed for the gold/purple styles — skip building it for the plain (neutral) case.</li>'
          '<li>Usually one per screen, so this is lower priority than the buttons and inputs.</li></ul>',
    ),
    _Spec(
      name: 'SegmentedControl',
      rootType: SegmentedControl,
      build: () => SegmentedControl(
        items: const [SegmentedItem(label: 'A'), SegmentedItem(label: 'B')],
        selected: 0,
        onChanged: (_) {},
      ),
      blurShadows: 1,
      tickers: 0,
      selfRepaintBoundary: false,
      heavy: 'One soft blurred shadow on its track; otherwise light.',
      fix: 'Swap the soft shadow for a cheap hard one, and isolate it from neighbours.',
      detail: '<p>Mostly light. The one cost is <b>a single soft shadow</b> under the track. The sliding selected-pill is a cheap built-in animation.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Swap the soft shadow for a <b>plain hard shadow</b>.</li>'
          '<li>Add a <b>fence</b> so the sliding pill does not redraw what is around it.</li></ul>',
    ),
    _Spec(
      name: 'SelectableRow',
      rootType: SelectableRow,
      build: () => const SelectableRow(label: 'United Arab Emirates', secondary: 'AED'),
      blurShadows: 0,
      tickers: 1,
      selfRepaintBoundary: true,
      heavy: 'A small tap-flash animation and a hand-drawn checkmark.',
      fix: 'Already light — it only animates when you tap a row.',
      detail: '<p>Light. It has <b>one animation timer</b> for the tap-flash (plays only when you tap a row) and a small <b>hand-drawn checkmark</b> that animates when selected.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Nothing urgent. It already has a fence and only animates on interaction — safe in long lists (with a lazy list, as always).</li></ul>',
    ),
    _Spec(
      name: 'SavChip',
      rootType: SavChip,
      build: () => const SavChip(label: 'Instant'),
      blurShadows: 0,
      tickers: 1,
      selfRepaintBoundary: false,
      heavy: 'Very light, but keeps one animation idling even when nothing is moving.',
      fix: 'Drop the idle animation when the entry animation is not used.',
      detail: '<p>Very light. The only note: it creates <b>one animation timer for its entry effect even when that effect is switched off</b>, so the timer sits there doing nothing.</p>'
          '<p><b>What to do:</b></p><ul>'
          '<li>Only create that timer when the entry animation is actually turned on.</li>'
          '<li>Add a <b>fence</b> if you place chips over moving content.</li></ul>',
    ),
    _Spec(
      name: 'SavBadge',
      rootType: SavBadge,
      build: () => const SavBadge(value: '3'),
      blurShadows: 0,
      tickers: 0,
      selfRepaintBoundary: false,
      heavy: 'The lightest of all — just a filled shape, no shadows and no animations.',
      fix: 'Fine as-is.',
      detail: '<p>The lightest component — a filled shape with a number, plus a small fade when the number changes. Nothing expensive.</p>'
          '<p><b>What to do:</b></p><ul><li>Nothing. Use freely.</li></ul>',
    ),
  ];

  // Baseline tree (empty) so component metrics are NET of the harness scaffold.
  late int baseElements;
  late int baseRenderObjects;
  final metrics = <_Metric>[];

  testWidgets('baseline', (t) async {
    await t.pumpWidget(_app(const SizedBox.shrink()));
    baseElements = t.allElements.length;
    baseRenderObjects = t.allRenderObjects.length;
  });

  for (final spec in specs) {
    testWidgets('profile ${spec.name}', (t) async {
      final m = _Metric(spec);

      // --- structure (one instance) ---
      await t.pumpWidget(_app(spec.build()));
      m.netElements = t.allElements.length - baseElements;
      m.netRenderObjects = t.allRenderObjects.length - baseRenderObjects;
      final root = find.byType(spec.rootType);
      int countIn(Type type) =>
          find.descendant(of: root, matching: find.byType(type)).evaluate().length;
      m.repaintBoundaries = countIn(RepaintBoundary);
      m.customPaints = countIn(CustomPaint);
      m.shaderMasks = countIn(ShaderMask);
      m.noiseLayers = find.byType(NoiseLayer).evaluate().length;

      // --- build cost: mean of K fresh pumps (alternate to force rebuild) ---
      const k = 30;
      final sw = Stopwatch();
      for (var i = 0; i < k; i++) {
        await t.pumpWidget(_app(const SizedBox.shrink()));
        sw.start();
        await t.pumpWidget(_app(spec.build()));
        sw.stop();
      }
      m.buildUs = sw.elapsedMicroseconds / k;

      // --- volume: 200 instances eager ---
      final vsw = Stopwatch()..start();
      await t.pumpWidget(
        _app(SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(200, (_) => spec.build()),
          ),
        )),
      );
      vsw.stop();
      t.takeException(); // drain any overflow from dense layout
      m.volumeMs = vsw.elapsedMilliseconds;

      // --- weight score (transparent heuristic; GPU-cost weighted) ---
      m.score = (m.netRenderObjects +
              8 * spec.blurShadows +
              6 * m.noiseLayers +
              5 * m.shaderMasks +
              3 * spec.tickers -
              (m.hasRepaintBoundary ? 2 : 0))
          .clamp(0, 100000);

      metrics.add(m);
    });
  }

  tearDownAll(() {
    metrics.sort((a, b) => b.score.compareTo(a.score));
    print('\n===== PERF RESULTS (by render weight) =====');
    for (final m in metrics) {
      print('PERF|${m.spec.name}|score=${m.score}|renderObjects=${m.netRenderObjects}|blur=${m.spec.blurShadows}|noise=${m.noiseLayers}|shaderMask=${m.shaderMasks}|tickers=${m.spec.tickers}|RB=${m.hasRepaintBoundary}|build=${m.buildUs.toStringAsFixed(0)}us|volume200=${m.volumeMs}ms');
    }
    print('===== END PERF RESULTS =====\n');

    File('stress_report.html').writeAsStringSync(_renderHtml(metrics));
    print('Wrote stress_report.html');
  });
}

// ---------------------------------------------------------------------------
// HTML report (self-contained, offline, plain-language)
// ---------------------------------------------------------------------------

String _sevColor(int score) {
  if (score >= 100) return '#e5484d'; // very heavy
  if (score >= 60) return '#f5811f'; // heavy
  if (score >= 25) return '#f5a623'; // medium
  return '#30a46c'; // light
}

({String label, String emoji}) _weightLabel(int score) {
  if (score >= 100) return (label: 'Very heavy', emoji: '🔴');
  if (score >= 60) return (label: 'Heavy', emoji: '🟠');
  if (score >= 25) return (label: 'Medium', emoji: '🟡');
  return (label: 'Light', emoji: '🟢');
}

/// One slice of the "what's making it heavy" stacked bar.
class _Seg {
  const _Seg(this.name, this.pts, this.color);
  final String name;
  final int pts;
  final String color;
}

List<_Seg> _segments(_Metric m) => <_Seg>[
      _Seg('Building blocks', m.netRenderObjects, '#5b6472'),
      _Seg('Soft shadows', 8 * m.spec.blurShadows, '#e5484d'),
      _Seg('Grain texture', 6 * m.noiseLayers, '#f5a623'),
      _Seg('Gradient mask', 5 * m.shaderMasks, '#8b5cf6'),
      _Seg('Animations', 3 * m.spec.tickers, '#3b9eff'),
    ].where((s) => s.pts > 0).toList();

String _stack(_Metric m) {
  final segs = _segments(m);
  final total = segs.fold<int>(0, (a, b) => a + b.pts);
  final bars = segs.map((s) {
    final pct = total == 0 ? 0 : (s.pts / total * 100);
    return '<div class="seg" style="width:$pct%;background:${s.color}" title="${s.name}: ${s.pts} pts"></div>';
  }).join();
  final legend = segs
      .map((s) => '<span class="leg"><i style="background:${s.color}"></i>${s.name} <b>${s.pts}</b></span>')
      .join();
  return '<div class="stack">$bars</div><div class="legend">$legend</div>';
}

String _bar(String label, num value, num max, String color, String suffix) {
  final pct = max == 0 ? 0 : (value / max * 100).clamp(2, 100);
  return '''
  <div class="row">
    <div class="bar-label">$label</div>
    <div class="bar-track"><div class="bar-fill" style="width:$pct%;background:$color"></div></div>
    <div class="bar-val">$value$suffix</div>
  </div>''';
}

String _card(_Metric m) {
  final c = _sevColor(m.score);
  final w = _weightLabel(m.score);
  final rb = m.hasRepaintBoundary
      ? '<span class="badge green">✓ isolated from neighbours</span>'
      : '<span class="badge amber">not isolated from neighbours</span>';
  return '''
  <div class="card" style="border-left:6px solid $c">
    <div class="card-head">
      <h3>${m.spec.name}</h3>
      <span class="score" style="background:$c">${w.emoji} ${w.label}</span>
    </div>
    <p class="plain">${m.spec.heavy}</p>
    <div class="stack-wrap">
      <div class="stack-title">What is making it heavy</div>
      ${_stack(m)}
    </div>
    <div class="badges">$rb</div>
    <p class="fix"><b>👍 What helps:</b> ${m.spec.fix}</p>
    <details class="more"><summary>Show me exactly what to do →</summary>${m.spec.detail}</details>
  </div>''';
}

String _glossaryRow(String emoji, String name, String what, String cost, String costColor) =>
    '''
  <div class="gloss">
    <div class="gloss-name">$emoji <b>$name</b></div>
    <div class="gloss-what">$what</div>
    <div class="gloss-cost" style="color:$costColor">$cost</div>
  </div>''';

String _renderHtml(List<_Metric> metrics) {
  final maxScore = metrics.map((m) => m.score).fold<int>(1, (a, b) => b > a ? b : a);
  final maxBuild = metrics.map((m) => m.buildUs).fold<double>(1, (a, b) => b > a ? b : a);
  final heaviest = metrics.take(3).map((m) => m.spec.name).join(', ');
  final scoreBars = metrics.map((m) => _bar(m.spec.name, m.score, maxScore, _sevColor(m.score), '')).join();
  final buildBars = metrics.map((m) => _bar(m.spec.name, m.buildUs.round(), maxBuild, _sevColor(m.score), ' µs')).join();
  final cards = metrics.map(_card).join();
  final now = DateTime.now().toIso8601String().split('.').first;

  const css = r'''
  :root{--bg:#0f1115;--panel:#171a21;--ink:#e6e8ec;--mut:#9aa3af;--line:#262b34}
  *{box-sizing:border-box}
  body{margin:0;font:15px/1.6 -apple-system,Segoe UI,Roboto,sans-serif;background:var(--bg);color:var(--ink)}
  .wrap{max-width:1000px;margin:0 auto;padding:32px 20px 64px}
  h1{font-size:28px;margin:0 0 4px} h2{font-size:19px;margin:38px 0 6px}
  .sub{color:var(--mut);margin:0 0 18px}
  .note{background:#13233a;border:1px solid #1f3a5f;border-radius:12px;padding:16px 20px;margin:18px 0;color:#cfe0f5}
  .note b{color:#fff}
  .summary{display:flex;gap:16px;flex-wrap:wrap;margin:18px 0}
  .stat{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:14px 18px;flex:1;min-width:160px}
  .stat b{display:block;font-size:20px} .stat span{color:var(--mut);font-size:12px}
  .chart{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px 18px}
  .row{display:flex;align-items:center;gap:12px;margin:7px 0}
  .bar-label{width:140px;color:var(--mut);font-size:13px;text-align:right;flex:none}
  .bar-track{flex:1;background:#0c0e12;border-radius:6px;height:18px;overflow:hidden}
  .bar-fill{height:100%;border-radius:6px}
  .bar-val{width:74px;font-variant-numeric:tabular-nums;font-size:13px}
  .cards{display:grid;grid-template-columns:1fr 1fr;gap:16px}
  @media(max-width:720px){.cards{grid-template-columns:1fr}}
  .card{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:18px}
  .card-head{display:flex;justify-content:space-between;align-items:center}
  .card-head h3{margin:0;font-size:17px}
  .score{font-size:12px;font-weight:700;color:#0c0e12;padding:4px 11px;border-radius:20px}
  .plain{font-size:14px;color:#cdd3db;margin:10px 0 14px}
  .stack-wrap{margin:10px 0 12px}
  .stack-title{font-size:11px;text-transform:uppercase;letter-spacing:.06em;color:var(--mut);margin-bottom:6px}
  .stack{display:flex;height:22px;border-radius:7px;overflow:hidden;background:#0c0e12}
  .seg{height:100%}
  .legend{display:flex;flex-wrap:wrap;gap:10px;margin-top:8px}
  .leg{font-size:12px;color:#c9d1da;display:flex;align-items:center;gap:5px}
  .leg i{width:11px;height:11px;border-radius:3px;display:inline-block}
  .leg b{font-variant-numeric:tabular-nums}
  .badges{margin:6px 0 10px}
  .badge{font-size:11px;background:#222833;color:#c9d1da;border-radius:6px;padding:3px 9px}
  .badge.amber{background:#3a2f17;color:#ffce82} .badge.green{background:#16321f;color:#7ee2a8}
  .fix{font-size:14px;margin:6px 0 0;color:#a9e6c0}
  details.more{margin-top:12px;border-top:1px solid var(--line);padding-top:10px}
  details.more summary{cursor:pointer;color:#8ec5ff;font-size:13px;font-weight:600;list-style:none}
  details.more summary::-webkit-details-marker{display:none}
  details.more[open] summary{margin-bottom:6px}
  details.more p{font-size:13.5px;color:#cdd3db;margin:8px 0}
  details.more ul{margin:6px 0 0;padding-left:18px}
  details.more li{font-size:13.5px;color:#cdd3db;margin:6px 0}
  .lazybox{background:#13233a;border:1px solid #1f3a5f;border-radius:12px;padding:14px 20px;margin:16px 0;color:#cfe0f5;font-size:13.5px}
  .lazybox b{color:#fff}
  .gloss{display:grid;grid-template-columns:160px 1fr 110px;gap:14px;align-items:center;padding:12px 0;border-bottom:1px dotted var(--line)}
  .gloss-what{color:#cdd3db;font-size:13px} .gloss-cost{font-weight:700;font-size:13px;text-align:right}
  @media(max-width:720px){.gloss{grid-template-columns:1fr;gap:4px}.gloss-cost{text-align:left}}
  .recs{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:8px 22px}
  .recs li{margin:9px 0}
  code{background:#0c0e12;padding:1px 6px;border-radius:5px;color:#ffce82}
  footer{color:var(--mut);font-size:12px;margin-top:30px;border-top:1px solid var(--line);padding-top:14px}
  ''';

  return '''<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>sav_ds — How heavy is each component?</title><style>$css</style></head>
<body><div class="wrap">
<h1>How heavy is each component?</h1>
<p class="sub">A plain-English look at how much work the phone does to draw each piece of the design system. Generated $now.</p>

<div class="note">
<b>How to read this.</b> Think of each component like a dish on a menu. Some are simple to make; others
use expensive "ingredients" — soft blurred shadows, a grain texture, animations — that the phone has
to redraw constantly. <b>Heavier = more work every time it appears on screen.</b> One or two heavy ones
is totally fine. The thing to watch is putting <b>many</b> heavy ones in a long scrolling list — that is
where it can start to stutter. The bars below show <b>which ingredients</b> are adding the weight.
</div>

<div class="summary">
  <div class="stat"><b>${metrics.length}</b><span>components checked</span></div>
  <div class="stat"><b>$heaviest</b><span>heaviest three</span></div>
  <div class="stat"><b>Soft shadows + grain</b><span>the costliest ingredients</span></div>
</div>

<h2>Heaviness, ranked</h2>
<p class="sub">Longer bar = heavier. Green is light, red is heavy.</p>
<div class="chart">$scoreBars</div>

<h2>Each component, broken down</h2>
<p class="sub">The coloured bar in each card shows what is making it heavy — at a glance.</p>
<div class="cards">$cards</div>

<h2>What makes things heavy?</h2>
<div class="recs">
  ${_glossaryRow('🌫️', 'Soft shadows', 'Blurred drop/inner shadows. The phone has to blur pixels every frame — the single most expensive thing here.', 'Very high', '#ff9ea1')}
  ${_glossaryRow('🌾', 'Grain texture', 'A subtle noise overlay for depth. Needs a special blend each time it is drawn.', 'High', '#ffce82')}
  ${_glossaryRow('🎨', 'Gradient mask', 'A colour gradient applied through the shape of the widget.', 'High', '#ffce82')}
  ${_glossaryRow('🎞️', 'Animations', 'Moving parts that keep a timer running and redraw over time. Each one adds ongoing work.', 'Medium', '#ffd9a0')}
  ${_glossaryRow('🧱', 'Building blocks', 'How many little pieces a component is made of. Each is cheap, but lots of them add up.', 'Low each', '#a9e6c0')}
  ${_glossaryRow('🚧', 'Isolation', 'A "fence" so one component redrawing does not force its neighbours to redraw too. This is GOOD — it lowers cost.', 'Saves cost', '#7ee2a8')}
</div>

<h2>How long each takes to appear (build time)</h2>
<p class="sub">Time to build one instance. Real, measured — lower is better.</p>
<div class="chart">$buildBars</div>

<h2>Keeping your app lightweight</h2>
<div class="lazybox"><b>What is a "lazy list"?</b> A lazy list (<code>ListView.builder</code>) only builds the rows you can actually see, plus a few just off-screen, and reuses them as you scroll. The opposite — putting everything in a plain <code>Column</code> — builds every component up front, including all of its shadows, grain and animation timers, even the ones nobody can see. For anything that can get long, use the lazy kind.</div>
<div class="recs"><ul>
  <li><b>The soft blurred shadows are the #1 cost.</b> Where the soft look is not essential (lists, dense screens), use a simple hard shadow instead — much cheaper to draw.</li>
  <li><b>The grain texture is the #2 cost.</b> Add a "flat" mode that turns it off for screens with many components.</li>
  <li><b>Use lazy lists</b> (<code>ListView.builder</code>) for long lists, so only the components actually on screen get built.</li>
  <li><b>Isolate the inputs.</b> Wrapping AmountInput, InputField, SavChip, SegmentedControl and Badge in a "fence" stops them from making neighbours redraw.</li>
  <li><b>Turn off animations that are not moving</b> — a few components keep a timer running even when idle.</li>
</ul></div>

<footer>These are structural + build-time measurements from a headless test — great for comparing components to each other, but not exact on-device frame times. The real cost of shadows/grain shows up on the GPU; to see true frame times, run the app on a device and watch the performance overlay. Regenerate this report any time with <code>flutter test test/perf_stress_test.dart</code>.</footer>
</div></body></html>''';
}
