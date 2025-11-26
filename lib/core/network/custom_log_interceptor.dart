import 'package:dio/dio.dart';
import 'package:easy_app/core/utils/app_logger.dart';

/// Custom log interceptor for Dio that provides readable and intuitive logging
class CustomLogInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;
  final bool logRequestHeaders;
  final bool logResponseHeaders;
  final bool logRequestBody;
  final bool logResponseBody;

  CustomLogInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logRequestHeaders = true,
    this.logResponseHeaders = false,
    this.logRequestBody = true,
    this.logResponseBody = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      AppLogger.logApiRequest(
        method: options.method,
        url: options.uri.toString(),
        headers: logRequestHeaders ? options.headers : null,
        data: logRequestBody ? options.data : null,
        queryParameters: options.queryParameters.isNotEmpty
            ? options.queryParameters
            : null,
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      AppLogger.logApiResponse(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode,
        headers: logResponseHeaders ? response.headers.map : null,
        data: logResponseBody ? response.data : null,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      AppLogger.logApiResponse(
        method: err.requestOptions.method,
        url: err.requestOptions.uri.toString(),
        statusCode: err.response?.statusCode,
        headers: logResponseHeaders ? err.response?.headers.map : null,
        data: logResponseBody ? err.response?.data : null,
        errorMessage: err.message,
      );

      // Log additional error details
      AppLogger.error(
        'API Request Failed',
        tag: 'DioInterceptor',
        error: {
          'type': err.type.toString(),
          'message': err.message,
          'response': err.response?.data,
          'statusCode': err.response?.statusCode,
        },
        stackTrace: err.stackTrace,
      );
    }
    handler.next(err);
  }
}

