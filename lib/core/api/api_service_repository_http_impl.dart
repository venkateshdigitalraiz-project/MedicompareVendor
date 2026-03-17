import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../error/exceptions.dart';
import '../network/connection_checker.dart';
import '../utils/token_storage.dart';
import 'api_service_repository.dart';

/// ---------------- LOGGER ----------------
class ApiLogger {
  static void logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    dynamic body,
  }) {
    String bodyStr;
    if (body is String) {
      bodyStr = body;
    } else if (body is File) {
      bodyStr = "File: ${body.path}";
    } else if (body is List<File>) {
      bodyStr = "List<File>: ${body.length} files";
    } else {
      try {
        bodyStr = jsonEncode(body ?? {});
      } catch (e) {
        bodyStr = "Unencodable body: $body";
      }
    }

    log('''
📤 API REQUEST
METHOD: $method
URL: ${uri.toString()}
HEADERS: ${jsonEncode(headers ?? {})}
BODY: $bodyStr
''', name: "API");
  }

  static void logResponse({
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    log('''
📥 API RESPONSE
URL: ${uri.toString()}
STATUS: $statusCode
BODY: $body
''', name: "API");
  }

  static void logError({required Uri uri, required dynamic error}) {
    log('''
❌ API ERROR
URL: ${uri.toString()}
ERROR: $error
''', name: "API");
  }
}

/// ---------------- IMPLEMENTATION ----------------
class ApiServiceRepositoryHttpImplementation implements ApiServiceRepository {
  final String baseUrl;
  final ConnectionChecker connectionChecker;

  ApiServiceRepositoryHttpImplementation({
    required this.baseUrl,
    required this.connectionChecker,
  });

  @override
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(
        queryParameters: queryParameters
            ?.map((key, value) => MapEntry(key, value.toString())));

    return _request(() async {
      final mergedHeaders = await _mergeHeaders(headers);
      ApiLogger.logRequest(method: "GET", uri: uri, headers: mergedHeaders);

      final response = await http.get(
        uri,
        headers: mergedHeaders,
      );

      ApiLogger.logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      return _handleResponse(response);
    }, uri: uri);
  }

  @override
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(
        queryParameters: queryParameters
            ?.map((key, value) => MapEntry(key, value.toString())));

    return _request(() async {
      final mergedHeaders = await _mergeHeaders(headers);
      ApiLogger.logRequest(
        method: "POST",
        uri: uri,
        headers: mergedHeaders,
        body: body ?? fields ?? files,
      );

      // Multipart request (fields or files)
      if (files != null || fields != null) {
        final request = http.MultipartRequest("POST", uri);
        mergedHeaders.remove('Content-Type'); // boundary is set automatically
        request.headers.addAll(mergedHeaders);

        if (fields != null) request.fields.addAll(fields);

        if (files != null) {
          for (var entry in files.entries) {
            final fieldName = entry.key;
            final file = entry.value;
            final extension = file.path.split('.').last.toLowerCase();
            String type = 'image';
            String subtype = 'jpeg';

            if (extension == 'png') {
              subtype = 'png';
            } else if (extension == 'gif') {
              subtype = 'gif';
            } else if (extension == 'webp') {
              subtype = 'webp';
            } else if (extension == 'pdf') {
              type = 'application';
              subtype = 'pdf';
            } else if (extension == 'doc' || extension == 'docx') {
              type = 'application';
              subtype = 'msword';
            }

            request.files.add(
              await http.MultipartFile.fromPath(
                fieldName,
                file.path,
                contentType: MediaType(type, subtype),
              ),
            );
          }
        }

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        ApiLogger.logResponse(
          uri: uri,
          statusCode: response.statusCode,
          body: response.body,
        );
        return _handleResponse(response);
      }

      if (body is Map<String, String>) {
        final formHeaders = await _mergeHeaders(headers, formContent: true);
        final response = await http.post(
          uri,
          headers: formHeaders,
          body: body,
        );
        ApiLogger.logResponse(
          uri: uri,
          statusCode: response.statusCode,
          body: response.body,
        );
        return _handleResponse(response);
      }

      final jsonHeaders = await _mergeHeaders(headers, jsonContent: true);
      final response = await http.post(
        uri,
        headers: jsonHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      ApiLogger.logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      return _handleResponse(response);
    }, uri: uri);
  }

  @override
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(
        queryParameters: queryParameters
            ?.map((key, value) => MapEntry(key, value.toString())));

    return _request(() async {
      final mergedHeaders = await _mergeHeaders(headers, jsonContent: true);
      ApiLogger.logRequest(
        method: "PUT",
        uri: uri,
        headers: mergedHeaders,
        body: body,
      );

      final response = await http.put(
        uri,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      ApiLogger.logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      return _handleResponse(response);
    }, uri: uri);
  }

  @override
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(
        queryParameters: queryParameters
            ?.map((key, value) => MapEntry(key, value.toString())));

    return _request(() async {
      final mergedHeaders = await _mergeHeaders(headers, jsonContent: true);
      ApiLogger.logRequest(
        method: "DELETE",
        uri: uri,
        headers: mergedHeaders,
        body: body,
      );

      final response = await http.delete(
        uri,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      ApiLogger.logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      return _handleResponse(response);
    }, uri: uri);
  }

  /// ---------------- PRIVATE ----------------
  Future<http.Response> _request(
    Future<http.Response> Function() request, {
    Uri? uri,
  }) async {
    bool connected = await connectionChecker.isConnected;

    if (!connected) {
      await Future.delayed(const Duration(milliseconds: 500));
      connected = await connectionChecker.isConnected;
    }

    if (!connected) {
      if (uri != null) ApiLogger.logError(uri: uri, error: "No Internet");
      throw NoInternetException();
    }

    try {
      return await request().timeout(const Duration(seconds: 30));
    } on SocketException catch (e) {
      if (uri != null) ApiLogger.logError(uri: uri, error: e.message);
      throw ServerException(
        "Unable to connect to the server. Please check your network and try again.",
      );
    } on TimeoutException {
      if (uri != null) {
        ApiLogger.logError(uri: uri, error: "Connection timed out");
      }
      throw ServerException(
        "The connection has timed out. Please check your network and try again.",
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      if (uri != null) ApiLogger.logError(uri: uri, error: e.toString());
      throw ServerException("An unexpected error occurred. Please try again.");
    }
  }

  Future<Map<String, String>> _mergeHeaders(
    Map<String, String>? headers, {
    bool jsonContent = false,
    bool formContent = false,
  }) async {
    final merged = <String, String>{};

    if (jsonContent) merged["Content-Type"] = "application/json";
    if (formContent) {
      merged["Content-Type"] = "application/x-www-form-urlencoded";
    }

    // Automatically add Authorization header if token exists
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      merged["Authorization"] = "Bearer $token";
    }

    if (headers != null) merged.addAll(headers);

    return merged;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Clear token globally if needed, but throwing a unique error is better for Bloc/UI handling
      throw ServerException("UNAUTHORIZED_ACCESS_401");
    }

    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode == 304) {
      return response;
    } else {
      String? message;
      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? data['error'];
      } catch (_) {
        // Body is not JSON
      }
      throw ServerException(message ?? "Server error (${response.statusCode})");
    }
  }
}
