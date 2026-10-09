import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/severity_badge.dart';

class TimelineItemView extends StatefulWidget {
  final TimelineEventItem event;
  final bool isLast;

  const TimelineItemView({
    super.key,
    required this.event,
    this.isLast = false,
  });

  @override
  State<TimelineItemView> createState() => _TimelineItemViewState();
}

class _TimelineItemViewState extends State<TimelineItemView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final eventColor = switch (widget.event.severity) {
      ThreatSeverityLevel.critical => AppColors.severityCritical,
      ThreatSeverityLevel.high => AppColors.severityHigh,
      ThreatSeverityLevel.suspicious => AppColors.severitySuspicious,
      ThreatSeverityLevel.safe => AppColors.severitySafe,
    };

    final icon = switch (widget.event.type) {
      NodeType.sms => Icons.sms_outlined,
      NodeType.phoneNumber => Icons.phone_callback_outlined,
      NodeType.url => Icons.link,
      NodeType.domain => Icons.language,
      NodeType.ipAddress => Icons.router_outlined,
      NodeType.apkDownload => Icons.download_outlined,
      NodeType.application => Icons.apps,
      NodeType.callSignal => Icons.phone_in_talk_outlined,
      NodeType.incident => Icons.warning_amber_rounded,
      NodeType.targetBank => Icons.account_balance_outlined,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator Column
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: eventColor.withAlpha(35),
                  shape: BoxShape.circle,
                  border: Border.all(color: eventColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: eventColor.withAlpha(50),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(icon, size: 16, color: eventColor),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.borderCyber,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyberSurfaceVariant.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderCyber.withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.event.time,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.cyberCyan,
                            fontSize: 10,
                          ),
                        ),
                        SeverityBadge.fromLevel(severity: widget.event.severity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
