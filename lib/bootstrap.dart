import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/di.dart';
import 'firebase_options.dart';

/// App entry point: initializes bindings, Firebase (best effort), Crashlytics
/// hooks, and dependency injection, then runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebaseAndCrashlytics();

  registerDependencies();

  runApp(const DaftariApp());
}

/// Initializes Firebase and Crashlytics error hooks.
///
/// Offline first: a failure here (for example no network, or missing native
/// configuration) must never prevent the app from running, so every error is
/// swallowed after the hooks are best-effort installed.
Future<void> _initializeFirebaseAndCrashlytics() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Rule R6: never report user data. Only the error type and the stack
    // trace are reported, never exception messages that may contain
    // customer names, phone numbers, or amounts.
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error.runtimeType.toString(),
        stackTrace,
      );
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
  } on Object {
    // Firebase or Crashlytics are optional; the app works fully offline.
  }
}
