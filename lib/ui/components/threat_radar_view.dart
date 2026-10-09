import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';

class ThreatRadarView extends StatefulWidget {
  final double size;
  final int activeThreatsCount;

  const ThreatRadarView({
    super.key,
    this.size = 140,
    this.activeThreatsCount = 1,
  });

  @override
  State<ThreatRadarView> createState() => _ThreatRadarViewState();
}

class _ThreatRadarViewState extends State<ThreatRadarView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(
            sweepAngle: _animController.value * 2 * math.pi,
            activeThreats: widget.activeThreatsCount,
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double sweepAngle;
  final int activeThreats;

  _RadarPainter({required this.sweepAngle, required this.activeThreats});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle rings
    final ringPaint = Paint()
      ..color = AppColors.cyberCyan.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.33, ringPaint);
    canvas.drawCircle(center, radius * 0.66, ringPaint);
    canvas.drawCircle(center, radius * 0.98, ringPaint);

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = AppColors.cyberCyan.withAlpha(30)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), crosshairPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), crosshairPaint);

    // Radar Sweep Cone
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          AppColors.cyberCyan.withAlpha(120),
          AppColors.cyberCyan.withAlpha(0),
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.98, sweepPaint);

    // Radar Blips
    if (activeThreats > 0) {
      final blipPaint = Paint()
        ..color = AppColors.severityCritical
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final blipCore = Paint()..color = Colors.white;

      final blip1 = Offset(center.dx + radius * 0.5 * math.cos(0.8), center.dy + radius * 0.5 * math.sin(0.8));
      canvas.drawCircle(blip1, 4, blipPaint);
      canvas.drawCircle(blip1, 2, blipCore);

      if (activeThreats > 1) {
        final blip2 = Offset(center.dx + radius * 0.75 * math.cos(3.5), center.dy + radius * 0.75 * math.sin(3.5));
        canvas.drawCircle(blip2, 4, blipPaint);
        canvas.drawCircle(blip2, 2, blipCore);
      }
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => true;
}
