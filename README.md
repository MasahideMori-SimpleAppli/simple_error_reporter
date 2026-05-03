# simple_error_reporter

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/simple_error_reporter/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/simple_error_reporter/blob/main/README_JA.md)にあります。

## Overview
This package provides automatic error reporting to a backend server for Flutter applications.  
It includes rate limiting, duplicate error filtering, and consent-based reporting control.

Two implementations are provided:
- `ErrorReporter`: Works on both web and native platforms.
- `ErrorReporterForNative`: Native-only, with support for self-signed certificates via `badCertificateCallback`.

## Features
- Automatic Flutter and platform error catching via `FlutterError.onError` and `PlatformDispatcher.instance.onError`
- Manual error reporting via `reportError()`
- Rate limiting: configurable max reports per time window to prevent error loops
- Duplicate filtering: prevents sending the same error multiple times (`avoidDuplicate`)
- `allowReporting` flag for consent-based reporting control
- `getJWT` parameter for authenticated error reporting
- `onSendFailure` callback for handling send failures (e.g., saving to local storage)
- `ErrorReporterConfig` singleton for independent retry control (isolated from global `RetryConfig` in `simple_https_service`)

## Payload format

The following JSON is sent to the endpoint on each report:

```json
{
  "app_version": "1.0.0",
  "error_msg": "Exception: something went wrong",
  "stacktrace": "#0 ...",
  "timestamp": "2026-05-03T03:00:00.000Z",
  "extra_info": {"platform": "web"},
  "custom_extra_info": {"location": "HomeScreen"}
}
```

`timestamp` is always in UTC ISO 8601 format (trailing `Z`).

## Usage

### Basic setup

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For web or native device.
  // Automatically catches Flutter and platform errors after init.
  ErrorReporter().init(
    endpointUrl: 'https://your-endpoint.example.com/errors',
    appVersion: '1.0.0',
    extraInfo: {'platform': 'web'},
  );

  runApp(const MyApp());
}
```

### Native-only with self-signed certificate

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

ErrorReporterForNative().init(
  endpointUrl: 'https://your-endpoint.example.com/errors',
  appVersion: '1.0.0',
  badCertificateCallback: (cert, host, port) => true,
);
```

### Manual error reporting

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

await ErrorReporter().reportError(
  error,
  stackTrace,
  customExtraInfo: {'location': 'HomeScreen'},
);
```

### Authenticated error reporting

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

await ErrorReporter().reportError(
  error,
  stackTrace,
  getJWT: () async => await myTokenStore.getAccessToken(),
);
```

### Consent-based reporting

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

// Set false until the user grants permission.
ErrorReporter().allowReporting = false;

// Once permission is granted:
ErrorReporter().allowReporting = true;
```

### Handling send failures

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

ErrorReporter().init(
  endpointUrl: 'https://your-endpoint.example.com/errors',
  appVersion: '1.0.0',
  onSendFailure: (reportData) async {
    // TODO: Save reportData to local storage for later retry.
  },
);
```

### Retry configuration

By default, error reports are sent once with no retries.  
Use `ErrorReporterConfig` to enable retries independently of any global retry settings in `simple_https_service`.

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

// Enable retries for error reporting (call this before init, e.g. in main()).
ErrorReporterConfig().maxRetries = 3;
ErrorReporterConfig().baseDelay = const Duration(seconds: 1);
ErrorReporterConfig().maxJitter = const Duration(milliseconds: 500);
ErrorReporterConfig().retryCondition = (url, res, error) {
  // Retry only on server errors or network exceptions.
  return res.resultStatus == EnumServerResponseStatus.serverError ||
      error != null;
};
```

`retryCondition` must be set for retries to occur. If it is `null`, `maxRetries` is ignored and no retries are attempted — regardless of any global `RetryConfig` settings.

## Support
Basically no support.  
If you have any problem please open an issue on Github.  
This package is low priority, but may be fixed.

## About version control
The C part will be changed at the time of version upgrade.  
However, versions less than 1.0.0 may change the file structure regardless of the following rules.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
Copyright 2026 Masahide Mori

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Trademarks

- "Dart" and "Flutter" are trademarks of Google LLC.  
  *This package is not developed or endorsed by Google LLC.*
