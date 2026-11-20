import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OMDB_BASE_URL')
  static const String omdbBaseUrl = _Env.omdbBaseUrl;

  @EnviedField(varName: 'OMDB_API_KEY', obfuscate: true)
  static final String omdbApiKey = _Env.omdbApiKey;
}
