// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_error_reporter/simple_error_reporter.dart';

// TODO: Please make sure to rewrite this URL.
const String errorReportURL = "https://your-endpoint.example.com/errors";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: configure retry behavior independently of simple_https_service globals.
  // By default, no retries are attempted (maxRetries = 0).
  // ErrorReporterConfig().maxRetries = 3;
  // ErrorReporterConfig().retryCondition = (url, res, error) {
  //   return res.resultStatus == EnumServerResponseStatus.serverError ||
  //       error != null;
  // };

  // For web or native device.
  // Automatically catches Flutter and platform errors after init.
  ErrorReporter().init(
    endpointUrl: errorReportURL,
    appName: 'Test App',
    appVersion: '1.0.0',
    extraInfo: {'platform': 'web'},
  );

  // Set this to false if you don't want to send errors until
  // the user has granted permission, then set it to true once granted.
  ErrorReporter().allowReporting = true;

  // For native device only.
  // This version can support self-signed certificates.
  // ErrorReporterForNative().init(
  //   endpointUrl: errorReportURL,
  //   appVersion: '1.0.0',
  //   extraInfo: {'platform': 'Android'},
  //   badCertificateCallback: (X509Certificate cert, String host, int port) {
  //     // TODO
  //     // The condition is checked here, and if it returns true,
  //     // self-signed certificates are allowed.
  //     return true;
  //   },
  // );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _allowReporting = true;

  // TODO: Please note that this is just a usage example and will not typically be laid out like this.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Error Reporter Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Error Reporter Example'),
          backgroundColor: const Color.fromARGB(255, 0, 255, 0),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('Allow reporting'),
                    Switch(
                      value: _allowReporting,
                      onChanged: (value) {
                        setState(() {
                          _allowReporting = value;
                          ErrorReporter().allowReporting = value;
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Manual error reporting.
                      await ErrorReporter().reportError(
                        Exception('Manual test error'),
                        StackTrace.current,
                        customExtraInfo: {'location': 'HomeScreen'},
                      );
                    },
                    child: const Text('Report error manually'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Manual error reporting with JWT authentication.
                      await ErrorReporter().reportError(
                        Exception('Auth test error'),
                        StackTrace.current,
                        getJWT: () async {
                          // TODO: Return your JWT token.
                          return 'your_access_token';
                        },
                      );
                    },
                    child: const Text('Report error with JWT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
