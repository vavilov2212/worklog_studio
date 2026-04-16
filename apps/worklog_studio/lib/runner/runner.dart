import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:l/l.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:worklog_studio/core/environment/app_environment.dart';
import 'package:worklog_studio/core/environment/dotenv.dart';
import 'package:worklog_studio/core/services/service_locator/service_locator.dart';
import 'package:worklog_studio/entity/session/data/repository/session_storage_repository.dart';
import 'package:worklog_studio/entity/user/data/repository/user_repository.dart';
import 'package:worklog_studio/feature/app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:worklog_studio/feature/app/layout/app_bar/app_bar_service.dart';
import 'package:worklog_studio/firebase_options.dart';
import 'package:worklog_studio_style_system/ui_kit/ui_kit.dart';

import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:worklog_studio/feature/desktop/presentation/mini_app.dart';

Future<void> run(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    runApp(MiniApp(windowId: windowId, argument: argument));
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔑 ВАЖНО: для desktop / VM
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  if (kIsWeb) {
    usePathUrlStrategy();
  }
  _initDependencies();
  _initRepositories();

  runApp(App());
}

void _initDependencies() async {
  _initDotEnv();
  await configureDependencies();
}

void _initRepositories() {
  try {
    getIt.registerSingleton<SessionStorageRepository>(
      SessionStorageRepository(),
    );
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(getIt<SessionStorageRepository>()),
    );

    getIt.registerSingleton(AppBarService());
    getIt.registerSingleton<DrawerService>(DrawerService());
  } on Object catch (e, stackTrace) {
    l.e(e, stackTrace);
    rethrow;
  }
}

void _initDotEnv() {
  final config = appEnvironment.config;
  appEnvironment.config = config.copyWith(
    url: DotEnv.apiHost,
    jwtSecret: DotEnv.jwtSecret,
  );
}
