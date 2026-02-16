import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'easy_support_config.dart';

typedef EasySupportErrorCallback = void Function(WebResourceError error);

class EasySupport {
  EasySupport._();

  static EasySupportConfig? _config;

  static bool get isInitialized => _config != null;

  static EasySupportConfig get config {
    final currentConfig = _config;
    if (currentConfig == null) {
      throw StateError('Call EasySupport.init(config) before open().');
    }
    return currentConfig;
  }

  static void init(EasySupportConfig config) {
    _config = config;
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

    await showModalBottomSheet<void>(
      context: context,
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

  static WebViewController buildWebViewController({
    required EasySupportConfig config,
    EasySupportErrorCallback? onError,
  }) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            onError?.call(error);
          },
        ),
      )
      ..loadHtmlString(
        _buildHtml(config),
        baseUrl: config.normalizedBaseUrl,
      );
  }

  static String _buildHtml(EasySupportConfig config) {
    final sdkScriptUrl = jsonEncode(config.sdkScriptUrl);
    final widgetOptions = config.toJavaScriptOptionsJson();

    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        background: #f6f9ff;
      }
    </style>
  </head>
  <body>
    <script>
      (function(d, t) {
        var g = d.createElement(t);
        var s = d.getElementsByTagName(t)[0];
        g.src = $sdkScriptUrl;
        g.async = true;
        g.onerror = function() {
          console.error('Failed to load support sdk.js from ' + g.src);
        };
        s.parentNode.insertBefore(g, s);

        g.onload = function() {
          if (!window.EasySupportWidget || !window.EasySupportWidget.init) {
            console.error('EasySupportWidget.init was not found on window');
            return;
          }
          window.EasySupportWidget.init($widgetOptions);
        };
      })(document, 'script');
    </script>
  </body>
</html>
''';
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
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = EasySupport.buildWebViewController(
      config: widget.config,
      onError: widget.onError,
    );
  }

  @override
  void didUpdateWidget(covariant EasySupportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _webViewController = EasySupport.buildWebViewController(
        config: widget.config,
        onError: widget.onError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }
}
