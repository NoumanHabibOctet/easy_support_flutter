# easy_support_flutter

A Flutter package for initializing and opening Easy Support.

## What this package gives you

- `EasySupport.init(config)` to set SDK config once
- `EasySupport.open(context)` to open chat in a full-screen page
- `EasySupportView(config: ...)` if you want to embed the widget directly

## Install

```yaml
dependencies:
  easy_support_flutter:
    path: ../easy_support_flutter
```

## Usage

```dart
import 'package:easy_support_flutter/easy_support_flutter.dart';

await EasySupport.init(
  const EasySupportConfig(
    baseUrl: 'https://easysupport-portal.onevision.io',
    apiBaseUrl: 'https://easysupport-portal.onevision.io/api/v1',
    channelToken: 'api_xxx',
    autoOpen: true,
    // Optional: use hosted web widget inside app WebView
    useWebView: false,
    webViewUrl: 'https://easysupport-portal.onevision.io',
    // Optional: make app socket config match your web client
    socketPath: '/socket.io/',
    socketNamespace: '/',
    socketTransports: <String>['websocket', 'polling'],
    socketQuery: <String, dynamic>{},
    socketAuth: <String, dynamic>{},
  ),
);

await EasySupport.open(context);
```

## Embed directly in a screen

```dart
EasySupportView(
  config: const EasySupportConfig(
    baseUrl: 'https://easysupport-portal.onevision.io',
    apiBaseUrl: 'https://easysupport-portal.onevision.io/api/v1',
    channelToken: 'api_xxx',
  ),
)
```

## Notes

- `apiBaseUrl` defaults to `${baseUrl}/api/v1` if not provided.
- During `EasySupport.init`, the SDK calls `${apiBaseUrl}/channel/key` first.
- If network is unavailable, init automatically retries and completes when connection is back.
- All widget API calls include `channelkey: channelToken` in headers.
- Init state is available via `EasySupport.state` / `EasySupport.stateListenable`.
- Merged runtime config (input params + API response) is available via `EasySupport.resolvedConfig`.
- Network workflow is handled by repository (`EasySupportRepository` -> `EasySupportDioRepository`) using `GET /channel/key`.
- For socket compatibility with an existing web panel, align `socketPath`, `socketNamespace`, `socketTransports`, `socketQuery`, and `socketAuth`.
- If `useWebView` is true, EasySupport opens a WebView and injects JS options from Flutter config.
- Use public HTTPS URLs in production.
- Do not expose secret server keys in client config.
- Your backend must allow calls from app webview clients.
