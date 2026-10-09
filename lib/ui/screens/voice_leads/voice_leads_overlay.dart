import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceLeadsOverlay extends StatefulWidget {
  const VoiceLeadsOverlay({Key? key}) : super(key: key);

  @override
  State<VoiceLeadsOverlay> createState() => _VoiceLeadsOverlayState();
}

class _VoiceLeadsOverlayState extends State<VoiceLeadsOverlay> {
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _seconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
      // Tell the main app to start recording via Isolate communication
      FlutterOverlayWindow.shareData("START_RECORDING");
    } else {
      _timer?.cancel();
      // Tell main app to stop and analyze
      FlutterOverlayWindow.shareData("STOP_RECORDING");
      // Close overlay after stopping
      Future.delayed(const Duration(milliseconds: 500), () {
        FlutterOverlayWindow.closeOverlay();
      });
    }
  }

  String get _formattedTime {
    final m = (_seconds / 60).floor().toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E201E),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.redAccent : Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRecording ? "Analyzing..." : "Record with Leads",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_isRecording)
                  Text(
                    _formattedTime,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => FlutterOverlayWindow.closeOverlay(),
              child: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
