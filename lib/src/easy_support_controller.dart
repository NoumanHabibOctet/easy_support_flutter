import 'package:flutter/foundation.dart';

import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';
import 'easy_support_repository.dart';

enum EasySupportInitStatus { initial, loading, ready, error }

@immutable
class EasySupportInitState {
  const EasySupportInitState._({
    required this.status,
    this.error,
    this.channelConfiguration,
  });

  const EasySupportInitState.initial()
      : this._(status: EasySupportInitStatus.initial);

  const EasySupportInitState.loading()
      : this._(status: EasySupportInitStatus.loading);

  const EasySupportInitState.ready()
      : this._(status: EasySupportInitStatus.ready);

  const EasySupportInitState.readyWith(
    EasySupportChannelConfiguration channelConfiguration,
  ) : this._(
         status: EasySupportInitStatus.ready,
         channelConfiguration: channelConfiguration,
       );

  const EasySupportInitState.error(Object error)
      : this._(status: EasySupportInitStatus.error, error: error);

  final EasySupportInitStatus status;
  final Object? error;
  final EasySupportChannelConfiguration? channelConfiguration;

  bool get isReady => status == EasySupportInitStatus.ready;
}

class EasySupportController extends ValueNotifier<EasySupportInitState> {
  EasySupportController({required EasySupportRepository repository})
      : _repository = repository,
        super(const EasySupportInitState.initial());

  final EasySupportRepository _repository;
  Future<EasySupportChannelConfiguration>? _inFlightInitialization;

  Future<EasySupportChannelConfiguration> initialize(EasySupportConfig config) {
    final readyChannelConfiguration = value.channelConfiguration;
    if (value.isReady && readyChannelConfiguration != null) {
      return Future<EasySupportChannelConfiguration>.value(
        readyChannelConfiguration,
      );
    }

    final inFlightInitialization = _inFlightInitialization;
    if (inFlightInitialization != null) {
      return inFlightInitialization;
    }

    value = const EasySupportInitState.loading();
    final initialization = _repository.fetchChannelKey(config).then((
      channelConfiguration,
    ) {
      value = EasySupportInitState.readyWith(channelConfiguration);
      return channelConfiguration;
    }).catchError((Object error, StackTrace stackTrace) {
      value = EasySupportInitState.error(error);
      _inFlightInitialization = null;
      throw error;
    });

    _inFlightInitialization = initialization;
    return initialization;
  }

  void reset() {
    _inFlightInitialization = null;
    value = const EasySupportInitState.initial();
  }
}
