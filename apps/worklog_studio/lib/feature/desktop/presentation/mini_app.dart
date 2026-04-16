import 'package:flutter/material.dart';
import 'package:worklog_studio/core/environment/app_environment.dart';
import 'package:worklog_studio/feature/desktop/presentation/mini_panel.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/feature/desktop/bloc/mini_tracker_cubit.dart';

class MiniApp extends StatelessWidget {
  final int windowId;
  final Map<String, dynamic> argument;

  const MiniApp({
    super.key,
    required this.windowId,
    required this.argument,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MiniTrackerCubit(windowId: windowId),
      child: MaterialApp(
        title: 'Worklog Mini',
        debugShowCheckedModeBanner: false,
        theme: appEnvironment.config.lightTheme,
        home: const MiniPanel(),
      ),
    );
  }
}
