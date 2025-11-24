import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_logger/network_logger.dart';

class DeveloperCommandCenter extends StatefulWidget {
  const DeveloperCommandCenter({super.key});

  @override
  State<DeveloperCommandCenter> createState() => _DeveloperCommandCenterState();
}

class _DeveloperCommandCenterState extends State<DeveloperCommandCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _mostTappedWidgets = {};
  Map<String, Duration> _mostVisitedScreens = {};

  String _firebaseProjectId = 'Unknown';
  String _appVersion = 'Unknown';
  String _bundleId = 'Unknown';
  final List<String> _debugLogs = [];

  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();
  StreamSubscription<String>? _logSubscription;

  DebugPrintCallback? _originalDebugPrint;

  final Set<String> _logFilters = {'all'};
  final bool _isFullScreen = false;
  final FocusNode _fullScreenFocusNode = FocusNode();

  bool _showOverlayButton = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _logSubscription = _logStreamController.stream.listen((logMessage) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final logEntry = '[$timestamp] $logMessage';
      _debugLogs.insert(0, logEntry);
      if (_debugLogs.length > 100) {
        _debugLogs.removeLast();
      }

      if (mounted) {
        setState(() {});
      }
    });

    _setupConsoleCapture();
    _loadAnalyticsData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logStreamController.add('🚀 Developer Command Center initialized');
      _logStreamController.add('📺 Console log capture enabled');

      debugPrint('Test console log from Developer Command Center');
      developer.log('Test developer.log message',
          name: 'DeveloperCommandCenter');

      _logStreamController
          .add('❌ Demo error log for testing filter functionality');
      _logStreamController
          .add('⚠️ Demo warning log for testing filter functionality');

      if (_isFullScreen) {
        _fullScreenFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _logStreamController.close();
    _tabController.dispose();
    _fullScreenFocusNode.dispose();
    _restoreConsoleCapture();
    _hideFloatingOverlay();
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
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const AdvancedNetworkLogViewer(),
                  ),
                );
              },
              child: const Icon(
                Icons.network_check,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setupConsoleCapture() {
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        _logStreamController.add('🖥️ $message');
      }
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };

    developer.log('Console capture initialized for Debug Console',
        name: 'DeveloperCommandCenter');
  }

  void _restoreConsoleCapture() {
    if (_originalDebugPrint != null) {
      debugPrint = _originalDebugPrint!;
    }
  }

  void _loadAnalyticsData() {
    _mostTappedWidgets = {
      'LoginButton': 156,
      'ProfileImage': 89,
      'NavigationDrawer': 67,
      'SearchBar': 45,
      'LogoutButton': 23,
    };

    _mostVisitedScreens = {
      'Home': const Duration(minutes: 45),
      'Profile': const Duration(minutes: 23),
      'Settings': const Duration(minutes: 12),
      'About': const Duration(minutes: 8),
    };
  }

  Widget _buildLogFilterButtons() {
    final filters = ['all', 'system', 'console', 'network', 'error'];
    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = _logFilters.contains(filter);
        return FilterChip(
          label: Text(filter, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (filter == 'all') {
                if (selected) {
                  _logFilters
                    ..clear()
                    ..add('all');
                } else {
                  _logFilters.remove('all');
                }
              } else {
                _logFilters.remove('all');
                if (selected) {
                  _logFilters.add(filter);
                } else {
                  _logFilters.remove(filter);
                }
                if (_logFilters.isEmpty) {
                  _logFilters.add('all');
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  List<String> _getFilteredLogs() {
    if (_logFilters.contains('all')) {
      return _debugLogs;
    }

    return _debugLogs.where((log) {
      final isSystemLog = log.contains('🖥️') || log.contains('🚀');
      final isConsoleLog = log.contains('🖥️');
      final isNetworkLog = log.contains('🌐');
      final isErrorLog = log.contains('❌');

      return (_logFilters.contains('system') && isSystemLog) ||
          (_logFilters.contains('console') && isConsoleLog) ||
          (_logFilters.contains('network') && isNetworkLog) ||
          (_logFilters.contains('error') && isErrorLog);
    }).toList();
  }

  Widget _buildConsoleContent() {
    final filteredLogs = _getFilteredLogs();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildLogFilterButtons(),
            ],
          ),
        ),
        const Divider(height: 1),
        
        Expanded(
          child: filteredLogs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bug_report, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Console ready - No logs yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Debug messages and console.log() will appear here',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return _buildLogItem(log);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogItem(String log) {
    Color logColor = const Color(0xFF94A3B8);
    IconData logIcon = Icons.info_outline;

    final isSystemLog = log.contains('🚀') || log.contains('📺');
    final isConsoleLog = log.contains('🖥️');
    final isNetworkLog = log.contains('🌐');
    final isErrorLog = log.contains('❌');
    final isWarningLog = log.contains('⚠️');

    if (isErrorLog) {
      logColor = const Color(0xFFEF4444);
      logIcon = Icons.error_outline;
    } else if (isWarningLog) {
      logColor = const Color(0xFFF59E0B);
      logIcon = Icons.warning_outlined;
    } else if (isSystemLog) {
      logColor = const Color(0xFF10B981);
      logIcon = Icons.settings_outlined;
    } else if (isConsoleLog) {
      logColor = const Color(0xFF60A5FA);
      logIcon = Icons.terminal;
    } else if (isNetworkLog) {
      logColor = const Color(0xFF8B5CF6);
      logIcon = Icons.wifi;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(logIcon, size: 16, color: logColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log,
              style: TextStyle(
                color: logColor,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('App Information', [
            'Version: $_appVersion',
            'Bundle ID: $_bundleId',
            'Platform: ${Platform.operatingSystem}',
            'Debug Mode: ${kDebugMode ? 'Enabled' : 'Disabled'}',
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Firebase', [
            'Project ID: $_firebaseProjectId',
            'Core Initialized: ${Firebase.apps.isNotEmpty ? 'Yes' : 'No'}',
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Network Logger', [
            'Status: Enabled',
            'Logs Count: 0',
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMostTappedWidgetsChart(),
          const SizedBox(height: 24),
          _buildMostVisitedScreensChart(),
        ],
      ),
    );
  }

  Widget _buildMostTappedWidgetsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Tapped Widgets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _mostTappedWidgets.values.isNotEmpty
                      ? _mostTappedWidgets.values
                          .reduce((a, b) => a > b ? a : b).toDouble() * 1.2
                      : 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && 
                              index < _mostTappedWidgets.keys.length) {
                            return Text(
                              _mostTappedWidgets.keys.elementAt(index),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(),
                    ),
                  ),
                  borderData: FlBorderData(),
                  barGroups: _mostTappedWidgets.entries.map((entry) {
                    final index = _mostTappedWidgets.keys.toList()
                        .indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostVisitedScreensChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Visited Screens (Time Spent)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: _mostVisitedScreens.entries.map((entry) {
                    final index = _mostVisitedScreens.keys.toList()
                        .indexOf(entry.key);
                    const colors = [
                        Colors.blue, Colors.green, Colors.orange, Colors.red];
                    
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: entry.value.inMinutes.toDouble(),
                      title: '${entry.key}\n${entry.value.inMinutes}m',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Network Monitoring',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AdvancedNetworkLogViewer(),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Full View'),
              ),
            ],
          ),
        ),
        const Expanded(
          child: AdvancedNetworkLogViewer(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Developer Command Center'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _debugLogs.clear();
              });
              _addDebugLog('🧹 Console cleared');
            },
          ),
          IconButton(
            icon: Icon(_showOverlayButton 
                ? Icons.close : Icons.picture_in_picture),
            onPressed: () {
              setState(() {
                _showOverlayButton = !_showOverlayButton;
              });
              if (_showOverlayButton) {
                _enableFloatingOverlay();
              } else {
                _hideFloatingOverlay();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.terminal), text: 'Console'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.network_check), text: 'Network'),
            Tab(icon: Icon(Icons.info), text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsoleContent(),
          _buildAnalyticsTab(),
          _buildNetworkTab(),
          _buildSystemInfoTab(),
        ],
      ),
    );
  }

  void _addDebugLog(String message) {
    _logStreamController.add(message);
  }
}
