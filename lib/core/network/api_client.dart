import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<Response> get(String url) async {
    try {
      return await _dio.get(url);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      default:
        return Exception('Something went wrong');
    }
  }
}
