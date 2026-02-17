import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'easy_support_controller.dart';
import 'easy_support_config.dart';
import 'easy_support_repository.dart';

typedef EasySupportErrorCallback = void Function(WebResourceError error);

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
    await _ensureReady();
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
    await _ensureReady();
    if (!navigator.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: navigator.context,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          color: Colors.transparent,
          height: MediaQuery.of(sheetContext).size.height * heightFactor,
          child: EasySupportView(
            config: EasySupport.config,
            onError: onError,
          ),
        );
      },
    );
  }

  static Future<void> waitUntilReady() => _ensureReady();

  static Future<void> _ensureReady() async {
    await _controller.initialize(config);
  }
}

class EasySupportView extends StatefulWidget {
  const EasySupportView({
    super.key,
    required this.config,
    this.onError,
  });

  final EasySupportConfig config;
  final EasySupportErrorCallback? onError;

  @override
  State<EasySupportView> createState() => _EasySupportViewState();
}

class _EasySupportViewState extends State<EasySupportView> {
  @override
  void initState() {
    super.initState();
    print(
        'Easy Support initialized with config: ${widget.config.channelToken}');
  }

  @override
  void didUpdateWidget(covariant EasySupportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      print(
          'Easy Support initialized with config2: ${widget.config.channelToken}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Text(
      'EasySupportView is under development. Please check back later.',
    );
  }
}
