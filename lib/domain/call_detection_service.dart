import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_leads_service.dart';

class CallDetectionService {
  static StreamSubscription<PhoneState>? _subscription;

  static Future<void> initialize() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      _subscription = PhoneState.stream.listen((event) {
        if (event.status == PhoneStateStatus.CALL_INCOMING || event.status == PhoneStateStatus.CALL_STARTED) {
          _showOverlay();
        } else if (event.status == PhoneStateStatus.CALL_ENDED) {
          _closeOverlay();
        }
      });
      
      // Listen to commands from overlay
      FlutterOverlayWindow.overlayListener.listen((event) {
        if (event == "START_RECORDING") {
          VoiceLeadsService.startRecording(); // Starts the real recording service
        } else if (event == "STOP_RECORDING") {
          VoiceLeadsService.stopAndAnalyze();
        }
      });
    }
  }

  static Future<void> _showOverlay() async {
    final bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) return;
    
    final bool isActive = await FlutterOverlayWindow.isActive();
    if (!isActive) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Voice Leads Sentinel",
        overlayContent: "Monitoring call for scams",
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.center,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: 100,
        width: 300,
      );
    }
  }

  static void _closeOverlay() async {
    final bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      FlutterOverlayWindow.closeOverlay();
    }
    VoiceLeadsService.resetState();
  }
}
