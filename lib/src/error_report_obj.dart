/// (en) This is an object for storing basic error content used by
/// ErrorReporter and ErrorReporterForNative.
///
/// (ja) ErrorReporter、及びErrorReporterForNativeで利用される
/// 基本的なエラー内容を格納するためのオブジェクトです。
class ErrorReportObj {
  final String appVersion;
  final String errorMsg;
  final String? stackTrace;
  final String timestamp;
  final Map<String, dynamic>? extraInfo;
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
