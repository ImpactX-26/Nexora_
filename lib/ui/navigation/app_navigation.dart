import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/ui/screens/chat/agent_chat_screen.dart';
import 'package:leads/ui/screens/chat/agent_chat_view_model.dart';
import 'package:leads/ui/screens/dashboard/dashboard_screen.dart';
import 'package:leads/ui/screens/dashboard/dashboard_view_model.dart';
import 'package:leads/ui/screens/investigate/investigate_screen.dart';
import 'package:leads/ui/screens/investigate/investigate_view_model.dart';
import 'package:leads/ui/screens/scanner/scanner_screen.dart';
import 'package:leads/ui/screens/scanner/scanner_view_model.dart';
import 'package:leads/ui/screens/settings/settings_screen.dart';
import 'package:leads/ui/screens/settings/settings_view_model.dart';
import 'package:leads/ui/screens/tools/tools_screen.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';

class AppNavigationHost extends StatefulWidget {
  final DashboardViewModel dashboardViewModel;
  final ScannerViewModel scannerViewModel;
  final InvestigateViewModel investigateViewModel;
  final AgentChatViewModel chatViewModel;
  final ToolsViewModel toolsViewModel;
  final SettingsViewModel settingsViewModel;

  const AppNavigationHost({
    super.key,
    required this.dashboardViewModel,
    required this.scannerViewModel,
    required this.investigateViewModel,
    required this.chatViewModel,
    required this.toolsViewModel,
    required this.settingsViewModel,
  });

  @override
  State<AppNavigationHost> createState() => _AppNavigationHostState();
}

class _AppNavigationHostState extends State<AppNavigationHost> {
  int _currentIndex = 0;
  int _toolsInitialTab = 0;

  void _navigateToTab(int index, [int? subTab]) {
    setState(() {
      _currentIndex = index;
      if (subTab != null) {
        _toolsInitialTab = subTab;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cyberBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            viewModel: widget.dashboardViewModel,
            onNavigateToScanner: () => _navigateToTab(1),
            onNavigateToChat: () => _navigateToTab(3),
            onNavigateToInvestigate: () => _navigateToTab(2),
            onNavigateToTools: (tabIndex) => _navigateToTab(4, tabIndex),
          ),
          ScannerScreen(viewModel: widget.scannerViewModel),
          InvestigateScreen(viewModel: widget.investigateViewModel),
          AgentChatScreen(viewModel: widget.chatViewModel),
          ToolsScreen(
            viewModel: widget.toolsViewModel,
            initialTab: _toolsInitialTab,
          ),
          SettingsScreen(viewModel: widget.settingsViewModel),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderCyber, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              selectedIcon: Icon(Icons.hub),
              label: 'Investigate',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'AI Agent',
            ),
            NavigationDestination(
              icon: Icon(Icons.security_outlined),
              selectedIcon: Icon(Icons.security),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
