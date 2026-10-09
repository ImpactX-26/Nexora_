import 'package:flutter/material.dart';

class AppColors {
  // Leads Brand Theme (Extracted from leads-logo.jpeg & app-logo.png)
  static const Color leadsLime = Color(0xFFA6F55D); // Vibrant Electric Lime from Logo
  static const Color leadsLimeLight = Color(0xFFC8FFA1); // Soft Lime Tint
  static const Color leadsLimeDark = Color(0xFF75C725); // Deep Lime
  static const Color leadsLimeGlow = Color(0x66A6F55D); // Atmospheric Lime Glow
  static const Color leadsCharcoal = Color(0xFF424242); // Slate Charcoal from Logo
  static const Color leadsWhite = Color(0xFFFFFFFF); // Pure White

  // Sleek Dark Cyber-Obsidian Backgrounds with Lime Ambiance
  static const Color cyberBackground = Color(0xFF0B1108); // Ultra Dark Forest Obsidian
  static const Color cyberSurface = Color(0xFF131D10);
  static const Color cyberSurfaceVariant = Color(0xFF1C2A18);
  static const Color cyberSurfaceLight = Color(0xFF283A22);
  static const Color cyberSurfaceElevated = Color(0xFF1E2D19);

  // Primary & Accent Tones
  static const Color cyberCyan = leadsLime;
  static const Color cyberCyanDark = Color(0xFF1B3811);
  static const Color cyberPurple = Color(0xFF9D7BFF);
  static const Color cyberPurpleDark = Color(0xFF2E1065);
  static const Color cyberBlue = Color(0xFF38BDF8);

  // Status Tones
  static const Color severitySafe = leadsLime;
  static const Color severitySuspicious = Color(0xFFFBBF24);
  static const Color severityHigh = Color(0xFFFB923C);
  static const Color severityCritical = Color(0xFFF87171);

  static const Color cyberGreen = leadsLime;
  static const Color cyberGreenDark = Color(0xFF183B0E);
  static const Color cyberAmber = severitySuspicious;
  static const Color cyberAmberDark = Color(0xFF451A03);
  static const Color cyberRed = severityCritical;
  static const Color cyberRedDark = Color(0xFF450A0A);

  // Typography & Borders
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFC0CCBE);
  static const Color textMuted = Color(0xFF7E8E7C);
  static const Color borderCyber = Color(0xFF293D25);
  static const Color borderSubtle = Color(0xFF1C2B19);
  static const Color borderHighlight = leadsLime;
  static const Color nodeGlow = leadsLimeGlow;
}

