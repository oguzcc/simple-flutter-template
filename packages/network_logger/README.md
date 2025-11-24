# Network Logger

A Flutter package for logging and inspecting HTTP network requests with Dio interceptor support.

## Features

- 🔍 Automatic HTTP request/response logging
- 📊 Visual network log viewer
- 🎯 Dio interceptor integration
- 🎨 Floating overlay button for easy access
- 🔒 Sensitive header filtering
- 📱 Draggable floating button
- 🧹 Clear logs functionality
- 📦 Lightweight and easy to use

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  network_logger:
    path: packages/network_logger  # For local package
    # Or from pub.dev when published:
    # network_logger: ^1.0.0
```

## Quick Start

### 1. Initialize in your app

```dart
import 'package:network_logger/network_logger.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize NetworkLogger
    NetworkLogger.initialize(context);
    
    return MaterialApp(
      // Your app
    );
  }
}
```

### 2. Create Dio instances with NetworkLogger

```dart
// Option 1: Create new Dio with NetworkLogger
final dio = NetworkLogger.createDio(
  baseUrl: 'https://api.example.com',
);

// Option 2: Attach to existing Dio
final existingDio = Dio();
NetworkLogger.attachTo(existingDio);
```

### 3. That's it! 🎉

All HTTP requests will now be logged and accessible via the floating button.

## Advanced Usage

### Custom Interceptors

```dart
final dio = NetworkLogger.createDio(
  baseUrl: 'https://api.example.com',
  interceptors: [
    // Your custom interceptors
    AuthInterceptor(),
    ErrorInterceptor(),
    // NetworkLogger interceptor is added automatically at the end
  ],
);
```

### Show Logs Programmatically

```dart
// Show network logs viewer
NetworkLogger.showLogs(context);

// Get logs count
final count = NetworkLogger.logsCount;

// Clear all logs
NetworkLogger.clearLogs();

// Enable/disable logging
NetworkLogger.enable();
NetworkLogger.disable();
```

### Access Raw Logs

```dart
// Get all network logs
final logs = NetworkLogger.logs;

// Process logs
for (final log in logs) {
  print('${log.method} ${log.url} - ${log.statusCode}');
}
```

## Widget Integration

### Using the Overlay Button

The package includes a draggable floating button that appears when initialized:

```dart
NetworkLoggerOverlayButton()
```

### Custom Log Viewer

You can create your own log viewer using the `NetworkLogViewer` widget:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NetworkLogViewer(),
  ),
);
```

## Log Entry Model

Each network request is captured as a `NetworkLogEntry` with:

- Request details (method, URL, headers, body)
- Response details (status, headers, body)
- Timing information
- Error details
- Size calculations

## Configuration

### Sensitive Headers

The following headers are automatically filtered:
- authorization
- cookie
- set-cookie
- x-api-key
- x-auth-token

### Log Limits

By default, the logger keeps the last 100 requests. This can be configured in the service.

## Example

```dart
import 'package:flutter/material.dart';
import 'package:network_logger/network_logger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // Initialize NetworkLogger
          NetworkLogger.initialize(context);
          
          return MyHomePage();
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Network Logger Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Create Dio with NetworkLogger
            final dio = NetworkLogger.createDio();
            
            // Make a test request
            await dio.get('https://jsonplaceholder.typicode.com/posts/1');
            
            // Show logs
            NetworkLogger.showLogs(context);
          },
          child: Text('Make Test Request'),
        ),
      ),
    );
  }
}
```

## License

MIT License - See LICENSE file for details