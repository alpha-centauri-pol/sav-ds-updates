import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class PerfMetrics {
  const PerfMetrics(this.buildTime, this.rasterTime);
  final Duration buildTime;
  final Duration rasterTime;

  double get buildMs => buildTime.inMicroseconds / 1000.0;
  double get rasterMs => rasterTime.inMicroseconds / 1000.0;
}

class PerfProbe {
  /// Measures the average build and raster time for the next [frames] frames.
  /// Note: The application must be driving frames (e.g. animating) for this to complete.
  static Future<PerfMetrics> measure({int frames = 60}) async {
    final completer = Completer<PerfMetrics>();
    int count = 0;
    int totalBuild = 0;
    int totalRaster = 0;
    
    void listener(List<FrameTiming> timings) {
      for (final timing in timings) {
        totalBuild += timing.buildDuration.inMicroseconds;
        totalRaster += timing.rasterDuration.inMicroseconds;
        count++;
      }
      if (count >= frames) {
        WidgetsBinding.instance.removeTimingsCallback(listener);
        if (!completer.isCompleted) {
          completer.complete(PerfMetrics(
            Duration(microseconds: totalBuild ~/ count),
            Duration(microseconds: totalRaster ~/ count),
          ));
        }
      }
    }
    
    WidgetsBinding.instance.addTimingsCallback(listener);
    
    return completer.future;
  }
}
