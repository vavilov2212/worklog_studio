import 'package:worklog_studio/domain/time_tracker.dart';

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}
