import 'package:dio/dio.dart';
import '../serializer/serializer_interface.dart';
import 'api_response.dart';

/// Main API Manager interface with smart parsing capabilities
///
/// This interface provides type-safe HTTP methods with automatic
/// list parsing, wrapper detection, and pagination support.
///
/// Example usage:
/// ```dart
/// // Single model
/// final user = await api.get<User>(
///   path: 'users/123',
///   fromJson: User.fromJson,
/// );
///
/// // List of models (auto-detects wrapper)
/// final users = await api.get<List<User>>(
///   path: 'users',
///   fromJson: User.fromJson,
/// );
///
/// // List with explicit wrapper
/// final pokemon = await api.get<List<Pokemon>>(
///   path: 'pokemon',
///   fromJson: Pokemon.fromJson,
///   listWrapperKey: 'results',
/// );
/// ```
abstract class ApiManager {
  /// GET request with smart parsing
  ///
  // ignore: unintended_html_in_doc_comment
  /// - [T]: Return type (Model or List<Model>)
  /// - [path]: API endpoint path
  /// - [query]: Query parameters
  /// - [headers]: Additional headers
  /// - [cancelToken]: Cancellation token
  /// - [fromJson]: JSON decoder function for the MODEL (not list!)
  ///   - For single model: User.fromJson
  ///   - For list: User.fromJson (module will handle list automatically!)
  /// - [listWrapperKey]: Wrapper key for lists (auto-detected if null)
  /// - [extractor]: Custom data extraction (overrides fromJson)
  /// - [priority]: Request priority (default: normal)
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  });

  /// POST request with smart parsing
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
  });

  /// PUT request with smart parsing
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
  });

  /// PATCH request with smart parsing
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
  });

  /// DELETE request with smart parsing
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
  });

  /// Upload file with progress tracking
  Future<ApiResponse<T>> upload<T>({
    required String path,
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
  });

  /// Download file with progress tracking
  Future<String> download({
    required String path,
    required String savePath,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });
}

/// Request priority levels for queue management
enum RequestPriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  final int value;
  const RequestPriority(this.value);
}
