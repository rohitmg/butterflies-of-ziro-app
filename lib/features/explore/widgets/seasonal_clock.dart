// lib/features/explore/widgets/seasonal_clock.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'dart:ui';

// --- HELPER CLASSES FOR DATA MORPHING ---

// Represents a continuous arc segment
class ArcSegment {
  final double startAngle; // Start angle in radians
  final double sweepAngle; // Angular size in radians
  ArcSegment(this.startAngle, this.sweepAngle);
}

// --- MAIN WIDGET: SeasonalClock ---

class SeasonalClock extends StatefulWidget {
  final String seasonString;
  final Color primaryColor;

  const SeasonalClock({
    super.key,
    required this.seasonString,
    required this.primaryColor,
  });

  @override
  State<SeasonalClock> createState() => _SeasonalClockState();

  // Helper method defined on the widget for static access
  List<String> _parseActiveMonths(String season) {
    if (season.toLowerCase().contains('year-round')) {
      return const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
    }

    final List<String> components = season
        .split(RegExp(r'[-,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (components.isEmpty) return const [];

    // Simplification: If the input has commas OR only one component, treat as a list of single months.
    if (season.contains(',') || components.length < 2) {
      return components;
    }

    // Case: Hyphenated Range (e.g., "Aug-Oct")
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final startMonth = components.first;
    final endMonth = components.last;

    int startIndex = monthNames.indexWhere((m) => m.startsWith(startMonth));
    int endIndex = monthNames.indexWhere((m) => m.startsWith(endMonth));

    if (startIndex == -1 || endIndex == -1) return const [];

    final List<String> result = [];
    int current = startIndex;
    while (true) {
      result.add(monthNames[current]);
      if (current == endIndex) break;
      current = (current + 1) % 12;
      if (result.length > 12) break; // Safety break for bad input
    }
    return result;
  }
}

class _SeasonalClockState extends State<SeasonalClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // States holding the current (new) and old (transition start) data
  List<String> _currentActiveMonths = [];
  List<String> _oldActiveMonths = [];
  Color _transitionColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _currentActiveMonths = widget._parseActiveMonths(widget.seasonString);
    _transitionColor = widget.primaryColor;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initial load: play forward (scale-in effect)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(SeasonalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seasonString != oldWidget.seasonString ||
        widget.primaryColor != oldWidget.primaryColor) {
      // 1. Capture the old state and color
      _oldActiveMonths = _currentActiveMonths;
      _transitionColor = oldWidget.primaryColor;

      // 2. Set the new target state
      _currentActiveMonths = widget._parseActiveMonths(widget.seasonString);

      // 3. Immediately start the transition animation forward
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: widget.primaryColor),
        shape: BoxShape.circle,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SeasonalClockPainter(
              currentActiveMonths: _currentActiveMonths,
              oldActiveMonths: _oldActiveMonths,
              primaryColor: widget.primaryColor,
              oldPrimaryColor: _transitionColor,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

// --- CUSTOM PAINTER: _SeasonalClockPainter (Morphing Logic) ---

class _SeasonalClockPainter extends CustomPainter {
  final List<String> currentActiveMonths;
  final List<String> oldActiveMonths;
  final Color primaryColor;
  final Color oldPrimaryColor;
  final double animationValue;

  _SeasonalClockPainter({
    required this.currentActiveMonths,
    required this.oldActiveMonths,
    required this.primaryColor,
    required this.oldPrimaryColor,
    required this.animationValue,
  });

  int _getMonthIndex(String month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final index = monthNames.indexWhere(
      (m) => m.toLowerCase().startsWith(month.toLowerCase()),
    );
    return index >= 0 ? index + 1 : -1;
  }

  // --- Core Painting Logic ---
  void _drawSlices(
    Canvas canvas,
    Offset center,
    double radius,
    List<String> months,
    Color color,
    double opacity,
    double scaleFactor, // Used for the initial spread
  ) {
    if (opacity <= 0) return;

    final indices = months.map(_getMonthIndex).where((i) => i != -1).toList();
    final Paint paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Use scaleFactor to grow/shrink the arc radius
    final currentRadius = radius * scaleFactor;
    if (currentRadius <= 1.0) return;

    for (int month = 0; month < 12; month++) {
      final startAngle = -pi / 2 + (month * pi / 6);
      const sweepAngle = pi / 6;
      final int monthIndex = month + 1;

      final isActive = indices.contains(monthIndex);

      if (isActive) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          startAngle.toDouble(),
          sweepAngle.toDouble(),
          true,
          paint,
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- Static Base Paints ---
    final yearRoundPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Draw the Base Circle (Static background)
    canvas.drawCircle(center, radius, yearRoundPaint);

    // 2. Draw the OLD data (Fades Out: Opacity 1.0 -> 0.0, Scale 1.0 -> 0.0)
    // We rely on the old color/data being passed down for the fade effect.
    if (animationValue < 1.0) {
      _drawSlices(
        canvas,
        center,
        radius,
        oldActiveMonths,
        oldPrimaryColor,
        1.0 - animationValue, // Opacity fades out
        1.0, // Scale remains full size
      );
    }

    // 3. Draw the NEW data (Fades In: Opacity 0.0 -> 1.0, Scales In: 0.0 -> 1.0)
    // The animated radius provides the morphing/spreading effect.
    _drawSlices(
      canvas,
      center,
      radius,
      currentActiveMonths,
      primaryColor,
      animationValue, // Opacity fades in
      animationValue, // Scale grows from 0.0
    );

    // --- 4. Draw Labels and Center Dot (Appears when animation is near complete) ---
    if (animationValue > 0.9) {
      const monthLabels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      const TextStyle labelStyle = TextStyle(
        fontSize: 10,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      );
      final double textRadius = radius + 8;

      for (int month = 0; month < 12; month++) {
        final angle = -pi / 2 + (month * pi / 6) + (pi / 12);
        final double textX = center.dx + textRadius * cos(angle);
        final double textY = center.dy + textRadius * sin(angle);
        final textSpan = TextSpan(text: monthLabels[month], style: labelStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final Offset textOffset = Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        );

        canvas.drawCircle(
          Offset(textX, textY),
          1.5,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.fill,
        );
        textPainter.paint(canvas, textOffset);
      }

      canvas.drawCircle(center, 3, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeasonalClockPainter oldDelegate) {
    // Repaint when the animation progresses OR when the underlying data changes
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.currentActiveMonths != currentActiveMonths ||
        oldDelegate.oldActiveMonths != oldActiveMonths ||
        oldDelegate.primaryColor != primaryColor;
  }
}
