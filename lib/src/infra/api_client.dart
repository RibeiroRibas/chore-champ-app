import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
    ));
  }

  late final Dio _dio;
  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
    return response.data as T;
  }

  Future<void> post(String path, {dynamic body}) async {
    await _dio.post<dynamic>(path, data: body);
  }

  Future<T> postWithResponse<T>(String path, {dynamic body}) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return response.data as T;
  }

  Future<T> put<T>(String path, {dynamic body}) async {
    final response = await _dio.put<dynamic>(path, data: body);
    return response.data as T;
  }

  Future<void> patch(String path, {dynamic body}) async {
    await _dio.patch<dynamic>(path, data: body);
  }

  Future<T> patchWithResponse<T>(String path, {dynamic body}) async {
    final response = await _dio.patch<dynamic>(path, data: body);
    return response.data as T;
  }

  Future<void> delete(String path) async {
    await _dio.delete<dynamic>(path);
  }

  void throwFromResponse(Response<dynamic> response) {
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : null;
    final code = (data != null && data['code'] != null)
        ? (data['code'] as num).toInt()
        : 0;
    final message = (data != null && data['message'] != null)
        ? data['message'] as String
        : response.statusMessage;
    throw ApiException(
      statusCode: response.statusCode ?? 0,
      code: code,
      message: message,
    );
  }
}
