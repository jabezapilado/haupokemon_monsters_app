import 'dart:io' show Platform;

class AppConfig {
  // Set ONE mode to true when you are ready.
  static const bool useAws = false;
  static const bool useTailscale = true;
  static const bool useLambdaEc2Control = true;

  // AWS public endpoint (example: http://52.10.20.30/api)
  static const String awsBaseUrl = 'http://13.39.66.13/api';

  // Tailscale endpoint (example: http://100.101.102.103/api)
  static const String tailscaleBaseUrl = 'http://100.108.139.85/api';

  // API Gateway base URL for EC2 control via Lambda.
  // Example: https://abc123.execute-api.eu-west-3.amazonaws.com/prod
  static const String lambdaEc2ControlBaseUrl =
      'https://5yjbyofkjk.execute-api.eu-west-3.amazonaws.com/HauPokemon_Lambda_Stage';

  // Local backend on your Mac while debugging on physical phones.
  static const String localLanBaseUrl = 'http://192.168.0.136/api';

  static String get baseUrl {
    if (useAws) return awsBaseUrl;
    if (useTailscale) return tailscaleBaseUrl;

    // For Android emulator only, use 10.0.2.2 to reach host machine.
    if (Platform.isAndroid) {
      return localLanBaseUrl;
    }

    return localLanBaseUrl;
  }

  static String? get ec2ControlBaseUrl {
    if (!useLambdaEc2Control) return null;
    return lambdaEc2ControlBaseUrl;
  }
}
