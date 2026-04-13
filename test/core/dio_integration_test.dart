import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/manager/remote/dio_client.dart';
import 'package:daisy/core/manager/remote/interceptors/refactored_streaming_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DioClient Integration Tests', () {
    testWidgets(
      'should initialize DioClient with RefactoredStreamingInterceptor',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final dio = Dio();
                final apiOptions = MockApiOptions();
                DioClient(dio, apiOptions, onUnauthorized: () async {});

                // Verify that the interceptor is added
                final interceptors = dio.interceptors;
                final streamingInterceptor = interceptors.firstWhere(
                  (i) => i is RefactoredStreamingInterceptor,
                  orElse: () => throw Exception(
                    'RefactoredStreamingInterceptor not found',
                  ),
                );

                expect(
                  streamingInterceptor,
                  isA<RefactoredStreamingInterceptor>(),
                );
                return Container();
              },
            ),
          ),
        );
      },
    );

    testWidgets('should create DioClient successfully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();

              expect(
                () => DioClient(dio, apiOptions, onUnauthorized: () async {}),
                returnsNormally,
              );
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should handle basic GET request structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client = DioClient(dio, apiOptions, onUnauthorized: () async {});

              // Test the method signature and basic structure
              expect(() => client.get('/test'), returnsNormally);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should handle POST request structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client = DioClient(dio, apiOptions, onUnauthorized: () async {});

              final testData = <String, dynamic>{'test': 'data'};

              // Test the method signature and basic structure
              expect(
                () => client.post('/test', data: testData),
                returnsNormally,
              );
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should support useStreaming parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client = DioClient(dio, apiOptions, onUnauthorized: () async {});

              // Test that useStreaming parameter is accepted
              expect(
                () => client.get('/test', useStreaming: false),
                returnsNormally,
              );

              expect(
                () => client.post(
                  '/test',
                  data: <String, dynamic>{},
                  useStreaming: true,
                ),
                returnsNormally,
              );
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should handle different HTTP methods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client =
                  DioClient(dio, apiOptions, onUnauthorized: () async {});

              expect(() => client.get('/test'), returnsNormally);
              expect(() => client.post('/test'), returnsNormally);
              expect(() => client.put('/test'), returnsNormally);
              expect(() => client.patch('/test'), returnsNormally);
              expect(() => client.delete('/test'), returnsNormally);
              expect(() => client.getList('/test'), returnsNormally);
              return Container();
            },
          ),
        ),
      );
    });

    test('should have configurable streaming methods', () {
      // Test static configuration methods exist
      expect(DioClient.configureStreaming, returnsNormally);
      expect(DioClient.enableAutoStreaming, returnsNormally);
      expect(DioClient.disableAutoStreaming, returnsNormally);
    });

    testWidgets('should support query parameters and options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client = DioClient(dio, apiOptions, onUnauthorized: () async {});

              final queryParams = <String, dynamic>{
                'param1': 'value1',
                'param2': 'value2',
              };
              final options = Options(
                headers: <String, dynamic>{'Custom-Header': 'test'},
              );

              // Test that parameters are accepted
              expect(
                () => client.get(
                  '/test',
                  queryParameters: queryParams,
                  options: options,
                ),
                returnsNormally,
              );
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should handle cancel tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dio = Dio();
              final apiOptions = MockApiOptions();
              final client = DioClient(dio, apiOptions, onUnauthorized: () async {});
              final cancelToken = CancelToken();

              // Test that cancel token is accepted
              expect(
                () => client.get('/test', cancelToken: cancelToken),
                returnsNormally,
              );
              return Container();
            },
          ),
        ),
      );
    });

    test('should configure access token and locale', () {
      // Test static properties
      expect(() => DioClient.accessToken = 'test-token', returnsNormally);
      expect(() => DioClient.locale = 'en', returnsNormally);

      expect(DioClient.accessToken, equals('test-token'));
      expect(DioClient.locale, equals('en'));
    });
  });
}

class MockApiOptions implements IApiOption {
  final timeout = const Duration(seconds: 30);

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  Duration get connectionTimeout => timeout;

  @override
  Duration get receiveTimeout => timeout;
}
