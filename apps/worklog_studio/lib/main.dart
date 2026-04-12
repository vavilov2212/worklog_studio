import 'package:worklog_studio/core/environment/app_environment.dart';

import 'runner/runner.dart' as runner;

void main() async {
  AppEnvironment.init(config: const AppConfig(flavor: Flavor.production));

  await runner.run();
}
