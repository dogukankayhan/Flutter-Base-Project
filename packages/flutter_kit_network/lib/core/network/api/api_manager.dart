import 'dart:io';
import 'package:dio/dio.dart';
import 'api_manager_interface.dart';
import '../client/http_client_interface.dart';
import '../error/error_mapper.dart';
import '../error/api_exception.dart';
import '../serializer/serializer_interface.dart';
import '../queue/request_queue.dart';
import '../analytics/analytics_manager.dart';
import 'api_response.dart';

/// Enhanced API Manager with smart parsing and advanced features
class DioApiManager implements ApiManager {
  final HttpClient client;
  final Serializer serializer;
  final RequestQueue? requestQueue;
  final AnalyticsManager? analyticsManager;

  DioApiManager({
    required this.client,
    required this.serializer,
    this.requestQueue,
    this.analyticsManager,
  });

  /// Main request handler with smart parsing and analytics
  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final startTime = DateTime.now();

    try {
      // Track request start
      analyticsManager?.trackRequestStart(path, method);

      // Execute request (with queue if available)
      final response = requestQueue != null
          ? await requestQueue!.enqueue(
              () => _executeRequest(
                method: method,
                path: path,
                body: body,
                query: query,
                headers: headers,
                cancelToken: cancelToken,
              ),
              priority: priority,
            )
          : await _executeRequest(
              method: method,
              path: path,
              body: body,
              query: query,
              headers: headers,
              cancelToken: cancelToken,
            );

      // Parse response data
      final T data = _parseResponseData<T>(
        response.data,
        fromJson: fromJson,
        extractor: extractor,
        listWrapperKey: listWrapperKey,
      );

      final apiResponse = ApiResponse<T>(
        data: data,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        requestUri: response.requestOptions.uri.toString(),
        raw: response.data,
      );

      // Track success
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestSuccess(path, method, duration);

      return apiResponse;
    } on DioException catch (e) {
      // Track failure
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestFailure(path, method, duration, e);

      throw ApiException(ErrorMapper.fromDio(e));
    } catch (e) {
      // Track unexpected error
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestError(path, method, duration, e);

      rethrow;
    }
  }

  /// Execute HTTP request
  Future<Response<Object>> _executeRequest({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return await client.dio.request<Object>(
      path,
      data: body,
      queryParameters: query,
      options: Options(method: method, headers: headers),
      cancelToken: cancelToken,
    );
  }

  /// Smart response data parser
  ///
  /// Automatically handles:
  /// - Single models
  /// - Lists of models
  /// - Wrapped lists (with auto-detection)
  /// - Custom extraction
  T _parseResponseData<T>(
    Object? responseData, {
    FromJson<dynamic>? fromJson,
    T Function(Object?)? extractor,
    String? listWrapperKey,
  }) {
    // Priority 1: Custom extractor
    if (extractor != null) {
      return extractor(responseData);
    }

    // Priority 2: No parsing needed
    if (fromJson == null) {
      return responseData as T;
    }

    // Priority 3: Smart parsing based on type
    final typeString = T.toString();
    final isListType = typeString.startsWith('List<');

    if (isListType) {
      return _parseListResponse<T>(
        responseData,
        fromJson,
        listWrapperKey: listWrapperKey,
      );
    } else {
      return _parseSingleResponse<T>(responseData, fromJson);
    }
  }

  /// Parse single model response
  T _parseSingleResponse<T>(Object? responseData, FromJson<dynamic> fromJson) {
    if (responseData is! Map<String, dynamic>) {
      throw ApiException.parse(
        'Expected Map<String, dynamic> for single model, got ${responseData.runtimeType}',
      );
    }

    // Cast FromJson<dynamic> to FromJson<T>
    return serializer.decode<T>(responseData, fromJson as FromJson<T>);
  }

  /// Parse list response with smart wrapper detection
  ///
  /// Supports:
  /// - Direct arrays: [item1, item2, ...]
  /// - Wrapped arrays: { results: [item1, item2, ...] }
  /// - Pagination wrappers: { data: [...], meta: {...} }
  T _parseListResponse<T>(
    Object? responseData,
    FromJson<dynamic> fromJson, {
    String? listWrapperKey,
  }) {
    List<dynamic> listData;

    if (responseData is Map<String, dynamic>) {
      // Try explicit wrapper key first
      if (listWrapperKey != null) {
        if (!responseData.containsKey(listWrapperKey)) {
          throw ApiException.parse(
            'Wrapper key "$listWrapperKey" not found in response. '
            'Available keys: ${responseData.keys.join(", ")}',
          );
        }

        final wrapped = responseData[listWrapperKey];
        if (wrapped is! List) {
          throw ApiException.parse(
            'Expected List at key "$listWrapperKey", got ${wrapped.runtimeType}',
          );
        }

        listData = wrapped;
      } else {
        // Auto-detect wrapper key
        final detectedKey = _detectListWrapperKey(responseData);

        if (detectedKey != null) {
          listData = responseData[detectedKey] as List;
        } else {
          throw ApiException.parse(
            'Could not detect list wrapper key in response. '
            'Available keys: ${responseData.keys.join(", ")}. '
            'Please provide listWrapperKey explicitly.',
          );
        }
      }
    } else if (responseData is List) {
      // Direct array response
      listData = responseData;
    } else {
      throw ApiException.parse(
        'Expected List or Map with list wrapper, got ${responseData.runtimeType}',
      );
    }

    // Parse list items – map individually to preserve concrete type
    final parsedList = listData
        .map((e) => fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return parsedList as T;
  }

  /// Auto-detect common list wrapper keys
  ///
  /// Checks in priority order:
  /// 1. 'data' - Most common in REST APIs
  /// 2. 'results' - Django, PokeAPI style
  /// 3. 'items' - Common alternative
  /// 4. 'list' - Simple naming
  /// 5. 'content' - Spring Boot style
  /// 6. First key that contains a List
  String? _detectListWrapperKey(Map<String, dynamic> map) {
    // Priority keys
    const priorityKeys = ['data', 'results', 'items', 'list', 'content'];

    for (final key in priorityKeys) {
      if (map.containsKey(key) && map[key] is List) {
        return key;
      }
    }

    // Fallback: find any key with List value
    for (final entry in map.entries) {
      if (entry.value is List) {
        return entry.key;
      }
    }

    return null;
  }

  @override
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'GET',
      path: path,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'POST',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'PUT',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'PATCH',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'DELETE',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> upload<T>({
    required String path,
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
      ...?fields,
    });

    try {
      final response = await client.dio.post<Object>(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      final T data = fromJson != null
          ? serializer.decode<T>(response.data, fromJson as FromJson<T>)
          : response.data as T;

      return ApiResponse<T>(
        data: data,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        requestUri: response.requestOptions.uri.toString(),
        raw: response.data,
      );
    } on DioException catch (e) {
      throw ApiException(ErrorMapper.fromDio(e));
    }
  }

  @override
  Future<String> download({
    required String path,
    required String savePath,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await client.dio.download(
        path,
        savePath,
        queryParameters: query,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return savePath;
    } on DioException catch (e) {
      throw ApiException(ErrorMapper.fromDio(e));
    }
  }
}
