import 'dart:io';
import 'package:http/http.dart' as http;

abstract class ApiServiceRepository {
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? fields,
    Map<String, File>? files,
  });

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });
}
