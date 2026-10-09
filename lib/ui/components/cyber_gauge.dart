import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/security_score.dart';

class CyberGauge extends StatefulWidget {
  final int score;
  final int maxScore;
  final HealthStatus status;
  final double size;
  final VoidCallback? onTap;

  const CyberGauge({
    super.key,
    required this.score,
    this.maxScore = 100,
    required this.status,
    this.size = 200,
    this.onTap,
  });

  @override
  State<CyberGauge> createState() => _CyberGaugeState();
}

class _CyberGaugeState extends State<CyberGauge> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: (widget.score / widget.maxScore).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void didUpdateWidget(CyberGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: (widget.score / widget.maxScore).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (widget.status) {
      HealthStatus.excellent => AppColors.severitySafe,
      HealthStatus.good => AppColors.cyberCyan,
      HealthStatus.warning => AppColors.severitySuspicious,
      HealthStatus.critical => AppColors.severityCritical,
    };

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CyberGaugePainter(
                    progress: _progressAnim.value,
                    statusColor: statusColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SECURITY SCORE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${(_progressAnim.value * widget.maxScore).round()}',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: widget.size * 0.22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/${widget.maxScore}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(100), width: 1),
                      ),
                      child: Text(
                        widget.status.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CyberGaugePainter extends CustomPainter {
  final double progress;
  final Color statusColor;

  _CyberGaugePainter({required this.progress, required this.statusColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    // 1. Background Track Arc
    final bgPaint = Paint()
      ..color = AppColors.cyberSurfaceLight.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 2. Active Progress Arc with Gradient
    if (progress > 0) {
      final activeSweep = sweepAngle * progress;
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + activeSweep,
        colors: [
          AppColors.cyberCyan,
          statusColor,
        ],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      // Glow effect under active arc
      final glowPaint = Paint()
        ..color = statusColor.withAlpha(70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        glowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        progressPaint,
      );

      // Endpoint Indicator Dot
      final endAngle = startAngle + activeSweep;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
    }

    // 3. Decorative Outer Ticks
    final tickPaint = Paint()
      ..color = AppColors.textMuted.withAlpha(80)
      ..strokeWidth = 1.2;

    for (int i = 0; i <= 24; i++) {
      final angle = startAngle + (sweepAngle * (i / 24));
      final innerX = center.dx + (radius + 9) * math.cos(angle);
      final innerY = center.dy + (radius + 9) * math.sin(angle);
      final outerX = center.dx + (radius + (i % 6 == 0 ? 14 : 11)) * math.cos(angle);
      final outerY = center.dy + (radius + (i % 6 == 0 ? 14 : 11)) * math.sin(angle);
      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_CyberGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.statusColor != statusColor;
  }
}
