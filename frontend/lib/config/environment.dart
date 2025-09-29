import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, staging, production }

class AppEnvironment {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  static bool get enableLogging => dotenv.env['ENABLE_LOGGING'] == 'true';

  static Future<void> initialize(Environment env) async {
    _environment = env;

    String envFile;
    switch (env) {
      case Environment.development:
        envFile = '.env.dev';
        break;
      case Environment.staging:
        envFile = '.env.staging';
        break;
      case Environment.production:
        envFile = '.env.prod';
        break;
    }

    await dotenv.load(fileName: envFile);
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}