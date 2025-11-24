import 'package:flutter/material.dart';
import 'package:network_logger/network_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Logger Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) {
          // Initialize NetworkLogger
          NetworkLogger.initialize(context);
          
          return const MyHomePage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String _response = '';

  Future<void> _makeTestRequest() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      // Create Dio instance with NetworkLogger
      final dio = NetworkLogger.createDio();
      
      // Make a test request
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      
      setState(() {
        _response = 'Success! Check the network logger button for details.';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Logger Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => NetworkLogger.showLogs(context),
            tooltip: 'Show Logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              NetworkLogger.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared')),
              );
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Network Logger is ${NetworkLogger.logsCount > 0 ? "active" : "ready"}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                'Logs count: ${NetworkLogger.logsCount}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _makeTestRequest,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Loading...' : 'Make Test Request'),
              ),
              const SizedBox(height: 20),
              if (_response.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _response,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 40),
              const Text(
                'Look for the floating button to access network logs!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}