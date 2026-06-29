import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class PerfProbe {
  /// Measures the average raster time for the next [frames] frames.
  /// Note: The application must be driving frames (e.g. animating) for this to complete.
  static Future<Duration> measureRasterTime({int frames = 60}) async {
    final completer = Completer<Duration>();
    int count = 0;
    int totalRaster = 0;
    
    void listener(List<FrameTiming> timings) {
      for (final timing in timings) {
        totalRaster += timing.rasterDuration.inMicroseconds;
        count++;
      }
      if (count >= frames) {
        WidgetsBinding.instance.removeTimingsCallback(listener);
        if (!completer.isCompleted) {
          completer.complete(Duration(microseconds: totalRaster ~/ count));
        }
      }
    }
    
    WidgetsBinding.instance.addTimingsCallback(listener);
    
    return completer.future;
  }
}
