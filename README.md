# easy_support_flutter

Easy Support Flutter SDK.

## Install

```yaml
dependencies:
  easy_support_flutter:
    path: ../easy_support_flutter
```

## Quick Start (Essential)

```dart
import 'package:easy_support_flutter/easy_support_flutter.dart';

await EasySupport.init(
  const EasySupportConfig.essentials(
    baseUrl: 'https://easysupport.onevision.io',
    channelToken: 'api_xxx',
  ),
);

await EasySupport.open(context);
```

Only two values are required:
- `baseUrl`
- `channelToken`

## Advanced Config

```dart
await EasySupport.init(
  config: const EasySupportConfig(
    baseUrl: 'https://easysupport.onevision.io',
    apiBaseUrl: 'https://easysupport.onevision.io/api/v1',
    channelToken: 'api_xxx',
    autoOpen: true,
    useWebSocketChannel: false,
    webSocketChannelUrl: 'wss://easysupport.onevision.io/socket.io/?EIO=4&transport=websocket',
    webSocketChannelSocketIoMode: true,
  ),
);
```

## Notes

- `apiBaseUrl` defaults to `${baseUrl}/api/v1` if not provided.
- During `EasySupport.init`, the SDK calls `${apiBaseUrl}/channel/key` first.
- If network is unavailable, init automatically retries and completes when connection is back.
- All widget API calls include `channelkey: channelToken` in headers.
- Socket backend defaults to `socket_io_client`. You can switch to `web_socket_channel` via `useWebSocketChannel`.
- `web_socket_channel` mode requires backend protocol compatibility (plain WS or Socket.IO frame mode).
- Init state is available via `EasySupport.state` / `EasySupport.stateListenable`.
- Merged runtime config (input params + API response) is available via `EasySupport.resolvedConfig`.
- Network workflow is handled by repository (`EasySupportRepository` -> `EasySupportDioRepository`) using `GET /channel/key`.
- Use public HTTPS URLs in production.
- Do not expose secret server keys in client config.
- Your backend must allow calls from app webview clients.
