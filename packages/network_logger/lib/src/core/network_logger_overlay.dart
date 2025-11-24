import 'package:flutter/material.dart';
import '../widgets/advanced_network_log_viewer.dart';

/// NetworkLoggerOverlay - Simple overlay management for network logger
class NetworkLoggerOverlay {
  static bool _isAttached = false;

  /// Attach the network logger overlay to the given context
  static void attachTo(BuildContext context) {
    if (_isAttached) {
      debugPrint('🌐 NetworkLoggerOverlay: Already attached');
      return;
    }

    _isAttached = true;
    debugPrint('🌐 NetworkLoggerOverlay: Attached to context');
    
    // You can add overlay button logic here if needed
    // For now, just mark as attached
  }

  /// Detach the overlay
  static void detach() {
    if (!_isAttached) return;
    _isAttached = false;
    debugPrint('🌐 NetworkLoggerOverlay: Detached');
  }

  /// Check if overlay is currently attached
  static bool get isAttached => _isAttached;

  /// Show the network logs viewer
  static void showLogs(BuildContext context) {
    debugPrint('🌐 NetworkLoggerOverlay: Show logs requested');
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const AdvancedNetworkLogViewer(),
          fullscreenDialog: true,
        ),
      );
    } catch (e) {
      debugPrint('🌐 Error opening NetworkLogViewer: $e');
    }
  }
}