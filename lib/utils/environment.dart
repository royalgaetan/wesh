import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Environment {
  static String prodPackageName = "com.wesh.android";
  static String prodEnvFilename = ".env.prod";

  static String devPackageName = "dev.wesh.android";
  static String devEnvFilename = ".env.dev";

  // Depending on the current app flavor: return the appropriate .env file
  static Future<String> get filename async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // If Flavor == prod
      if (packageInfo.packageName == prodPackageName) {
        return prodEnvFilename;
      }
      // If Flavor == dev
      if (packageInfo.packageName == devPackageName) {
        return devEnvFilename;
      } else {
        // Else return only dev Flavor
        return devEnvFilename;
      }
    } catch (e) {
      // Else catch error
      debugPrint('An error occured with .env files: $e');
      // And return only dev Flavor
      return devEnvFilename;
    }
  }

  // Return test var from .env: depending on the current app flavor
  static String get testVar {
    return dotenv.get('TEST_VAR', fallback: 'No test var found');
  }
}
