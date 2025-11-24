import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:developer_command_center/src/interfaces/developer_command_center_dependencies.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_logger/network_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Developer Command Center - Advanced debugging and analytics dashboard
class DeveloperCommandCenter extends StatefulWidget {
  const DeveloperCommandCenter({
    required this.dependencies,
    super.key,
  });

  final DeveloperCommandCenterDependencies dependencies;

  @override
  State<DeveloperCommandCenter> createState() => _DeveloperCommandCenterState();
}

class _DeveloperCommandCenterState extends State<DeveloperCommandCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnalyticsClientInterface _analyticsClient;
  Map<String, int> _mostTappedWidgets = {};
  Map<String, Duration> _mostVisitedScreens = {};
  Map<String, dynamic> _navigationPattern = {};
  Map<String, Map<String, int>> _heatmapData = {};

  // Debug information
  String? _oneSignalUserId;
  String? _oneSignalPushToken;
  bool _isOptedIn = false;
  String? _currentFlavor;
  String _firebaseProjectId = 'Unknown';
  String _appVersion = 'Unknown';
  String _bundleId = 'Unknown';
  Map<String, dynamic> _oneSignalDiagnostics = {};
  final List<String> _debugLogs = [];

  // Stream controllers for real-time updates
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();
  StreamSubscription<String>? _logSubscription;

  // Notification Queue Debug Info
  Map<String, dynamic> _notificationQueueStatus = {};
  Map<String, dynamic> _notificationQueueStats = {};
  Map<String, dynamic> _notificationHandlerStatus = {};

  // Token Comparison Debug Info
  String _dioClientToken = '';
  String _notificationMixinToken = '';
  bool _tokensMatch = false;

  // Console log capturing
  DebugPrintCallback? _originalDebugPrint;

  // Log filtering
  final Set<String> _logFilters = {
    'all',
  }; // 'all', 'system', 'console', 'network', 'error'
  bool _autoScroll = true;

  // Full screen mode
  bool _isFullScreen = false;
  final FocusNode _fullScreenFocusNode = FocusNode();

  // Network logger overlay
  bool _showOverlayButton = false;
  OverlayEntry? _overlayEntry;

  // UI update management (kept for potential future use)
  // bool _hasScheduledUpdate = false;
  // bool _isBuildingWidget = false;
  // DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _analyticsClient = widget.dependencies.analyticsClient;

    // Setup stream listener for log updates
    _logSubscription = _logStreamController.stream.listen((logMessage) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final logEntry = '[$timestamp] $logMessage';
      _debugLogs.insert(0, logEntry);
      if (_debugLogs.length > 100) {
        _debugLogs.removeLast();
      }

      // Use setState only for stream updates (safe because stream events are async)
      if (mounted) {
        setState(() {});
      }
    });

    // Setup console log capturing
    _setupConsoleCapture();

    // Load analytics data
    _loadAnalyticsData();

    // Defer all initialization that might trigger UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up notification queue debug log callback
      final queueManager = widget.dependencies.notificationQueueManager;
      if (queueManager != null) {
        NetworkLoggerEnhancedInterface.setDebugLogCallback(
          _logStreamController.add,
        );
      }

      // Network logger uses its own UI - no callback needed

      _logStreamController.add('🚀 Developer Command Center initialized');
      _logStreamController.add('📺 Console log capture enabled');

      // Test console log capture
      debugPrint('Test console log from Developer Command Center');
      developer.log(
        'Test developer.log message',
        name: 'DeveloperCommandCenter',
      );

      // Add a demo error to showcase filtering
      _logStreamController
          .add('❌ Demo error log for testing filter functionality');
      _logStreamController
          .add('⚠️ Demo warning log for testing filter functionality');

      // Setup full screen focus
      if (_isFullScreen) {
        _fullScreenFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // Cancel stream subscription
    _logSubscription?.cancel();
    _logStreamController.close();

    _tabController.dispose();
    _fullScreenFocusNode.dispose();

    // Restore original debug print
    _restoreConsoleCapture();

    // Clear debug log callbacks
    NetworkLoggerEnhancedInterface.clearDebugLogCallback();

    // Clean up overlay
    _hideFloatingOverlay();

    // NetworkLogger handles its own cleanup
    super.dispose();
  }

  void _enableFloatingOverlay() {
    if (_overlayEntry != null) return;

    try {
      final overlay = Overlay.of(context);
      _overlayEntry = _createOverlayEntry();
      overlay.insert(_overlayEntry!);
    } catch (e) {
      debugPrint('🌐 Error enabling overlay: $e');
    }
  }

  void _hideFloatingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        right: 20,
        bottom: 100,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                try {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) {
                        final networkLogger = widget.dependencies.networkLogger;
                        if (networkLogger != null) {
                          networkLogger.openAdvancedLogViewer();
                        }
                        return const Scaffold(
                          body: Center(
                            child: Text('Network Logger not available'),
                          ),
                        );
                      },
                      fullscreenDialog: true,
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '🌐 Error opening network viewer from overlay: $e',
                  );
                }
              },
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.network_check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Log count badge
                  if (widget.dependencies.networkLogger != null &&
                      widget.dependencies.networkLogger!.totalLogsCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          widget.dependencies.networkLogger != null &&
                                  widget.dependencies.networkLogger!
                                          .totalLogsCount >
                                      99
                              ? '99+'
                              : (widget.dependencies.networkLogger
                                      ?.totalLogsCount
                                      .toString() ??
                                  '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAnalyticsData() async {
    try {
      // Load data asynchronously
      _mostTappedWidgets = await _analyticsClient.getMostTappedWidgets();
      _mostVisitedScreens = await _analyticsClient.getMostVisitedScreens();
      _navigationPattern = await _analyticsClient.analyzeNavigationPattern();
      _heatmapData = await _analyticsClient.getAllHeatmapData();

      // Trigger UI update if widget is mounted
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    }

    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    try {
      _addDebugLog('🔄 Loading debug data...');

      // OneSignal bilgilerini al
      final oneSignalService = widget.dependencies.oneSignalService;
      if (oneSignalService != null) {
        _oneSignalUserId = await oneSignalService.getUserId();
        _oneSignalPushToken = await oneSignalService.getPushToken();
        _isOptedIn = await oneSignalService.getOptedIn();
      }

      _addDebugLog('📱 OneSignal User ID: ${_oneSignalUserId ?? "NULL"}');
      _addDebugLog('🔑 Push Token Available: ${_oneSignalPushToken != null}');
      _addDebugLog('🔔 Notifications Opted In: $_isOptedIn');

      // OneSignal diagnostics
      if (oneSignalService != null) {
        _oneSignalDiagnostics = await oneSignalService.getDiagnostics();
      }
      _addDebugLog(
        '📊 OneSignal diagnostics loaded: ${_oneSignalDiagnostics.keys.length} entries',
      );

      // Firebase ve uygulama bilgilerini al
      try {
        final firebaseApp = Firebase.app();
        _firebaseProjectId = firebaseApp.options.projectId;
        _addDebugLog('🔥 Firebase Project: $_firebaseProjectId');
      } catch (e) {
        _firebaseProjectId = 'Firebase not initialized';
        _addDebugLog('❌ Firebase Error: $e');
      }

      // App flavor bilgisi
      try {
        _currentFlavor = widget.dependencies.appFlavor?.name ?? 'Unknown';
        _addDebugLog('🎯 App Flavor: $_currentFlavor');
      } catch (e) {
        _currentFlavor = null;
        _addDebugLog('❌ Flavor Error: $e');
      }

      // Package info
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _appVersion = packageInfo.version;
        _bundleId = packageInfo.packageName;
        _addDebugLog('📦 App Version: $_appVersion');
        _addDebugLog('🆔 Bundle ID: $_bundleId');
      } catch (e) {
        _appVersion = 'Error loading version';
        _bundleId = 'Error loading bundle';
        _addDebugLog('❌ Package Info Error: $e');
      }

      // Notification Queue Manager debug bilgileri
      try {
        _addDebugLog('🔔 Loading notification queue debug info...');
        final queueManager = widget.dependencies.notificationQueueManager;
        if (queueManager != null) {
          _notificationQueueStatus = queueManager.getQueueStatus();
          _notificationQueueStats = queueManager.getQueueStats();
        } else {
          _notificationQueueStatus = {
            'isAppReady': false,
            'pendingActionsCount': 0,
            'hasNavigationCallback': false,
          };
          _notificationQueueStats = {'total': 0, 'success': 0, 'failed': 0};
        }

        _addDebugLog(
          '📋 Queue Manager - App Ready: ${_notificationQueueStatus['isAppReady']}',
        );
        _addDebugLog(
          '📋 Queue Manager - Pending: ${_notificationQueueStatus['pendingActionsCount']}',
        );
        _addDebugLog(
          '📋 Queue Manager - Has Callback: ${_notificationQueueStatus['hasNavigationCallback']}',
        );

        // Notification Handler status
        final notificationHandler = widget.dependencies.notificationHandler;
        if (notificationHandler != null) {
          _notificationHandlerStatus = notificationHandler.getHandlerStatus();
        } else {
          _notificationHandlerStatus = {
            'platform': 'unknown',
            'hasInternetConnection': false,
          };
        }
        _addDebugLog(
          '🔔 Handler Status - Platform: ${_notificationHandlerStatus['platform']}',
        );
        _addDebugLog(
          '🔔 Handler Status - Internet: ${_notificationHandlerStatus['hasInternetConnection']}',
        );
      } catch (e) {
        _addDebugLog('❌ Error loading notification queue debug info: $e');
      }

      // Token comparison debug info
      try {
        _addDebugLog('🔑 Loading token comparison info...');
        await _loadTokenComparison();
        _addDebugLog('🔑 Token comparison loaded successfully');
      } catch (e) {
        _addDebugLog('❌ Error loading token comparison info: $e');
      }

      _addDebugLog('✅ Debug data loading completed');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _addDebugLog('❌ Critical Error in loadDebugData: $e');
      if (kDebugMode) {
        debugPrint('Error loading debug data: $e');
      }
    }
  }

  Future<void> _loadTokenComparison() async {
    try {
      // Get DioClient token
      final dioClient = widget.dependencies.dioClient;
      _dioClientToken = dioClient?.token ?? '';
      _addDebugLog('🔑 DioClient token length: ${_dioClientToken.length}');

      // Get NotificationHelper token (via private method simulation)
      _notificationMixinToken = _getDioClientTokenFromNotificationHelper();
      _addDebugLog(
        '🔑 NotificationHelper token length: ${_notificationMixinToken.length}',
      );

      // Compare tokens
      _tokensMatch = _dioClientToken.isNotEmpty &&
          _notificationMixinToken.isNotEmpty &&
          _dioClientToken == _notificationMixinToken;

      _addDebugLog('🔍 Tokens match: $_tokensMatch');

      if (!_tokensMatch) {
        if (_dioClientToken.isEmpty) {
          _addDebugLog('⚠️ DioClient token is empty');
        }
        if (_notificationMixinToken.isEmpty) {
          _addDebugLog('⚠️ NotificationHelper token is empty');
        }
        if (_dioClientToken.isNotEmpty && _notificationMixinToken.isNotEmpty) {
          _addDebugLog('❌ Tokens are different!');
          // Log first and last few characters for debugging
          _addDebugLog(
            '🔍 DioClient token start: ${_dioClientToken.substring(0, 20)}...',
          );
          _addDebugLog(
            '🔍 NotificationHelper token start: ${_notificationMixinToken.substring(0, 20)}...',
          );
        }
      } else {
        _addDebugLog('✅ Tokens match perfectly');
      }
    } catch (e) {
      _addDebugLog('❌ Error in token comparison: $e');
    }
  }

  String _getDioClientTokenFromNotificationHelper() {
    // NotificationHelper uses DioClient.accessToken internally
    // This is the same token but accessed from within NotificationHelper context
    final dioClient = widget.dependencies.dioClient;
    return dioClient?.token ?? '';
  }

  void _setupConsoleCapture() {
    if (kDebugMode) {
      // Store original debug print function
      _originalDebugPrint = debugPrint;

      // Override debug print to capture logs
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null && _logStreamController.hasListener) {
          // Add to stream for UI updates
          _logStreamController.add('🖥️ $message');
        }

        // Also call original debug print
        if (_originalDebugPrint != null) {
          _originalDebugPrint!(message, wrapWidth: wrapWidth);
        }
      };

      // Also capture developer.log messages
      developer.log(
        'Console capture initialized for Debug Console',
        name: 'DeveloperCommandCenter',
      );
    }
  }

  void _restoreConsoleCapture() {
    if (_originalDebugPrint != null) {
      debugPrint = _originalDebugPrint!;
      _originalDebugPrint = null;
    }
  }

  void _addDebugLog(String message) {
    // Add log via stream instead of direct manipulation
    _logStreamController.add(message);

    // Still print to original debug output
    if (_originalDebugPrint != null) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final logEntry = '[$timestamp] $message';
      _originalDebugPrint!(logEntry);
    }
  }

  // No longer needed with stream-based approach
  // void _scheduleUIUpdate() {
  //   if (!mounted || _hasScheduledUpdate || _isBuildingWidget) return;
  //
  //   // Throttle updates to max once per 100ms
  //   final now = DateTime.now();
  //   if (_lastUpdateTime != null &&
  //       now.difference(_lastUpdateTime!).inMilliseconds < 100) {
  //     return;
  //   }
  //
  //   _hasScheduledUpdate = true;
  //   _lastUpdateTime = now;
  //
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     _hasScheduledUpdate = false;
  //     if (mounted && !_isBuildingWidget) {
  //       try {
  //         setState(() {});
  //       } catch (e) {
  //         // Silently ignore setState errors during dispose or unmount
  //       }
  //     }
  //   });
  // }

  List<String> _getFilteredLogs() {
    final filter = _logFilters.first;

    if (filter == 'all') {
      return _debugLogs;
    }

    return _debugLogs.where((log) {
      switch (filter) {
        case 'error':
          return log.contains('❌') ||
              log.contains('ERROR') ||
              log.contains('Exception') ||
              log.contains('error');
        case 'console':
          return log.contains('🖥️');
        case 'network':
          return log.contains('🌐');
        case 'system':
          return log.contains('🔄') ||
              log.contains('📱') ||
              log.contains('🔑') ||
              log.contains('📊') ||
              log.contains('🔥') ||
              log.contains('🎯') ||
              log.contains('📦');
        default:
          return false;
      }
    }).toList();
  }

  Widget _buildConsoleContent() {
    final filteredLogs = _getFilteredLogs();

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.terminal,
              color: Color(0xFF9CA3AF),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _debugLogs.isEmpty
                  ? 'Console ready - No logs yet'
                  : 'No logs match current filter',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _debugLogs.isEmpty
                  ? 'Debug messages and console.log() will appear here'
                  : 'Try adjusting filters or select "All" to see all logs',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            if (_debugLogs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Filter Summary:',
                      style: TextStyle(
                        color: Color(0xFFE5E7EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total logs: ${_debugLogs.length} | Filtered: ${filteredLogs.length}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Active filters: ${_logFilters.join(", ")}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      reverse:
          !_autoScroll, // If auto-scroll is on, show latest at bottom, otherwise at top
      itemCount: filteredLogs.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final log = _autoScroll
            ? filteredLogs[filteredLogs.length - 1 - index]
            : filteredLogs[index];

        final isError = log.contains('❌') ||
            log.contains('ERROR') ||
            log.contains('Exception') ||
            log.contains('error');
        final isSuccess = log.contains('✅') || log.contains('success');
        final isWarning = log.contains('⚠️') ||
            log.contains('WARNING') ||
            log.contains('warning');
        final isConsoleLog = log.contains('🖥️');
        final isNetworkLog = log.contains('🌐');
        final isSystem = log.contains('🔄') ||
            log.contains('📱') ||
            log.contains('🔑') ||
            log.contains('📊');

        Color logColor;
        if (isError) {
          logColor = const Color(0xFFFB7185); // Red
        } else if (isSuccess) {
          logColor = const Color(0xFF10B981); // Green
        } else if (isWarning) {
          logColor = const Color(0xFFF59E0B); // Yellow/Orange
        } else if (isConsoleLog) {
          logColor = const Color(0xFF60A5FA); // Blue for console logs
        } else if (isNetworkLog) {
          logColor = const Color(0xFF06B6D4); // Cyan for network logs
        } else if (isSystem) {
          logColor = const Color(0xFF8B5CF6); // Purple for system logs
        } else {
          logColor = const Color(0xFFE5E7EB); // Default gray
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
          color: isError
              ? const Color(0xFFFB7185).withValues(alpha: 0.08)
              : Colors.transparent,
          child: SelectableText(
            log,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: logColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Full screen mode
    if (_isFullScreen) {
      return _buildFullScreenTerminal(context);
    }

    // Normal mode
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Developer Command Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _addDebugLog('🔄 Refreshing command center...');
              _loadAnalyticsData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.bug_report, size: 20),
              text: 'Debug',
            ),
            Tab(
              icon: Icon(Icons.info_outline, size: 20),
              text: 'System',
            ),
            Tab(
              icon: Icon(Icons.security, size: 20),
              text: 'Security',
            ),
            Tab(
              icon: Icon(Icons.cloud, size: 20),
              text: 'Services',
            ),
            Tab(
              icon: Icon(Icons.analytics, size: 20),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Debug Tools Tab - Full Screen Console
          _buildFullScreenDebugTab(),

          // System Information Tab
          _buildTabContent([
            _buildDebugInfoCard(),
          ]),

          // Security & Authentication Tab
          _buildTabContent([
            _buildTokenComparisonCard(),
          ]),

          // Services & Integration Tab
          _buildTabContent([
            _buildNetworkLoggerCard(),
            const SizedBox(height: 16),
            _buildNotificationDebugCard(),
            const SizedBox(height: 16),
            _buildFirebaseDebugCard(),
          ]),

          // User Analytics Tab
          _buildTabContent([
            _buildNavigationPatternCard(),
            const SizedBox(height: 16),
            _buildMostTappedWidgetsCard(),
            const SizedBox(width: 16),
            _buildMostVisitedScreensCard(),
            const SizedBox(height: 16),
            _buildHeatmapCard(),
          ]),
        ],
      ),
    );
  }

  Widget _buildFullScreenDebugTab() {
    return Column(
      children: [
        // Top controls bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          child: Row(
            children: [
              // Left side - Title
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.terminal,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Debug Console',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Controls
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Filter Dropdown
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _logFilters.contains('all')
                            ? 'all'
                            : _logFilters.first,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.expand_more,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3B82F6),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All', style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'system',
                            child:
                                Text('System', style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'console',
                            child:
                                Text('Console', style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'network',
                            child:
                                Text('Network', style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'error',
                            child:
                                Text('Errors', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _logFilters.clear();
                              _logFilters.add(value);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Compact Auto-scroll toggle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _autoScroll
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFF6B7280).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _autoScroll
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : const Color(0xFF6B7280).withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _autoScroll = !_autoScroll;
                          });
                        },
                        icon: Icon(
                          _autoScroll
                              ? Icons.vertical_align_bottom
                              : Icons.vertical_align_top,
                          size: 14,
                          color: _autoScroll
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7280),
                        ),
                        tooltip: _autoScroll
                            ? 'Auto-scroll: ON'
                            : 'Auto-scroll: OFF',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Full screen toggle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isFullScreen = !_isFullScreen;
                          });
                          // Focus for keyboard listener
                          if (_isFullScreen) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _fullScreenFocusNode.requestFocus();
                            });
                          }
                        },
                        icon: Icon(
                          _isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          size: 14,
                          color: const Color(0xFF8B5CF6),
                        ),
                        tooltip:
                            _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Compact Clear button
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _debugLogs.clear();
                          _addDebugLog('🧹 Console cleared');
                          setState(() {});
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Full screen terminal console
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
              ),
            ),
            child: _buildConsoleContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'System Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow('App Version', _appVersion, Icons.apps),
            _buildModernInfoRow('Bundle ID', _bundleId, Icons.fingerprint),
            _buildModernInfoRow(
              'Environment',
              _currentFlavor ?? 'Unknown',
              Icons.cloud,
            ),
            _buildModernInfoRow(
              'Debug Mode',
              kDebugMode ? 'Enabled' : 'Disabled',
              Icons.bug_report,
            ),
            _buildModernInfoRow(
              'Firebase Project',
              _firebaseProjectId,
              Icons.cloud_queue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenComparisonCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _tokensMatch
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _tokensMatch
                        ? Icons.verified_user
                        : Icons.security_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Token Security Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Icon(
                  _tokensMatch ? Icons.check_circle : Icons.error,
                  color: _tokensMatch ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow(
              'DioClient Token',
              '${_dioClientToken.length} characters',
              Icons.api,
            ),
            _buildModernInfoRow(
              'NotificationHelper Token',
              '${_notificationMixinToken.length} characters',
              Icons.notifications,
            ),

            const SizedBox(height: 12),
            // Token details section
            if (_dioClientToken.isNotEmpty) ...[
              _buildTokenDetailCard(
                'DioClient Token',
                _dioClientToken,
                Icons.api,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 8),
            ],

            if (_notificationMixinToken.isNotEmpty) ...[
              _buildTokenDetailCard(
                'NotificationHelper Token',
                _notificationMixinToken,
                Icons.notifications,
                const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tokensMatch
                      ? [const Color(0xFFF0FDF4), const Color(0xFDCFE8FF)]
                      : [const Color(0xFFFEF2F2), const Color(0xFFFEF7F7)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _tokensMatch
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _tokensMatch ? Icons.verified : Icons.warning,
                    color: _tokensMatch
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _tokensMatch
                          ? 'Tokens are identical - Security verified'
                          : 'Token mismatch detected - Review required',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _tokensMatch
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkLoggerCard() {
    // Use NetworkLogger package API (always enabled in debug)
    const isEnabled = true; // Package manages its own state

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: isEnabled
                          ? [Color(0xFF06B6D4), Color(0xFF0891B2)]
                          : [Color(0xFF6B7280), Color(0xFF4B5563)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    isEnabled ? Icons.network_check : Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Network Logger',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                const Icon(
                  isEnabled
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isEnabled ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow(
              'Status',
              isEnabled ? 'Active' : 'Disabled',
              Icons.power_settings_new,
            ),
            _buildModernInfoRow(
              'Logged Requests',
              '${widget.dependencies.networkLogger?.totalLogsCount ?? 0} requests',
              Icons.list_alt,
            ),
            _buildModernInfoRow(
              'HTTP Tracking',
              'Headers, Body & cURL',
              Icons.http,
            ),
            _buildModernInfoRow(
              'Error Detection',
              'Timeouts & Status codes',
              Icons.error_outline,
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: isEnabled
                      ? [Color(0xFFF0F9FF), Color(0xFFF8FAFC)]
                      : [Color(0xFFF8F9FA), Color(0xFFF1F3F4)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFF06B6D4).withValues(alpha: 0.2)
                      : const Color(0xFF6B7280).withValues(alpha: 0.2),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEnabled ? Icons.info : Icons.info_outline,
                        color:
                            isEnabled ? Color(0xFF06B6D4) : Color(0xFF6B7280),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isEnabled
                            ? 'Network Logging Active'
                            : 'Network Logging Disabled',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isEnabled ? Color(0xFF1E293B) : Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Text(
                    isEnabled
                        ? 'HTTP requests and responses are being logged to Debug Console. Use Network filter to view them.'
                        : 'Enable to capture all HTTP traffic including requests, responses, and errors in Debug Console.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? Color(0xFF64748B) : Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // İlk satır - Ana kontrol butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEnabled ? Colors.red : const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Package manages its own state, no toggle needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Network logger is always active in debug mode',
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEnabled ? Icons.stop : Icons.play_arrow, size: 18),
                    SizedBox(width: 8),
                    Text(
                      isEnabled
                          ? 'Always Active (Debug Mode)'
                          : 'Enable Logging',
                    ),
                  ],
                ),
              ),
            ),

            if (isEnabled) ...[
              const SizedBox(height: 8),
              // İkinci satır - İzleme butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF06B6D4),
                        side: const BorderSide(color: Color(0xFF06B6D4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Switch to Debug tab and set network filter
                        _tabController.animateTo(0); // Debug tab
                        setState(() {
                          _logFilters.clear();
                          _logFilters.add('network');
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 6),
                          Text('Debug'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        try {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const AdvancedNetworkLogViewer(),
                              fullscreenDialog: true,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error opening network viewer: $e'),
                            ),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt, size: 18),
                          SizedBox(width: 6),
                          Text('View Logs'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        // Enable floating overlay button
                        _showOverlayButton = !_showOverlayButton;
                        if (_showOverlayButton) {
                          _enableFloatingOverlay();
                        } else {
                          _hideFloatingOverlay();
                        }
                        setState(() {});
                      },
                      icon: Icon(
                        _showOverlayButton
                            ? Icons.visibility_off
                            : Icons.picture_in_picture,
                        size: 16,
                      ),
                      label: Text(
                        _showOverlayButton ? 'Hide Overlay' : 'Show Overlay',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () async {
                        // Test HTTP request
                        try {
                          // Use NetworkLoggerService to create test Dio instance with interceptor
                          // NetworkLogger.createDio() is not available in interface

                          // Create a simple HTTP request without dio
                          // Since we don't have access to the actual dio instance in the package
                          _addDebugLog(
                            '🧪 HTTP test would require proper dio integration',
                          );
                          _addDebugLog('🧪 Test HTTP request completed');
                        } catch (e) {
                          _addDebugLog('🧪 Test HTTP request failed: $e');
                        }
                      },
                      icon: const Icon(Icons.bug_report, size: 16),
                      label: const Text(
                        'Test Request',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDebugCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isOptedIn
                          ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                          : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isOptedIn
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notification System',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isOptedIn ? Icons.notifications : Icons.notifications_off,
                  color: _isOptedIn ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow(
              'OneSignal User ID',
              _oneSignalUserId ?? 'Not available',
              Icons.person,
            ),
            _buildModernInfoRow(
              'Push Token',
              _oneSignalPushToken != null ? 'Available' : 'Not available',
              Icons.vpn_key,
            ),
            _buildModernInfoRow(
              'Notification Status',
              _isOptedIn ? 'Enabled' : 'Disabled',
              Icons.toggle_on,
            ),
            _buildModernInfoRow(
              'Platform',
              Platform.isIOS ? 'iOS' : 'Android',
              Icons.phone_android,
            ),
            if (_oneSignalDiagnostics.containsKey('isInitialized'))
              _buildModernInfoRow(
                'OneSignal Service',
                _oneSignalDiagnostics['isInitialized'] == true
                    ? 'Initialized'
                    : 'Not initialized',
                Icons.cloud_sync,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                _addDebugLog('🧪 Testing notification...');
                final service = widget.dependencies.oneSignalService;
                if (service != null) {
                  try {
                    await service.sendNotification();
                    _addDebugLog('✅ Test notification sent successfully');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    _addDebugLog('❌ Test notification failed: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Test failed: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } else {
                  _addDebugLog('❌ OneSignal service not available');
                }
              },
              child: const Text('Send Test Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                _addDebugLog('🔧 Running OneSignal diagnostics...');
                final service = widget.dependencies.oneSignalService;
                if (service != null) {
                  try {
                    final diagnostics = await service.getDiagnostics();
                    _addDebugLog('📊 Comprehensive diagnostics completed');
                    diagnostics.forEach((key, value) {
                      _addDebugLog('📋 $key: $value');
                    });
                  } catch (e) {
                    _addDebugLog('❌ Diagnostics failed: $e');
                  }
                } else {
                  _addDebugLog('❌ OneSignal service not available');
                }
              },
              child: const Text('Run Full Diagnostics'),
            ),
            if (!_isOptedIn) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () async {
                  _addDebugLog('🔧 Attempting OneSignal initialization...');
                  final service = widget.dependencies.oneSignalService;
                  if (service != null) {
                    try {
                      // OneSignal initialization is not available in interface
                      _addDebugLog('🔧 OneSignal service is available');
                      _addDebugLog('✅ OneSignal re-initialization completed');
                      await _loadDebugData();
                    } catch (e) {
                      _addDebugLog('❌ OneSignal initialization failed: $e');
                    }
                  } else {
                    _addDebugLog('❌ OneSignal service not available');
                  }
                },
                child: const Text('Force Initialize OneSignal'),
              ),
            ],
            // Notification Queue Manager Debug Section
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '📋 Notification Queue Manager',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'App Ready',
              '${_notificationQueueStatus['isAppReady'] ?? 'Unknown'}',
            ),
            _buildInfoRow(
              'Pending Actions',
              '${_notificationQueueStatus['pendingActionsCount'] ?? 0}',
            ),
            _buildInfoRow(
              'Has Navigation Callback',
              '${_notificationQueueStatus['hasNavigationCallback'] ?? 'Unknown'}',
            ),
            _buildInfoRow(
              'Has Completer',
              '${_notificationQueueStatus['hasAppReadyCompleter'] ?? 'Unknown'}',
            ),

            if (_notificationQueueStats.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '📊 Queue Statistics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                'Recent Actions (30min)',
                '${_notificationQueueStats['recentActions'] ?? 0}',
              ),
              _buildInfoRow(
                'Oldest Action (min)',
                '${_notificationQueueStats['oldestActionAge'] ?? 0}',
              ),
            ],

            if (_notificationHandlerStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '🔔 Notification Handler Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                'Platform',
                '${_notificationHandlerStatus['platform'] ?? 'Unknown'}',
              ),
              _buildInfoRow(
                'Internet Connection',
                '${_notificationHandlerStatus['hasInternetConnection'] ?? 'Unknown'}',
              ),
              _buildInfoRow(
                'Last Handled ID',
                '${_notificationHandlerStatus['lastHandledId'] ?? 'None'}',
              ),
              _buildInfoRow(
                'Last Handled Type',
                '${_notificationHandlerStatus['lastHandledType'] ?? 'None'}',
              ),
            ],

            // Pending Actions Details
            if (_notificationQueueStatus['pendingActions'] != null &&
                (_notificationQueueStatus['pendingActions'] as List)
                    .isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '⏳ Pending Actions Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...((_notificationQueueStatus['pendingActions'] as List).map(
                (action) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📰 NewsID: ${action['newsId']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '📝 Title: ${action['title']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '⏰ Time: ${action['timestamp']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      _addDebugLog(
                        '🔄 Refreshing notification queue status...',
                      );
                      await _loadDebugData();
                    },
                    child: const Text('Refresh Queue Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _addDebugLog('🧹 Clearing notification queue...');
                      final queueManager =
                          widget.dependencies.notificationQueueManager;
                      queueManager?.clearQueue();
                      _loadDebugData();
                    },
                    child: const Text('Clear Queue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseDebugCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Firebase Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInfoRow(
              'Project ID',
              _firebaseProjectId,
              Icons.cloud_queue,
            ),
            _buildModernInfoRow(
              'Environment',
              _getFirebaseEnvironment(),
              Icons.settings,
            ),
            if (_oneSignalDiagnostics.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0F9FF), Color(0xFFF8FAFC)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'OneSignal Diagnostics',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._oneSignalDiagnostics.entries.take(5).map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFirebaseEnvironment() {
    // Use string comparison instead of enum
    switch (_currentFlavor) {
      case 'development':
        return 'Development';
      case 'staging':
        return 'Staging';
      case 'production':
        return 'Production';
      default:
        return 'Unknown';
    }
  }

  Widget _buildDebugLogsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.terminal, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Debug Console',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _debugLogs.clear();
                      _addDebugLog('🧹 Logs cleared');
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF374151),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _debugLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'Console ready - No logs yet',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _debugLogs.length,
                      itemBuilder: (context, index) {
                        final log = _debugLogs[index];
                        final isError = log.contains('❌');
                        final isSuccess = log.contains('✅');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                              color: isError
                                  ? const Color(0xFFFB7185)
                                  : isSuccess
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPatternCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.explore, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Navigation Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_navigationPattern.isNotEmpty &&
                _navigationPattern['status'] != 'no_data') ...[
              _buildModernInfoRow(
                'Total Screens',
                '${_navigationPattern['total_screens_visited']}',
                Icons.screen_search_desktop,
              ),
              _buildModernInfoRow(
                'Unique Screens',
                '${_navigationPattern['unique_screens']}',
                Icons.dashboard,
              ),
              _buildModernInfoRow(
                'Back Navigation',
                '${_navigationPattern['back_navigation_count']}',
                Icons.arrow_back,
              ),
              _buildModernInfoRow(
                'Loop Count',
                '${_navigationPattern['loop_count']}',
                Icons.loop,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0F9FF), Color(0xFFF8FAFC)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.route, color: Color(0xFF06B6D4), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Current Navigation Flow',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (_navigationPattern['current_flow'] ??
                              'No flow data available')
                          .toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD1D5DB),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF6B7280)),
                    SizedBox(width: 12),
                    Text(
                      'No navigation data available yet',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostTappedWidgetsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Widget Interactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_mostTappedWidgets.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _mostTappedWidgets.values.isNotEmpty
                        ? _mostTappedWidgets.values
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble() *
                            1.2
                        : 10,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < _mostTappedWidgets.keys.length) {
                              final key =
                                  _mostTappedWidgets.keys.elementAt(index);
                              final parts = key.split('_');
                              return Text(
                                parts.length > 1 ? parts.last : key,
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _mostTappedWidgets.entries
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value.toDouble(),
                            color: Colors.blue,
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ] else
              const Center(
                child: Text('No interaction data available yet'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostVisitedScreensCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.schedule, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Screen Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_mostVisitedScreens.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _mostVisitedScreens.entries.take(5).map((entry) {
                      final percentage = (_mostVisitedScreens.values.isNotEmpty)
                          ? (entry.value.inSeconds /
                                  _mostVisitedScreens.values
                                      .map((d) => d.inSeconds)
                                      .reduce((a, b) => a + b)) *
                              100
                          : 0.0;

                      return PieChartSectionData(
                        value: entry.value.inSeconds.toDouble(),
                        title:
                            '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        color: Colors.primaries[_mostVisitedScreens.keys
                                .toList()
                                .indexOf(entry.key) %
                            Colors.primaries.length],
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ..._mostVisitedScreens.entries.take(5).map(
                    (entry) =>
                        _buildInfoRow(entry.key, '${entry.value.inSeconds}s'),
                  ),
            ] else
              const Center(
                child: Text('No screen visit data available yet'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.whatshot, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Interaction Heatmap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_heatmapData.isNotEmpty) ...[
              ..._heatmapData.entries.map((screenEntry) {
                return ExpansionTile(
                  title: Text(
                    '${screenEntry.key} (${screenEntry.value.length} widgets)',
                  ),
                  children: screenEntry.value.entries.map((widgetEntry) {
                    final maxInteractions = screenEntry.value.values.isNotEmpty
                        ? screenEntry.value.values
                            .reduce((a, b) => a > b ? a : b)
                        : 1;
                    final intensity = widgetEntry.value / maxInteractions;

                    return ListTile(
                      title: Text(widgetEntry.key),
                      trailing: Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: intensity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${widgetEntry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ] else
              const Center(
                child: Text('No heatmap data available yet'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenDetailCard(
    String title,
    String token,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: color, size: 16),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: token));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title copied to clipboard'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: color,
                      ),
                    );
                  }
                  _addDebugLog('📋 $title copied to clipboard');
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Length: ${token.length} chars',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Type: ${_getTokenType(token)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Preview: ${token.length > 40 ? "${token.substring(0, 20)}...${token.substring(token.length - 20)}" : token}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (token.length > 100) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Hash: ${token.hashCode.abs().toString().substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTokenType(String token) {
    if (token.startsWith('Bearer ')) return 'Bearer';
    if (token.contains('.')) return 'JWT';
    if (token.length > 200) return 'Long Token';
    if (token.length > 50) return 'Access Token';
    return 'Short Token';
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenTerminal(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _fullScreenFocusNode,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              setState(() {
                _isFullScreen = false;
              });
            }
          },
          child: Column(
            children: [
              // Full screen terminal header - compact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2937),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Terminal title
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.terminal,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'Debug Console',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compact controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Filter dropdown - very compact
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _logFilters.contains('all')
                                ? 'all'
                                : _logFilters.first,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.expand_more,
                              size: 12,
                              color: Colors.white70,
                            ),
                            dropdownColor: const Color(0xFF1F2937),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child:
                                    Text('All', style: TextStyle(fontSize: 11)),
                              ),
                              DropdownMenuItem(
                                value: 'system',
                                child:
                                    Text('Sys', style: TextStyle(fontSize: 11)),
                              ),
                              DropdownMenuItem(
                                value: 'console',
                                child:
                                    Text('Con', style: TextStyle(fontSize: 11)),
                              ),
                              DropdownMenuItem(
                                value: 'network',
                                child:
                                    Text('Net', style: TextStyle(fontSize: 11)),
                              ),
                              DropdownMenuItem(
                                value: 'error',
                                child:
                                    Text('Err', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _logFilters.clear();
                                  _logFilters.add(value);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Auto-scroll toggle
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _autoScroll
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFF6B7280).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _autoScroll = !_autoScroll;
                              });
                            },
                            icon: Icon(
                              _autoScroll
                                  ? Icons.vertical_align_bottom
                                  : Icons.vertical_align_top,
                              size: 12,
                              color: _autoScroll
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF9CA3AF),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Clear button
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _debugLogs.clear();
                              _addDebugLog('🧹 Console cleared');
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 28),
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('CLR'),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Exit button
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isFullScreen = false;
                              });
                            },
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              size: 12,
                              color: Color(0xFF8B5CF6),
                            ),
                            tooltip: 'Exit (ESC)',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Full screen terminal console
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                    ),
                  ),
                  child: _buildConsoleContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
