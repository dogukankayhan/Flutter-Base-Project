/* import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager.dart';
import 'package:flutter_base_kit/core/networking/core/network/client/http_client_interface.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_exception.dart';
import 'package:flutter_base_kit/core/networking/core/network/serializer/serializer_interface.dart';

@GenerateMocks([HttpClient, Serializer, Dio])
import 'api_manager_test.mocks.dart';

void main() {
  late DioApiManager apiManager;
  late MockHttpClient mockHttpClient;
  late MockSerializer mockSerializer;
  late MockDio mockDio;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockSerializer = MockSerializer();
    mockDio = MockDio();
    
    when(mockHttpClient.dio).thenReturn(mockDio);
    
    apiManager = DioApiManager(
      client: mockHttpClient,
      serializer: mockSerializer,
    );
  });

  group('DioApiManager GET Tests', () {
    test('should successfully make GET request and return data', () async {
      // Arrange
      const path = '/test';
      final mockResponseData = {'key': 'value'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({'content-type': ['application/json']}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(path: path);

      // Assert
      expect(result.data, mockResponseData);
      expect(result.statusCode, 200);
      verify(mockDio.request<Object>(
        path,
        data: null,
        queryParameters: null,
        options: any,
        cancelToken: null,
      )).called(1);
    });

    test('should handle GET request with query parameters', () async {
      // Arrange
      const path = '/test';
      final query = {'param': 'value'};
      final mockResponseData = {'result': 'success'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(
        path: path,
        query: query,
      );

      // Assert
      expect(result.data, mockResponseData);
      verify(mockDio.request<Object>(
        path,
        data: null,
        queryParameters: query,
        options: any,
        cancelToken: null,
      )).called(1);
    });

    test('should throw ApiException on DioException', () async {
      // Arrange
      const path = '/test';
      final dioException = DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionTimeout,
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(dioException);

      // Act & Assert
      expect(
        () => apiManager.get<Map<String, dynamic>>(path: path),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('DioApiManager POST Tests', () {
    test('should successfully make POST request with body', () async {
      // Arrange
      const path = '/test';
      final body = {'name': 'test'};
      final mockResponseData = {'id': '123'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 201,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.post<Map<String, dynamic>>(
        path: path,
        body: body,
      );

      // Assert
      expect(result.data, mockResponseData);
      expect(result.statusCode, 201);
      verify(mockDio.request<Object>(
        path,
        data: body,
        queryParameters: null,
        options: any,
        cancelToken: null,
      )).called(1);
    });

    test('should handle POST request with custom headers', () async {
      // Arrange
      const path = '/test';
      final body = {'data': 'test'};
      final headers = {'Authorization': 'Bearer token'};
      final mockResponseData = {'success': true};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.post<Map<String, dynamic>>(
        path: path,
        body: body,
        headers: headers,
      );

      // Assert
      expect(result.data, mockResponseData);
      verify(mockDio.request<Object>(
        path,
        data: body,
        queryParameters: null,
        options: argThat(
          isA<Options>().having((o) => o.headers, 'headers', headers),
          named: 'options',
        ),
        cancelToken: null,
      )).called(1);
    });
  });

  group('DioApiManager PUT Tests', () {
    test('should successfully make PUT request', () async {
      // Arrange
      const path = '/test/123';
      final body = {'name': 'updated'};
      final mockResponseData = {'id': '123', 'name': 'updated'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.put<Map<String, dynamic>>(
        path: path,
        body: body,
      );

      // Assert
      expect(result.data, mockResponseData);
      expect(result.statusCode, 200);
    });
  });

  group('DioApiManager PATCH Tests', () {
    test('should successfully make PATCH request', () async {
      // Arrange
      const path = '/test/123';
      final body = {'status': 'active'};
      final mockResponseData = {'id': '123', 'status': 'active'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.patch<Map<String, dynamic>>(
        path: path,
        body: body,
      );

      // Assert
      expect(result.data, mockResponseData);
      expect(result.statusCode, 200);
    });
  });

  group('DioApiManager DELETE Tests', () {
    test('should successfully make DELETE request', () async {
      // Arrange
      const path = '/test/123';
      final mockResponse = Response<Object>(
        data: null,
        statusCode: 204,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.delete<void>(path: path);

      // Assert
      expect(result.statusCode, 204);
    });
  });

  group('DioApiManager with Serializer Tests', () {
    test('should use serializer when fromJson is provided', () async {
      // Arrange
      const path = '/test';
      final mockResponseData = {'name': 'test'};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      when(mockSerializer.decode<String>(any, any)).thenReturn('decoded');

      // Act
      final result = await apiManager.get<String>(
        path: path,
        fromJson: (json) => json.toString(),
      );

      // Assert
      expect(result.data, 'decoded');
      verify(mockSerializer.decode<String>(mockResponseData, any)).called(1);
    });

    test('should use extractor when provided', () async {
      // Arrange
      const path = '/test';
      final mockResponseData = {'nested': {'value': 'test'}};
      final mockResponse = Response<Object>(
        data: mockResponseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<String>(
        path: path,
        extractor: (data) {
          final map = data as Map<String, dynamic>;
          return (map['nested'] as Map<String, dynamic>)['value'] as String;
        },
      );

      // Assert
      expect(result.data, 'test');
      verifyNever(mockSerializer.decode<String>(any, any));
    });
  });

  group('DioApiManager CancelToken Tests', () {
    test('should pass cancelToken to Dio request', () async {
      // Arrange
      const path = '/test';
      final cancelToken = CancelToken();
      final mockResponse = Response<Object>(
        data: {},
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
        headers: Headers.fromMap({}),
      );

      when(mockDio.request<Object>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await apiManager.get<Map<String, dynamic>>(
        path: path,
        cancelToken: cancelToken,
      );

      // Assert
      verify(mockDio.request<Object>(
        path,
        data: null,
        queryParameters: null,
        options: any,
        cancelToken: cancelToken,
      )).called(1);
    });
  });
}
 */
