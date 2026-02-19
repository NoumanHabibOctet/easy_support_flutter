import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'easy_support_controller.dart';
import 'easy_support_repository.dart';
import 'easy_support_screen.dart';
import 'easy_support_view.dart';
import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';

class EasySupport {
  EasySupport._();

  static EasySupportConfig? _config;
  static final EasySupportController _controller = EasySupportController(
    repository: EasySupportDioRepository(),
  );

  static bool get isInitialized => _config != null;
  static bool get isReady => _controller.value.isReady;
  static EasySupportInitState get state => _controller.value;
  static ValueListenable<EasySupportInitState> get stateListenable =>
      _controller;

  static EasySupportConfig get config {
    final currentConfig = _config;
    if (currentConfig == null) {
      throw StateError('Call EasySupport.init(config) before open().');
    }
    return currentConfig;
  }

  static Future<void> init(EasySupportConfig config) async {
    _config = config;
    _controller.reset();
    final resolvedChannelConfiguration = await _ensureReady();
    _config =
        config.mergeWithChannelConfiguration(resolvedChannelConfiguration);
  }

  static Future<void> open(
    BuildContext context, {
    double heightFactor = 0.9,
    bool useSafeArea = true,
    EasySupportErrorCallback? onError,
  }) async {
    assert(
      heightFactor > 0 && heightFactor <= 1,
      'heightFactor must be between 0 and 1',
    );

    final navigator = Navigator.of(context);
    final resolvedChannelConfiguration = await _ensureReady();
    if (!navigator.mounted) {
      return;
    }

    await navigator.push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) {
          return EasySupportScreen(
            config: EasySupport.resolvedConfig,
            channelConfiguration: resolvedChannelConfiguration,
            useSafeArea: useSafeArea,
            onError: onError,
          );
        },
      ),
    );
  }

  static Future<void> waitUntilReady() async {
    await _ensureReady();
  }

  static EasySupportConfig get resolvedConfig {
    final channel = _currentChannelConfiguration;
    if (channel == null) {
      return config;
    }
    return config.mergeWithChannelConfiguration(channel);
  }

  static EasySupportChannelConfiguration? get _currentChannelConfiguration =>
      _controller.value.channelConfiguration;

  static Future<EasySupportChannelConfiguration> _ensureReady() async {
    return _controller.initialize(config);
  }
}
