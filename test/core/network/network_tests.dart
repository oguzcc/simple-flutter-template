import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/manager/remote/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {
  @override
  BaseOptions options = BaseOptions();
}

class MockApiOptions extends Mock implements IApiOption {}

void main() {
  late DioClient dioClient;
  late MockDio mockDio;
  late MockApiOptions mockApiOptions;

  setUp(() {
    mockDio = MockDio();
    mockApiOptions = MockApiOptions();

    when(() => mockApiOptions.baseUrl).thenReturn('https://api.example.com');
    when(() => mockApiOptions.connectionTimeout)
        .thenReturn(const Duration(seconds: 30));
    when(() => mockApiOptions.receiveTimeout)
        .thenReturn(const Duration(seconds: 30));
    when(() => mockDio.interceptors).thenReturn(Interceptors());

    dioClient = DioClient(mockDio, mockApiOptions, onUnauthorized: () async {});
  });

  group('DioClient Tests', () {
    test('GET request success test', () async {
      final mockResponse = Response(
        data: {'message': 'Success'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dioClient.get('/test');

      expect(result.statusCode, 200);
      expect(result.data, {'message': 'Success'});
      verify(() => mockDio.get<Map<String, dynamic>>('/test')).called(1);
    });

    test('POST request success test', () async {
      final requestData = {'key': 'value'};
      final mockResponse = Response(
        data: {'message': 'Created'},
        statusCode: 201,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dioClient.post('/test', data: requestData);

      expect(result.statusCode, 201);
      expect(result.data, {'message': 'Created'});
      verify(
        () => mockDio.post<Map<String, dynamic>>('/test', data: requestData),
      ).called(1);
    });

    test('PUT request success test', () async {
      final requestData = {'key': 'updated_value'};
      final mockResponse = Response(
        data: {'message': 'Updated'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test/1'),
      );

      when(
        () => mockDio.put<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dioClient.put('/test/1', data: requestData);

      expect(result.statusCode, 200);
      expect(result.data, {'message': 'Updated'});
      verify(
        () => mockDio.put<Map<String, dynamic>>('/test/1', data: requestData),
      ).called(1);
    });

    test('DELETE request success test', () async {
      final mockResponse = Response(
        data: {'message': 'Deleted'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test/1'),
      );

      when(
        () => mockDio.delete<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dioClient.delete('/test/1');

      expect(result.statusCode, 200);
      expect(result.data, {'message': 'Deleted'});
      verify(() => mockDio.delete<Map<String, dynamic>>('/test/1')).called(1);
    });

    test('PATCH request success test', () async {
      final requestData = {'key': 'patched_value'};
      final mockResponse = Response(
        data: {'message': 'Patched'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test/1'),
      );

      when(
        () => mockDio.patch<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await dioClient.patch('/test/1', data: requestData);

      expect(result.statusCode, 200);
      expect(result.data, {'message': 'Patched'});
      verify(
        () => mockDio.patch<Map<String, dynamic>>('/test/1', data: requestData),
      ).called(1);
    });

    //* MARK: Hata testleri
    group('Error Tests', () {
      test('GET request error test', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/test'),
            ),
          ),
        );

        expect(() => dioClient.get('/test'), throwsA(isA<DioException>()));
      });

      test('PUT request error test', () async {
        when(
          () => mockDio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test/1'),
            response: Response(
              statusCode: 400,
              requestOptions: RequestOptions(path: '/test/1'),
            ),
          ),
        );

        expect(
          () => dioClient.put('/test/1', data: {'key': 'value'}),
          throwsA(isA<DioException>()),
        );
      });

      test('DELETE request error test', () async {
        when(
          () => mockDio.delete<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test/1'),
            response: Response(
              statusCode: 403,
              requestOptions: RequestOptions(path: '/test/1'),
            ),
          ),
        );

        expect(() => dioClient.delete('/test/1'), throwsA(isA<DioException>()));
      });

      test('PATCH request error test', () async {
        when(
          () => mockDio.patch<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test/1'),
            response: Response(
              statusCode: 422,
              requestOptions: RequestOptions(path: '/test/1'),
            ),
          ),
        );

        expect(
          () => dioClient.patch('/test/1', data: {'key': 'value'}),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
