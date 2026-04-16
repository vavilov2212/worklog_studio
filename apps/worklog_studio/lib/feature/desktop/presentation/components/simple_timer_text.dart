import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class SimpleTimerText extends StatefulWidget {
  final DateTime? startTime;
  final TextStyle? style;

  const SimpleTimerText({
    super.key,
    this.startTime,
    this.style,
  });

  @override
  State<SimpleTimerText> createState() => _SimpleTimerTextState();
}

class _SimpleTimerTextState extends State<SimpleTimerText> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(SimpleTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime) {
      if (widget.startTime != null) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateElapsed();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _elapsed = Duration.zero;
      });
    }
  }

  void _updateElapsed() {
    if (widget.startTime != null) {
      _elapsed = DateTime.now().difference(widget.startTime!);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      _formatDuration(_elapsed),
      style: widget.style ??
          theme.commonTextStyles.body.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}
