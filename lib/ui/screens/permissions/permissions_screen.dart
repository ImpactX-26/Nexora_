import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/agent_settings.dart';
import 'package:leads/data/repositories/incident_repository.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/section_header.dart';

class PermissionsScreen extends StatefulWidget {
  final IncidentRepository repository;

  const PermissionsScreen({super.key, required this.repository});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late List<SecurityPermissionItem> _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = widget.repository.permissions;
  }

  void _toggle(String id, bool val) {
    setState(() {
      _permissions = _permissions.map((p) => p.id == id ? p.copyWith(isGranted: val) : p).toList();
    });
    widget.repository.togglePermission(id, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cyberBackground,
      appBar: AppBar(
        title: Text('SECURITY PERMISSIONS', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyberCyan.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.privacy_tip_outlined, color: AppColors.cyberCyan, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Perimeter Defense Privileges', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text('Enables LEADS to intercept SMS phishing, malicious APK downloads, & spoofed calls in real-time.', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Required Privileges'),
          ..._permissions.map((perm) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderColor: perm.isGranted ? AppColors.severitySafe.withAlpha(80) : AppColors.borderCyber,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(perm.name, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: perm.isGranted ? AppColors.severitySafe.withAlpha(30) : AppColors.cyberSurfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  perm.isGranted ? 'GRANTED' : 'RESTRICTED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: perm.isGranted ? AppColors.severitySafe : AppColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(perm.whyNeeded, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    Switch(
                      value: perm.isGranted,
                      activeThumbColor: AppColors.severitySafe,
                      onChanged: (val) => _toggle(perm.id, val),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
