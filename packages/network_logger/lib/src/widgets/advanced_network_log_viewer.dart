import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network_logger_service.dart';
import '../models/network_log_entry.dart';

/// Advanced Network Log Viewer - Detailed HTTP request/response viewer
class AdvancedNetworkLogViewer extends StatefulWidget {
  const AdvancedNetworkLogViewer({super.key});

  @override
  State<AdvancedNetworkLogViewer> createState() => _AdvancedNetworkLogViewerState();
}

class _AdvancedNetworkLogViewerState extends State<AdvancedNetworkLogViewer> {
  final NetworkLoggerService _networkLogger = NetworkLoggerService.instance;
  String _searchQuery = '';
  String _filterType = 'all'; // all, success, error, pending
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: _buildLogsList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.network_check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Network Logger',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'HTTP Monitor',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Status indicator - Responsive version
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _networkLogger.isEnabled
                ? const Color.fromARGB(51, 16, 185, 129)
                : const Color.fromARGB(51, 239, 68, 68),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _networkLogger.isEnabled
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _networkLogger.isEnabled ? Icons.circle : Icons.circle_outlined,
                color: _networkLogger.isEnabled
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                _networkLogger.isEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  color: _networkLogger.isEnabled
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search and filter row - Responsive version
          Column(
            children: [
              // Search field (full width)
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // Filter and clear buttons row
              Row(
                children: [
                  // Filter dropdown (compact)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButton<String>(
                        value: _filterType,
                        dropdownColor: const Color(0xFF1E293B),
                        underline: const SizedBox(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                              value: 'success', child: Text('Success')),
                          DropdownMenuItem(
                              value: 'error', child: Text('Error')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                        ],
                        onChanged: (value) =>
                            setState(() => _filterType = value ?? 'all'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Clear button (compact)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(51, 239, 68, 68),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _networkLogger.clearNetworkLogs();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear_all,
                          color: Color(0xFFEF4444), size: 20),
                      tooltip: 'Clear All Logs',
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row - Responsive with Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip('Total',
                  _networkLogger.networkLogsCount.toString(), Colors.blue),
              _buildStatChip(
                  'Success', _getSuccessCount().toString(), Colors.green),
              _buildStatChip('Error', _getErrorCount().toString(), Colors.red),
              _buildStatChip(
                  'Pending', _getPendingCount().toString(), Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final filteredLogs = _getFilteredLogs();

    if (!_networkLogger.isEnabled) {
      return _buildEmptyState(
        icon: Icons.wifi_off,
        title: 'Network Logging Disabled',
        subtitle:
            'Enable network logging from Developer Command Center to see HTTP requests here.',
      );
    }

    if (filteredLogs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No Network Logs',
        subtitle: _searchQuery.isNotEmpty
            ? 'No logs match your search query'
            : 'Make HTTP requests to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFF475569)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(NetworkLogEntry log) {
    final statusColor = _getStatusColor(log);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLogDetails(log),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Method badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMethodColor(log.method),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      log.method,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status text
                  if (log.hasError)
                    Text(
                      'ERROR',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  else if (log.statusCode != null)
                    Text(
                      '${log.statusCode}',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      'PENDING',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),

                  const Spacer(),

                  // Duration
                  Text(
                    log.formattedDuration,
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // URL
              Text(
                log.path,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Host
              Text(
                log.host,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Bottom row - sizes and timestamp
              Row(
                children: [
                  if (log.requestSize != null) ...[
                    Icon(Icons.arrow_upward,
                        size: 14, color: Colors.orange[400]),
                    const SizedBox(width: 4),
                    Text(
                      log.formattedRequestSize,
                      style: TextStyle(color: Colors.orange[400], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                  ],

                  if (log.responseSize != null) ...[
                    Icon(Icons.arrow_downward,
                        size: 14, color: Colors.green[400]),
                    const SizedBox(width: 4),
                    Text(
                      log.formattedResponseSize,
                      style: TextStyle(color: Colors.green[400], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                  ],

                  const Spacer(),

                  Text(
                    _formatTimestamp(log.timestamp),
                    style:
                        const TextStyle(color: Color(0xFF475569), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDetails(NetworkLogEntry log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NetworkLogDetailSheet(log: log),
    );
  }

  List<NetworkLogEntry> _getFilteredLogs() {
    var logs = _networkLogger.networkLogs;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      logs = logs.where((log) {
        return log.url.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.method.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (log.statusCode?.toString().contains(_searchQuery) ?? false) ||
            (log.host.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply type filter
    switch (_filterType) {
      case 'success':
        logs = logs
            .where((log) =>
                log.statusCode != null &&
                log.statusCode! >= 200 &&
                log.statusCode! < 300)
            .toList();
        break;
      case 'error':
        logs = logs
            .where((log) =>
                log.hasError ||
                (log.statusCode != null && log.statusCode! >= 400))
            .toList();
        break;
      case 'pending':
        logs = logs.where((log) => !log.isCompleted).toList();
        break;
    }

    return logs;
  }

  Color _getStatusColor(NetworkLogEntry log) {
    if (log.hasError) return Colors.red;
    if (log.statusCode == null) return Colors.orange;
    if (log.statusCode! >= 200 && log.statusCode! < 300) return Colors.green;
    if (log.statusCode! >= 300 && log.statusCode! < 400) return Colors.blue;
    if (log.statusCode! >= 400 && log.statusCode! < 500) return Colors.orange;
    return Colors.red;
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  int _getSuccessCount() {
    return _networkLogger.networkLogs
        .where((log) =>
            log.statusCode != null &&
            log.statusCode! >= 200 &&
            log.statusCode! < 300)
        .length;
  }

  int _getErrorCount() {
    return _networkLogger.networkLogs
        .where((log) =>
            log.hasError || (log.statusCode != null && log.statusCode! >= 400))
        .length;
  }

  int _getPendingCount() {
    return _networkLogger.networkLogs.where((log) => !log.isCompleted).length;
  }
}

/// Network Log Detail Sheet - Shows detailed request/response info
class NetworkLogDetailSheet extends StatelessWidget {
  final NetworkLogEntry log;

  const NetworkLogDetailSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getMethodColor(log.method),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                log.method,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.path,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    log.host,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // Tab bar
                      const TabBar(
                        labelColor: Color(0xFF06B6D4),
                        unselectedLabelColor: Color(0xFF64748B),
                        indicatorColor: Color(0xFF06B6D4),
                        tabs: [
                          Tab(text: 'Overview'),
                          Tab(text: 'Request'),
                          Tab(text: 'Response'),
                        ],
                      ),

                      // Tab views
                      Expanded(
                        child: Builder(
                          builder: (context) => TabBarView(
                            children: [
                              _buildOverviewTab(),
                              _buildRequestTab(context),
                              _buildResponseTab(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('URL', log.url),
          _buildDetailRow('Method', log.method),
          if (log.requestHeaders.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Request Headers',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...log.requestHeaders.entries.map(
              (entry) => _buildDetailRow(
                entry.key,
                entry.value.toString(),
                _isSensitiveHeader(entry.key) ? Colors.orange : null,
              ),
            ),
          ],
          if (log.statusCode != null)
            _buildDetailRow(
                'Status', '${log.statusCode} ${log.statusMessage ?? ''}'),
          if (log.hasError)
            _buildDetailRow('Error',
                '${log.errorType?.name ?? 'Unknown'}: ${log.errorMessage ?? 'No details'}'),
          _buildDetailRow('Duration', log.formattedDuration),
          _buildDetailRow('Timestamp', log.timestamp.toString()),
          if (log.requestSize != null)
            _buildDetailRow('Request Size', log.formattedRequestSize),
          if (log.responseSize != null)
            _buildDetailRow('Response Size', log.formattedResponseSize),
        ],
      ),
    );
  }

  Widget _buildRequestTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.queryParameters != null) ...[
            _buildSectionTitle('Query Parameters'),
            _buildJsonViewer(context, log.queryParameters!),
            const SizedBox(height: 20),
          ],
          _buildSectionTitle('Headers'),
          _buildJsonViewer(context, log.requestHeaders),
          if (log.requestBody != null) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Body'),
            _buildJsonViewer(context, log.requestBody),
            const SizedBox(height: 20),
          ],
          _buildCurlSection(context),
        ],
      ),
    );
  }

  Widget _buildResponseTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.responseHeaders != null) ...[
            _buildSectionTitle('Headers'),
            _buildJsonViewer(context, log.responseHeaders!),
            const SizedBox(height: 20),
          ],
          if (log.responseBody != null) ...[
            _buildSectionTitle('Body'),
            _buildJsonViewer(context, log.responseBody),
          ] else ...[
            const Center(
              child: Text(
                'No response data available',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: value)),
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight:
                      valueColor != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF06B6D4),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJsonViewer(BuildContext context, dynamic data,
      {bool showCopyButton = true}) {
    String formattedString;
    bool isJson = false;

    try {
      // Try to parse and pretty print JSON
      if (data is String) {
        final parsed = json.decode(data);
        formattedString = const JsonEncoder.withIndent('  ').convert(parsed);
        isJson = true;
      } else if (data is Map || data is List) {
        formattedString = const JsonEncoder.withIndent('  ').convert(data);
        isJson = true;
      } else {
        formattedString = data.toString();
      }
    } catch (e) {
      // If not JSON, just convert to string
      formattedString = data.toString();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with data type indicator and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isJson
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isJson ? 'JSON' : 'TEXT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${formattedString.length} characters',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (showCopyButton)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: formattedString));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('Copied to clipboard'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.copy,
                        color: Color(0xFF94A3B8),
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                formattedString,
                style: TextStyle(
                  color: const Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                  // JSON syntax highlighting colors
                  shadows: isJson
                      ? [
                          const Shadow(
                            color: Color(0xFF10B981),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurlSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('cURL Command'),
        _buildJsonViewer(context, log.curlCommand),
      ],
    );
  }

  bool _isSensitiveHeader(String headerName) {
    final sensitive = [
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'x-auth-token'
    ];
    return sensitive.any((s) => headerName.toLowerCase().contains(s));
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}