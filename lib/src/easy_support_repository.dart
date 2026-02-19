import 'package:dio/dio.dart';

import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';
import 'models/easy_support_customer_action.dart';
import 'models/easy_support_customer_response.dart';

abstract class EasySupportRepository {
  Future<EasySupportChannelConfiguration> fetchChannelKey(
    EasySupportConfig config,
  );

  Future<EasySupportCustomerResponse> postCustomer({
    required EasySupportConfig config,
    required EasySupportCustomerAction action,
    required Map<String, dynamic> body,
  }) {
    throw UnimplementedError(
      'postCustomer is not implemented in this repository.',
    );
  }
}

class EasySupportDioRepository implements EasySupportRepository {
  EasySupportDioRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<EasySupportChannelConfiguration> fetchChannelKey(
    EasySupportConfig config,
  ) async {
    final uri = Uri.parse('${config.normalizedApiBaseUrl}/channel/key');

    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          method: 'GET',
          headers: config.resolvedHeaders,
        ),
      );

      final statusCode = response.statusCode ?? -1;
      if (statusCode < 200 || statusCode >= 300) {
        throw EasySupportApiException(
          message: 'EasySupport init failed for ${uri.path}',
          statusCode: statusCode,
        );
      }

      final rawBody = response.data;
      if (rawBody is! Map) {
        throw EasySupportApiException(
          message: 'EasySupport init failed for ${uri.path}',
          statusCode: statusCode,
        );
      }

      final body = Map<String, dynamic>.from(rawBody);
      final parsedResponse = EasySupportChannelKeyResponse.fromJson(body);
      final channelConfiguration = parsedResponse.data;
      if (!parsedResponse.success || channelConfiguration == null) {
        throw EasySupportApiException(
          message: 'EasySupport init failed for ${uri.path}',
          statusCode: statusCode,
        );
      }
      return channelConfiguration;
    } on DioException catch (error) {
      final isNetworkError = error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
      throw EasySupportApiException(
        message:
            error.message ?? 'EasySupport init request failed for ${uri.path}',
        statusCode: error.response?.statusCode ?? -1,
        isNetworkError: isNetworkError,
      );
    }
  }

  @override
  Future<EasySupportCustomerResponse> postCustomer({
    required EasySupportConfig config,
    required EasySupportCustomerAction action,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(
      '${config.normalizedApiBaseUrl}/customer/${action.name}',
    );

    try {
      final response = await _dio.post<dynamic>(
        uri.toString(),
        data: body,
        options: Options(
          method: 'POST',
          headers: config.resolvedHeaders,
        ),
      );

      final statusCode = response.statusCode ?? -1;
      if (statusCode < 200 || statusCode >= 300) {
        throw EasySupportApiException(
          message: 'EasySupport customer call failed for ${uri.path}',
          statusCode: statusCode,
        );
      }

      final rawBody = response.data;
      if (rawBody is! Map) {
        throw EasySupportApiException(
          message: 'EasySupport customer call failed for ${uri.path}',
          statusCode: statusCode,
        );
      }

      final parsedResponse = EasySupportCustomerResponse.fromJson(
        Map<String, dynamic>.from(rawBody),
      );
      if (!parsedResponse.success) {
        throw EasySupportApiException(
          message: 'EasySupport customer call failed for ${uri.path}',
          statusCode: statusCode,
        );
      }
      return parsedResponse;
    } on DioException catch (error) {
      final isNetworkError = error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
      throw EasySupportApiException(
        message: error.message ??
            'EasySupport customer request failed for ${uri.path}',
        statusCode: error.response?.statusCode ?? -1,
        isNetworkError: isNetworkError,
      );
    }
  }
}

class EasySupportApiException implements Exception {
  const EasySupportApiException({
    required this.message,
    required this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int statusCode;
  final bool isNetworkError;

  @override
  String toString() => '$message: HTTP $statusCode';
}
