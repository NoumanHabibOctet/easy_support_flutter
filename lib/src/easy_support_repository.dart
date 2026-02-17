import 'package:dio/dio.dart';

import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';

abstract class EasySupportRepository {
  Future<EasySupportChannelConfiguration> fetchChannelKey(
    EasySupportConfig config,
  );
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
      throw EasySupportApiException(
        message:
            error.message ?? 'EasySupport init request failed for ${uri.path}',
        statusCode: error.response?.statusCode ?? -1,
      );
    }
  }
}

class EasySupportApiException implements Exception {
  const EasySupportApiException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => '$message: HTTP $statusCode';
}
