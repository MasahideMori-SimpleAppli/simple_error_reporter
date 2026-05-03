/// (en) This is an object for storing basic error content used by
/// ErrorReporter and ErrorReporterForNative.
///
/// (ja) ErrorReporter、及びErrorReporterForNativeで利用される
/// 基本的なエラー内容を格納するためのオブジェクトです。
class ErrorReportObj {
  /// (en) Frontend app version.
  /// (ja) フロントエンドのアプリバージョン。
  final String appVersion;

  /// (en) The error message.
  /// (ja) エラーメッセージ。
  final String errorMsg;

  /// (en) The stacktrace.
  /// (ja) スタックトレース。
  final String? stackTrace;

  /// (en) Timestamp in UTC ISO 8601 format.
  /// (ja) UTC の ISO 8601 形式のタイムスタンプ。
  final String timestamp;

  /// (en) Additional information common to this app added during initialization.
  /// (ja) 初期化時に追加されるアプリ共通の付加情報。
  final Map<String, dynamic>? extraInfo;

  /// (en) Additional information added when reporting an individual error.
  /// (ja) 個別エラー報告時に追加される付加情報。
  final Map<String, dynamic>? customExtraInfo;

  /// * [appVersion] : Frontend app version.
  /// * [errorMsg] : The error message.
  /// * [stackTrace] : The stacktrace.
  /// * [timestamp] : Timestamp in UTC ISO 8601 format.
  /// It is recommended to overwrite with the server time when saving.
  /// * [extraInfo] : Additional information common to this app that is added
  /// during initialization, such as the app's platform information.
  /// * [customExtraInfo] : When reporting an individual error,
  /// additional information, such as the location of the error, is added.
  ErrorReportObj(this.appVersion, this.errorMsg, this.stackTrace,
      this.timestamp, this.extraInfo, this.customExtraInfo);

  /// (en) Convert to dict.
  ///
  /// (ja) 辞書に変換して返します。
  Map<String, dynamic> toDict() {
    return {
      "app_version": appVersion,
      "error_msg": errorMsg,
      "stacktrace": stackTrace,
      "timestamp": timestamp,
      "extra_info": extraInfo,
      "custom_extra_info": customExtraInfo,
    };
  }
}
