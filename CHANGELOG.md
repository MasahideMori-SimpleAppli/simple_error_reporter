## 2.0.0 (2026-05-27)

* BREAKING: The `appName` parameter is now required in `ErrorReportObj`.
  This change allows a single backend to receive errors from multiple applications.
  Consequently, the `appName` argument is also required when initializing `ErrorReporter` and
  `ErrorReporterForNative`.

## 1.0.3 (2026-05-15)

* Bumped `simple_https_service` constraint to `^2.0.0` to follow the
  upstream package's 2.0.0 release. No API changes in this package.
  Note that `simple_https_service` 2.0.0 added the
  `EnumServerResponseStatus.cancelled` value; this package's send path
  (`response.resultStatus != EnumServerResponseStatus.success`) treats
  a cancelled response as a send failure and invokes `onSendFailure`,
  which is the intended behavior for error reporting.

## 1.0.2 (2026-05-04)

* Redeploy to fix pub.dev scores affected by a static analysis outage.

## 1.0.1 (2026-05-03)

* Fixed circular import: `error_reporter.dart` and `error_reporter_for_native.dart` now import
  `error_report_obj.dart` and `error_reporter_config.dart` directly instead of the barrel file.
* Added dartdoc comments to all public API members (`allowReporting` field,
  `ErrorReportObj` fields).

## 1.0.0 (2026-05-03)

* Initial release as a standalone package, extracted from `simple_jwt_manager`.
* `ErrorReporter`: Automatic and manual error reporting for web and native platforms.
* `ErrorReporterForNative`: Error reporting for native platforms with self-signed certificate
  support.
* `ErrorReportObj`: Data object representing the error payload sent to the server.
* `ErrorReporterConfig`: Singleton for independent retry control without affecting the global
  `RetryConfig` in `simple_https_service`.
* Rate limiting: configurable max reports per time window to prevent error loops.
* Duplicate filtering: prevents sending the same error multiple times (up to 1000 recent errors).
* `allowReporting` flag for consent-based reporting control.
* `onSendFailure` callback for handling send failures.
* Automatic error catching via `FlutterError.onError` and `PlatformDispatcher.instance.onError`.

### Breaking changes from `simple_jwt_manager`

* `ErrorReportObj.timestamp` is now sent in UTC ISO 8601 format (e.g. `"2026-05-03T03:00:00.000Z"`).
  Previously, the local device time without timezone information was used.
