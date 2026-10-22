# simple_error_reporter

(en)English ver is [here](https://github.com/MasahideMori-SimpleAppli/simple_error_reporter/blob/main/README.md).  
(ja)この解説の英語版は[ここ](https://github.com/MasahideMori-SimpleAppli/simple_error_reporter/blob/main/README.md)にあります。

## 概要
このパッケージは、Flutterアプリケーション向けにバックエンドサーバーへの自動エラー報告機能を提供します。  
レート制限、重複エラーフィルタリング、同意ベースの報告制御を備えています。

2つの実装が用意されています：
- `ErrorReporter`: WebとNativeの両プラットフォームで動作します。
- `ErrorReporterForNative`: Native専用で、`securityContext` または `badCertificateCallback` による自己署名証明書のサポートがあります。

## 機能
- `FlutterError.onError` および `PlatformDispatcher.instance.onError` による自動エラーキャッチ
- `reportError()` による手動エラー報告
- レート制限: エラーループを防ぐための時間窓あたりの最大報告数設定
- 重複フィルタリング: 同じエラーの重複送信を防止（`avoidDuplicate`）
- 同意ベースの報告制御のための `allowReporting` フラグ
- 認証済みエラー報告のための `getJWT` パラメータ
- 送信失敗時のコールバック `onSendFailure`（ローカルストレージへの保存などに活用可能）
- `ErrorReporterConfig` シングルトンによるリトライの独立制御（`simple_https_service` のグローバル `RetryConfig` から独立）

## 送信ペイロードの形式

エラー報告時にエンドポイントへ以下のJSONが送信されます：

```json
{
  "app_name": "my_app",
  "app_version": "1.0.0",
  "error_msg": "Exception: something went wrong",
  "stacktrace": "#0 ...",
  "timestamp": "2026-05-27T03:00:00.000Z",
  "extra_info": {"platform": "web"},
  "custom_extra_info": {"location": "HomeScreen"}
}
```

`timestamp` は常に UTC の ISO 8601 形式（末尾 `Z`）で送信されます。

## 使い方

### 基本的なセットアップ

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WebまたはNativeデバイス向け。
  // init後、FlutterおよびPlatformエラーを自動でキャッチします。
  ErrorReporter().init(
    endpointUrl: 'https://your-endpoint.example.com/errors',
    appName: 'my_app',
    appVersion: '1.0.0',
    extraInfo: {'platform': 'web'},
  );

  runApp(const MyApp());
}
```

### 自己署名証明書を使ったNative専用

`ErrorReporterForNative` は `securityContext` と `badCertificateCallback` を受け取り、`simple_https_service` の `HttpsServiceForNative` に渡します。
サーバー証明書（PEM形式。**秘密鍵は絶対に含めないこと**）をassetsに同梱し、条件に応じて以下のいずれかの方法を選びます。
詳細は [`simple_https_service`](https://pub.dev/packages/simple_https_service) のREADMEを参照してください。

| 条件 | 方法 |
|---|---|
| サーバーのホスト名またはIPが固定で、証明書のSANに含められる（推奨） | `securityContext` + `UtilSecurityContext` |
| サーバーのIPが変わる可能性があり（DHCPなど）、SANを固定できない | `badCertificateCallback` + `CertificatePinner` |

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';
import 'package:simple_https_service/simple_https_service.dart';

ErrorReporterForNative().init(
  endpointUrl: 'https://192.168.1.1/errors',
  appName: 'my_app',
  appVersion: '1.0.0',
  // 推奨：通常の検証が行われます（ホスト名や有効期限も検証）。
  securityContext:
      await UtilSecurityContext.fromAsset('assets/certs/local_server.pem'),
  // SANを固定できない場合は代わりにこちらを使用します：
  // badCertificateCallback:
  //     (await CertificatePinner.fromAsset('assets/certs/local_server.pem')).check,
);
```

> **Warning**  
> `badCertificateCallback` で無条件に `true` を返すとSSL検証が無視されます。本番環境（Releaseモード）での利用や、信頼できないネットワーク環境での使用は避けてください。

### 手動エラー報告

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

await ErrorReporter().reportError(
  error,
  stackTrace,
  customExtraInfo: {'location': 'HomeScreen'},
);
```

### 認証済みエラー報告

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

await ErrorReporter().reportError(
  error,
  stackTrace,
  getJWT: () async => await myTokenStore.getAccessToken(),
);
```

### 同意ベースの報告制御

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

// ユーザーの許可が得られるまでfalseに設定。
ErrorReporter().allowReporting = false;

// 許可が得られたらtrueに設定。
ErrorReporter().allowReporting = true;
```

### 送信失敗時の処理

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

ErrorReporter().init(
  endpointUrl: 'https://your-endpoint.example.com/errors',
  appName: 'my_app',
  appVersion: '1.0.0',
  onSendFailure: (reportData) async {
    // TODO: 後でリトライできるようにreportDataをローカルストレージに保存。
  },
);
```

### リトライの設定

デフォルトでは、エラーレポートはリトライなしで1回だけ送信されます。  
`ErrorReporterConfig` を使うと、`simple_https_service` のグローバルなリトライ設定に影響を与えずに、エラーレポーター独自のリトライ動作を設定できます。

```dart
import 'package:simple_error_reporter/simple_error_reporter.dart';

// リトライを有効にする（init より前、例えば main() 内で設定）。
ErrorReporterConfig().maxRetries = 3;
ErrorReporterConfig().baseDelay = const Duration(seconds: 1);
ErrorReporterConfig().maxJitter = const Duration(milliseconds: 500);
ErrorReporterConfig().retryCondition = (url, res, error) {
  // サーバーエラーやネットワーク例外の場合のみリトライする。
  return res.resultStatus == EnumServerResponseStatus.serverError ||
      error != null;
};
```

`retryCondition` が設定されていない場合（`null`）、`maxRetries` の値に関わらずリトライは行われません。グローバルな `RetryConfig` の設定も影響しません。

## サポート
基本的にサポートはありません。  
もし問題がある場合はGithubのissueを開いてください。  
このパッケージは優先度が低いですが、修正される可能性があります。

## バージョン管理について
それぞれ、Cの部分が変更されます。  
ただし、バージョン1.0.0未満は以下のルールに関係無くファイル構造が変化する場合があります。  
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
  - C.X.X
- メソッドの追加など
  - X.C.X
- 軽微な変更やバグ修正
  - X.X.C

## ライセンス
このソフトウェアはApache-2.0ライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

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

- "Dart" および "Flutter" は Google LLC の商標です。  
  *このパッケージは Google LLC によって開発・推奨されたものではありません。*
