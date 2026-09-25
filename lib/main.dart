import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'core/logging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) => logFailure(
    'flutter.unhandled',
    details.exception,
    details.stack ?? StackTrace.current,
  );
  PlatformDispatcher.instance.onError = (error, stack) {
    logFailure('platform.unhandled', error, stack);
    return true;
  };
  runApp(const DoeverBootstrap());
}
