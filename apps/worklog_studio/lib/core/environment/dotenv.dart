import 'package:envied/envied.dart';

part 'dotenv.g.dart';

@Envied(path: '.env')
abstract class DotEnv {
  @EnviedField(varName: 'API_HOST')
  static const String apiHost = _DotEnv.apiHost;
  @EnviedField(varName: 'JWT_SECRET', obfuscate: true)
  static String jwtSecret = _DotEnv.jwtSecret;
  @EnviedField(varName: 'SECURE_KEY', obfuscate: true)
  static String secureKey = _DotEnv.secureKey;
}
