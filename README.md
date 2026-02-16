# easy_support_flutter

A Flutter SDK wrapper for your existing web support widget (`/widget/sdk.js`).

## What this package gives you

- `EasySupport.init(config)` to set SDK config once
- `EasySupport.open(context)` to open chat in a bottom sheet
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

EasySupport.init(
  const EasySupportConfig(
    sdkBaseUrl: 'https://easysupport-portal.onevision.io',
    baseUrl: 'https://easysupport-portal.onevision.io',
    apiBaseUrl: 'https://easysupport-portal.onevision.io/api/v1',
    channelToken: 'api_xxx',
    autoOpen: true,
  ),
);

await EasySupport.open(context);
```

## Optional direct sdk.js URL

You can pass either of these:

- Domain/base URL: `https://easysupport-portal.onevision.io`
- Direct script URL: `https://easysupport-portal.onevision.io/widget/sdk.js`

## Embed directly in a screen

```dart
EasySupportView(
  config: const EasySupportConfig(
    sdkBaseUrl: 'https://easysupport-portal.onevision.io',
    baseUrl: 'https://easysupport-portal.onevision.io',
    apiBaseUrl: 'https://easysupport-portal.onevision.io/api/v1',
    channelToken: 'api_xxx',
  ),
)
```

## Notes

- `apiBaseUrl` defaults to `${baseUrl}/api/v1` if not provided.
- Use public HTTPS URLs in production.
- Do not expose secret server keys in client config.
- Your backend must allow calls from app webview clients.
