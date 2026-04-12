import 'package:worklog_studio/entity/session/domain/i_input_storage.dart';

import 'input_storage.stub.dart'
    if (dart.library.html) 'input_storage.web.dart';
// if (dart.library.io) 'input_storage.platforms.dart';

InputStorage createInputStorage() => getInputStorage();
