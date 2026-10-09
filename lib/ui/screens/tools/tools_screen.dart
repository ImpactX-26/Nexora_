import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/screens/tools/app_privacy_guard_view.dart';
import 'package:leads/ui/screens/tools/dark_web_monitor_view.dart';
import 'package:leads/ui/screens/tools/phishing_analyzer_view.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';
import 'package:leads/ui/screens/tools/wifi_auditor_view.dart';

class ToolsScreen extends StatefulWidget {
  final ToolsViewModel viewModel;
  final int initialTab;

  const ToolsScreen({
    super.key,
    required this.viewModel,
    this.initialTab = 0,
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
  }

  @override
  void didUpdateWidget(ToolsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget.initialTab.clamp(0, 3));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Text('DEFENSE HUB & TOOLS', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.cyberCyan,
              labelColor: AppColors.cyberCyan,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: AppTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTypography.labelSmall.copyWith(fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.link_off, size: 18), text: 'Phishing Check'),
                Tab(icon: Icon(Icons.security, size: 18), text: 'App Privacy'),
                Tab(icon: Icon(Icons.wifi_find, size: 18), text: 'Wi-Fi Auditor'),
                Tab(icon: Icon(Icons.travel_explore, size: 18), text: 'Dark Web'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              PhishingAnalyzerView(viewModel: widget.viewModel),
              AppPrivacyGuardView(viewModel: widget.viewModel),
              WifiAuditorView(viewModel: widget.viewModel),
              DarkWebMonitorView(viewModel: widget.viewModel),
            ],
          ),
        );
      },
    );
  }
}
