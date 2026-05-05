import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<Response<dynamic>> delete(String path) async {
    return _request(() => _dio.delete(path));
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _buildApiException(e);
    } catch (_) {
      throw const ApiException('Ocurrio un error inesperado.');
    }
  }

  ApiException _buildApiException(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverMessage = _extractMessage(error.response?.data);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(serverMessage, statusCode: statusCode);
    }

    switch (statusCode) {
      case 400:
        return const ApiException('Solicitud invalida.', statusCode: 400);
      case 401:
        return const ApiException(
          'Tu sesion expiro o no tienes autorizacion.',
          statusCode: 401,
        );
      case 404:
        return const ApiException('Recurso no encontrado.', statusCode: 404);
      case 409:
        return const ApiException(
          'Ya existe un registro con esos datos.',
          statusCode: 409,
        );
      case 500:
        return const ApiException(
          'Error interno del servidor.',
          statusCode: 500,
        );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException(
        'No se pudo conectar con el servidor. Verifica que el backend este activo.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'No hay conexion con el backend. Revisa la URL de la API.',
      );
    }

    return ApiException(
      'Error de comunicacion con el servidor.',
      statusCode: statusCode,
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String) return message;
      if (message is List) return message.join('\n');
    }

    if (data is String && data.isNotEmpty) return data;

    return null;
  }
}
