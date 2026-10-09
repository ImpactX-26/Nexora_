import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';

class ScamGraphView extends StatefulWidget {
  final CoordinatedIncident incident;
  final Function(GraphNode)? onNodeSelected;
  final double height;
  final bool isInteractive;

  const ScamGraphView({
    super.key,
    required this.incident,
    this.onNodeSelected,
    this.height = 340,
    this.isInteractive = true,
  });

  @override
  State<ScamGraphView> createState() => _ScamGraphViewState();
}

class _ScamGraphViewState extends State<ScamGraphView> with SingleTickerProviderStateMixin {
  GraphNode? _selectedNode;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    if (!widget.isInteractive) return;

    for (final node in widget.incident.nodes) {
      final nodeX = node.xRatio * size.width;
      final nodeY = node.yRatio * size.height;
      final distance = (details.localPosition - Offset(nodeX, nodeY)).distance;
      if (distance <= 26) {
        setState(() {
          _selectedNode = node;
        });
        widget.onNodeSelected?.call(node);
        _showNodeDetailsModal(node);
        return;
      }
    }
  }

  void _showNodeDetailsModal(GraphNode node) {
    final nodeColor = switch (node.severity) {
      ThreatSeverityLevel.critical => AppColors.severityCritical,
      ThreatSeverityLevel.high => AppColors.severityHigh,
      ThreatSeverityLevel.suspicious => AppColors.severitySuspicious,
      ThreatSeverityLevel.safe => AppColors.severitySafe,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cyberSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: nodeColor.withAlpha(120), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: nodeColor.withAlpha(40),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderCyber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.type.displayName.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.cyberCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.label,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          node.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SeverityBadge.fromLevel(severity: node.severity),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cyberSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderCyber),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attack Chain Risk Contribution:', style: AppTypography.bodySmall),
                    Text(
                      '+${node.riskContribution} pts',
                      style: AppTypography.labelLarge.copyWith(
                        color: nodeColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (node.attributes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Forensic Node Telemetry:', style: AppTypography.titleSmall),
                const SizedBox(height: 8),
                ...node.attributes.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            e.key,
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: AppTypography.codeMono.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('Isolate Node & Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberCyanDark,
                    foregroundColor: AppColors.cyberCyan,
                    side: const BorderSide(color: AppColors.cyberCyan),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.incident.nodes.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('No graph topology available for this incident.'),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, widget.height);
              return GestureDetector(
                onTapDown: (details) => _handleTapDown(details, size),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _ScamGraphPainter(
                        nodes: widget.incident.nodes,
                        edges: widget.incident.edges,
                        selectedNodeId: _selectedNode?.id,
                        pulseValue: _pulseController.value,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 12,
            left: 14,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.severityCritical,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MULTI-VECTOR ATTACK GRAPH',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 14,
            child: Text(
              'Tap any node for forensic details',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.cyberCyan,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScamGraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? selectedNodeId;
  final double pulseValue;

  _ScamGraphPainter({
    required this.nodes,
    required this.edges,
    required this.selectedNodeId,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (var n in nodes) n.id: n};

    // 1. Draw Grid Background Lines
    final gridPaint = Paint()
      ..color = AppColors.borderCyber.withAlpha(25)
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Directed Edges
    for (final edge in edges) {
      final from = nodeMap[edge.fromNodeId];
      final to = nodeMap[edge.toNodeId];
      if (from == null || to == null) continue;

      final start = Offset(from.xRatio * size.width, from.yRatio * size.height);
      final end = Offset(to.xRatio * size.width, to.yRatio * size.height);

      // Edge glow & line
      final edgePaint = Paint()
        ..color = AppColors.cyberCyan.withAlpha(70)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, edgePaint);

      // Telemetry Pulse Particle moving along the edge
      final pulseT = (pulseValue + (edges.indexOf(edge) * 0.15)) % 1.0;
      final pulsePos = Offset.lerp(start, end, pulseT)!;

      final particlePaint = Paint()
        ..color = AppColors.cyberCyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pulsePos, 3.5, particlePaint);

      final particleCore = Paint()..color = Colors.white;
      canvas.drawCircle(pulsePos, 1.8, particleCore);

      // Draw Edge Label Pill if present
      if (edge.label != null && size.width > 300) {
        final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        _drawEdgeLabel(canvas, mid, edge.label!);
      }
    }

    // 3. Draw Nodes
    for (final node in nodes) {
      final center = Offset(node.xRatio * size.width, node.yRatio * size.height);
      final isSelected = node.id == selectedNodeId;

      final nodeColor = switch (node.severity) {
        ThreatSeverityLevel.critical => AppColors.severityCritical,
        ThreatSeverityLevel.high => AppColors.severityHigh,
        ThreatSeverityLevel.suspicious => AppColors.severitySuspicious,
        ThreatSeverityLevel.safe => AppColors.severitySafe,
      };

      // Outer Pulse Glow
      final glowPaint = Paint()
        ..color = nodeColor.withAlpha((isSelected ? 140 : 45))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, isSelected ? 22 : 16, glowPaint);

      // Outer Ring
      final ringPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5;
      canvas.drawCircle(center, isSelected ? 17 : 13, ringPaint);

      // Inner Core Fill
      final fillPaint = Paint()..color = AppColors.cyberSurface;
      canvas.drawCircle(center, isSelected ? 15 : 11, fillPaint);

      // Center Dot Indicator
      final dotPaint = Paint()..color = nodeColor;
      canvas.drawCircle(center, isSelected ? 6 : 4, dotPaint);

      // Node Label Text below or above
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          backgroundColor: AppColors.cyberBackground.withAlpha(200),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 90);

      final labelOffset = Offset(
        center.dx - (textPainter.width / 2),
        center.dy + (center.dy > size.height * 0.8 ? -22 : 16),
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawEdgeLabel(Canvas canvas, Offset position, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = Rect.fromCenter(
      center: position,
      width: textPainter.width + 6,
      height: textPainter.height + 4,
    );

    final bgPaint = Paint()..color = AppColors.cyberBackground.withAlpha(210);
    final borderPaint = Paint()
      ..color = AppColors.borderCyber.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), borderPaint);

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_ScamGraphPainter oldDelegate) => true;
}
