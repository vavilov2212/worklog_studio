import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio/core/environment/app_environment.dart';
import 'package:worklog_studio/feature/app/layout/app_bar/app_bar.dart';
import 'package:worklog_studio/feature/app/layout/scaffold/app_scaffold.dart';
import 'package:worklog_studio/feature/work_log/presentation/work_log_raw_data_scope.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';
// import 'package:worklog_studio_style_system/ui_kit/src/select/index.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class WelcomeLayout extends StatefulWidget {
  const WelcomeLayout({super.key});

  @override
  State<WelcomeLayout> createState() => WelcomeLayoutState();
}

class WelcomeLayoutState extends State<WelcomeLayout> {
  final _textController = TextEditingController();
  final popoverController = PopoverController();
  late TimeTrackerState state;

  String? formatDuration(Duration? d) {
    if (d == null) return null;

    String two(int n) => n.toString().padLeft(2, '0');

    final hours = two(d.inHours);
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  @override
  void initState() {
    state = context.read<TimeTrackerState>();
    _textController.text = state.activeEntry?.comment ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _state = context.watch<TimeTrackerState>();
    return AppBarProvider(
      config: AppBarConfig(
        title: Text(AppEnvironment.instance().config.flavor.appTitle),
      ),

      child: AppScaffold(
        body: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.green),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Status
                          Text(
                            _state.isRunning ? 'RUNNING' : 'STOPPED',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          const SizedBox(height: 16),

                          // Elapsed
                          Text(
                            formatDuration(_state.elapsed) ?? '',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),

                          const SizedBox(height: 32),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _state.isRunning
                                    ? null
                                    : () async {
                                        await _state.start();
                                      },
                                child: const Text('Start'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _state.isRunning
                                    ? () async {
                                        await _state.stop();
                                      }
                                    : null,
                                child: const Text('Stop'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          Row(
                            spacing: context.theme.spacings.s16,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PopoverPrimitive(
                                controller: popoverController,
                                onRequestClose: popoverController.hide,
                                width: 520, // Меню шире, чем триггер
                                trigger: PrimaryButton(
                                  type: ButtonType.secondary,
                                  title: 'Comment',
                                  onTap: popoverController.toggle,
                                ),
                                contentBuilder: (context) {
                                  return PopoverSurface(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextArea(
                                          hintText: 'hintText',
                                          controller: _textController,
                                        ),
                                        PrimaryButton(
                                          title: 'Save',
                                          onTap: () => _state.updateActive(
                                            comment: _textController.text,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Column(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: [
                                    //     _menuItem(Icons.edit, "Edit task", context),
                                    //     _menuItem(Icons.copy, "Duplicate", context),
                                    //     const Divider(height: 1),
                                    //     _menuItem(
                                    //       Icons.delete,
                                    //       "Delete",
                                    //       context,
                                    //       isDestructive: true,
                                    //     ),
                                    //   ],
                                    // ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 200,
                                child: Select<String>(
                                  onChanged: (value) =>
                                      _state.updateActive(projectId: value),
                                  searchable: true,
                                  placeholder: 'Select project',
                                  value: _state.activeEntry?.projectId,
                                  options: [
                                    SelectOption(
                                      value: 'value',
                                      label: 'label1',
                                    ),
                                    SelectOption(
                                      value: 'value',
                                      label: 'label2',
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: 200,
                                child: Select<String>(
                                  onChanged: (value) =>
                                      _state.updateActive(taskId: value),
                                  searchable: true,
                                  placeholder: 'Select task',
                                  value: _state.activeEntry?.taskId,
                                  options: [
                                    SelectOption(
                                      value: 'value',
                                      label: 'label1',
                                    ),
                                    SelectOption(
                                      value: 'value',
                                      label: 'label2',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PrimaryButton(
                          onTap: () {
                            WorkLogRawDataScope.load(context);
                          },
                          title: 'Выбрать сессию',
                        ),
                      ),
                    ),
                    Text('_state.entries.length ${_state.entries.length}'),
                    Expanded(
                      child: _state.entries.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final entry = _state.entries[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: BoxBorder.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    color: index != index
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Project: ${entry.projectId}'),
                                          Text('Task: ${entry.taskId}'),
                                          Text('Started at: ${entry.startAt}'),
                                          Text('Status: ${entry.status}'),
                                          Text('Comment: ${entry.comment}'),
                                          entry.endAt != null
                                              ? Text(
                                                  'Duration: ${formatDuration(_state.calculateDuration(entry.startAt, entry.endAt))}',
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, _) =>
                                  SizedBox(height: 12),
                              itemCount: _state.entries.length,
                            )
                          : Text('Empty'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _menuItem(
//   IconData icon,
//   String text,
//   BuildContext context, {
//   bool isDestructive = false,
// }) {
//   return InkWell(
//     onTap: () {
//       /* Logic */
//     },
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 18,
//             color: isDestructive ? Colors.red : Colors.black87,
//           ),
//           const SizedBox(width: 12),
//           Text(
//             text,
//             style: TextStyle(
//               color: isDestructive ? Colors.red : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
