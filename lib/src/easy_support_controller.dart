import 'package:flutter/foundation.dart';

import 'easy_support_config.dart';
import 'easy_support_repository.dart';

enum EasySupportInitStatus { initial, loading, ready, error }

@immutable
class EasySupportInitState {
  const EasySupportInitState._({
    required this.status,
    this.error,
  });

  const EasySupportInitState.initial()
      : this._(status: EasySupportInitStatus.initial);

  const EasySupportInitState.loading()
      : this._(status: EasySupportInitStatus.loading);

  const EasySupportInitState.ready()
      : this._(status: EasySupportInitStatus.ready);

  const EasySupportInitState.error(Object error)
      : this._(status: EasySupportInitStatus.error, error: error);

  final EasySupportInitStatus status;
  final Object? error;

  bool get isReady => status == EasySupportInitStatus.ready;
}

class EasySupportController extends ValueNotifier<EasySupportInitState> {
  EasySupportController({required EasySupportRepository repository})
      : _repository = repository,
        super(const EasySupportInitState.initial());

  final EasySupportRepository _repository;
  Future<void>? _inFlightInitialization;

  Future<void> initialize(EasySupportConfig config) {
    if (value.isReady) {
      return Future<void>.value();
    }

    final inFlightInitialization = _inFlightInitialization;
    if (inFlightInitialization != null) {
      return inFlightInitialization;
    }

    value = const EasySupportInitState.loading();
    final initialization = _repository.fetchChannelKey(config).then((_) {
      value = const EasySupportInitState.ready();
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
