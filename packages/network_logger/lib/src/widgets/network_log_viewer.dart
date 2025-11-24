import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network_logger_service.dart';
import '../models/network_log_entry.dart';

/// Network Log Viewer - UI for displaying network logs
class NetworkLogViewer extends StatefulWidget {
  const NetworkLogViewer({super.key});

  @override
  State<NetworkLogViewer> createState() => _NetworkLogViewerState();
}

class _NetworkLogViewerState extends State<NetworkLogViewer> {
  @override
  Widget build(BuildContext context) {
    final logs = NetworkLoggerService.instance.networkLogs;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                NetworkLoggerService.instance.clearNetworkLogs();
              });
            },
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                'No network logs yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                // Show newest first (reverse the list display)
                final log = logs[logs.length - 1 - index];
                return _buildLogItem(log);
              },
            ),
    );
  }
  
  Widget _buildLogItem(NetworkLogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          '${log.method} ${log.path}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(log),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Host: ${log.host} • ${log.formattedDuration}',
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildStatusChip(log),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('URL', log.url),
                  if (log.requestHeaders.isNotEmpty)
                    _buildHeadersSection('Request Headers', log.requestHeaders),
                  if (log.queryParameters != null)
                    _buildSection('Query Parameters', log.queryParameters.toString()),
                  if (log.requestBody != null)
                    _buildSection('Request Body', log.requestBody.toString()),
                  if (log.responseBody != null)
                    _buildSection('Response Body', log.responseBody.toString()),
                  if (log.errorMessage != null)
                    _buildSection('Error', log.errorMessage!, Colors.red),
                  _buildSection('Request Size', log.formattedRequestSize),
                  _buildSection('Response Size', log.formattedResponseSize),
                  _buildCurlSection(log),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, String content, [Color? color]) {
    String formattedContent;
    bool isJson = false;
    
    try {
      // Try to parse and pretty print JSON
      final parsed = json.decode(content);
      formattedContent = const JsonEncoder.withIndent('  ').convert(parsed);
      isJson = true;
    } catch (e) {
      // If not JSON, just use original content
      formattedContent = content.length > 1000 
          ? '${content.substring(0, 1000)}...' 
          : content;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color ?? Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              if (isJson)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'JSON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: formattedContent));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(51, 158, 158, 158),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.copy,
                    size: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                formattedContent,
                style: TextStyle(
                  fontSize: 11,
                  color: color ?? Colors.black87,
                  fontFamily: 'monospace',
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadersSection(String title, Map<String, dynamic> headers) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: headers.entries.map((entry) {
                final isSensitive = _isSensitiveHeader(entry.key);
                final value = entry.value.toString();
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${entry.key}:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSensitive ? Colors.orange[700] : Colors.blue[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: entry.value.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSensitive ? Colors.orange[600] : Colors.black87,
                              fontFamily: 'monospace',
                              fontWeight: isSensitive ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSensitiveHeader(String headerName) {
    final sensitive = ['authorization', 'cookie', 'set-cookie', 'x-api-key', 'x-auth-token'];
    return sensitive.any((s) => headerName.toLowerCase().contains(s));
  }
  
  Widget _buildCurlSection(NetworkLogEntry log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'cURL Command',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: log.curlCommand));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('cURL command copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                log.curlCommand,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NetworkLogEntry log) {
    String label;
    Color color;
    
    if (log.hasError) {
      label = 'Error';
      color = Colors.red;
    } else if (log.statusCode != null) {
      label = log.statusCode.toString();
      color = _getStatusColor(log);
    } else {
      label = 'Pending';
      color = Colors.orange;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.all(4),
    );
  }
  
  Color _getStatusColor(NetworkLogEntry log) {
    if (log.hasError) return Colors.red;
    if (log.statusCode == null) return Colors.orange;
    if (log.statusCode! >= 200 && log.statusCode! < 300) return Colors.green;
    if (log.statusCode! >= 300 && log.statusCode! < 400) return Colors.blue;
    if (log.statusCode! >= 400 && log.statusCode! < 500) return Colors.orange;
    return Colors.red;
  }
}