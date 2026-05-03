import 'package:flutter_test/flutter_test.dart';
import 'package:simple_error_reporter/simple_error_reporter.dart';
import 'package:simple_https_service/simple_https_service.dart';

void main() {
  group('ErrorReportObj', () {
    test('toDict returns all expected keys', () {
      final obj = ErrorReportObj(
        '1.0.0',
        'Test error',
        '#0 main.dart',
        '2026-05-03T00:00:00.000',
        {'platform': 'web'},
        {'location': 'HomeScreen'},
      );
      final dict = obj.toDict();
      expect(dict['app_version'], '1.0.0');
      expect(dict['error_msg'], 'Test error');
      expect(dict['stacktrace'], '#0 main.dart');
      expect(dict['timestamp'], '2026-05-03T00:00:00.000');
      expect(dict['extra_info'], {'platform': 'web'});
      expect(dict['custom_extra_info'], {'location': 'HomeScreen'});
    });

    test('toDict handles null optional fields', () {
      final obj = ErrorReportObj(
          '1.0.0', 'error', null, '2026-05-03T00:00:00.000', null, null);
      final dict = obj.toDict();
      expect(dict['stacktrace'], isNull);
      expect(dict['extra_info'], isNull);
      expect(dict['custom_extra_info'], isNull);
    });
  });

  group('ErrorReporter', () {
    setUp(() {
      ErrorReporter().allowReporting = true;
    });

    test('is singleton', () {
      final a = ErrorReporter();
      final b = ErrorReporter();
      expect(identical(a, b), isTrue);
    });

    test('allowReporting defaults to true', () {
      expect(ErrorReporter().allowReporting, isTrue);
    });

    test('reportError completes without throwing when not initialized',
        () async {
      await expectLater(
        ErrorReporter().reportError(Exception('test'), null),
        completes,
      );
    });

    test('reportError completes without throwing when allowReporting is false',
        () async {
      ErrorReporter().allowReporting = false;
      await expectLater(
        ErrorReporter().reportError(Exception('test'), null),
        completes,
      );
    });
  });

  group('ErrorReporterForNative', () {
    setUp(() {
      ErrorReporterForNative().allowReporting = true;
    });

    test('is singleton', () {
      final a = ErrorReporterForNative();
      final b = ErrorReporterForNative();
      expect(identical(a, b), isTrue);
    });

    test('allowReporting defaults to true', () {
      expect(ErrorReporterForNative().allowReporting, isTrue);
    });

    test('reportError completes without throwing when not initialized',
        () async {
      await expectLater(
        ErrorReporterForNative().reportError(Exception('test'), null),
        completes,
      );
    });
  });

  group('ErrorReporterConfig', () {
    setUp(() {
      ErrorReporterConfig().maxRetries = 0;
      ErrorReporterConfig().baseDelay = const Duration(seconds: 1);
      ErrorReporterConfig().maxJitter = const Duration(milliseconds: 500);
      ErrorReporterConfig().retryCondition = null;
    });

    test('is singleton', () {
      final a = ErrorReporterConfig();
      final b = ErrorReporterConfig();
      expect(identical(a, b), isTrue);
    });

    test('defaults to no retries', () {
      expect(ErrorReporterConfig().maxRetries, 0);
    });

    test('default baseDelay is 1 second', () {
      expect(ErrorReporterConfig().baseDelay, const Duration(seconds: 1));
    });

    test('default maxJitter is 500 milliseconds', () {
      expect(
          ErrorReporterConfig().maxJitter, const Duration(milliseconds: 500));
    });

    test('default retryCondition is null', () {
      expect(ErrorReporterConfig().retryCondition, isNull);
    });

    test('can update maxRetries', () {
      ErrorReporterConfig().maxRetries = 3;
      expect(ErrorReporterConfig().maxRetries, 3);
    });

    test('can set retryCondition', () {
      bool called = false;
      ErrorReporterConfig().retryCondition = (url, res, error) {
        called = true;
        return false;
      };
      ErrorReporterConfig().retryCondition!(
          'https://example.com',
          ServerResponse(null, EnumServerResponseStatus.otherError, null, null),
          null);
      expect(called, isTrue);
    });
  });
}
