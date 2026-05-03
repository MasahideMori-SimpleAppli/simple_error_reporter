import 'package:simple_https_service/simple_https_service.dart';

/// (en) Singleton configuration for ErrorReporter and ErrorReporterForNative.
/// Use this to control retry behavior independently of the global RetryConfig
/// in simple_https_service.
///
/// (ja) ErrorReporter および ErrorReporterForNative 用のシングルトン設定クラスです。
/// simple_https_service のグローバル RetryConfig に依存せず、
/// エラーレポーターのリトライ動作を独立して制御できます。
///
/// Author Masahide Mori
///
/// First edition creation date 2026-05-03 00:00:00
class ErrorReporterConfig {
  static final ErrorReporterConfig _instance = ErrorReporterConfig._internal();

  factory ErrorReporterConfig() => _instance;

  ErrorReporterConfig._internal();

  /// Maximum number of retries on failure. Defaults to 0 (no retries).
  int maxRetries = 0;

  /// Base delay for exponential backoff.
  Duration baseDelay = const Duration(seconds: 1);

  /// Maximum random jitter added to each retry delay.
  Duration maxJitter = const Duration(milliseconds: 500);

  /// Condition under which a retry is attempted.
  /// If null, no retries occur (maxRetries is ignored).
  bool Function(String url, ServerResponse res, Object? error)? retryCondition;
}
