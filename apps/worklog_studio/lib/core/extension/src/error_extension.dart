import 'package:flutter/widgets.dart';
import 'package:worklog_studio/core/error/error_handler.dart';

extension ErrorExtension on IErrorHandler {
  String messageFromError(BuildContext context) =>
      when(unknown: (_) => 'unknown error');
}
