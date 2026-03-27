import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({required this.baseUrl, this.ec2ControlBaseUrl});

  final String baseUrl;
  final String? ec2ControlBaseUrl;

  bool get isBaseUrlConfigured {
    final value = baseUrl.trim().toLowerCase();
    return value.isNotEmpty && !value.contains('your_ec2_public_ip_or_domain');
  }

  Map<String, dynamic> _configError() {
    return {
      'success': false,
      'message':
          'Set your real server URL in lib/config.dart (AppConfig.baseUrl).',
    };
  }

  Map<String, dynamic> _ec2ConfigError() {
    return {
      'success': false,
      'message':
          'Set AppConfig.lambdaEc2ControlBaseUrl in lib/config.dart for EC2 control.',
    };
  }

  Uri _uri(String endpoint) => Uri.parse('$baseUrl/$endpoint');

  bool get _isEc2ControlUrlConfigured {
    final value = (ec2ControlBaseUrl ?? '').trim().toLowerCase();
    return value.isNotEmpty && !value.contains('your_api_id');
  }

  Uri _ec2ControlUri(String action) => Uri.parse(
      '${ec2ControlBaseUrl!.replaceAll(RegExp(r'/$'), '')}/ec2/$action');

  Uri _ec2FunctionActionUri(String action) => Uri.parse(
      '${ec2ControlBaseUrl!.replaceAll(RegExp(r'/$'), '')}/HauPokemon_EC2_Lambda?action=$action');

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      return {
        'success': false,
        'message': 'Invalid API format: expected JSON object.'
      };
    } catch (_) {
      return {
        'success': false,
        'message':
            'Server returned non-JSON response (HTTP ${response.statusCode}).',
      };
    }
  }

  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    if (!isBaseUrlConfigured) {
      return _configError();
    }
    try {
      final response = await http.post(
        _uri(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final decoded = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        decoded['success'] = false;
        decoded['message'] =
            decoded['message'] ?? 'HTTP error ${response.statusCode}';
      }
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> _postUri(
      Uri uri, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final decoded = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        decoded['success'] = false;
        decoded['message'] =
            decoded['message'] ?? 'HTTP error ${response.statusCode}';
      }
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    if (!isBaseUrlConfigured) {
      return _configError();
    }
    try {
      final response = await http.get(_uri(endpoint));

      final decoded = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        decoded['success'] = false;
        decoded['message'] =
            decoded['message'] ?? 'HTTP error ${response.statusCode}';
      }
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> _getUri(Uri uri) async {
    try {
      final response = await http.get(uri);

      final decoded = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        decoded['success'] = false;
        decoded['message'] =
            decoded['message'] ?? 'HTTP error ${response.statusCode}';
      }
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String playerName,
    required String username,
    required String password,
  }) {
    return _post('auth/register.php', {
      'player_name': playerName,
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) {
    return _post('auth/login.php', {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String playerName,
    required String username,
    required String newPassword,
  }) {
    return _post('auth/forgot_password.php', {
      'player_name': playerName,
      'username': username,
      'new_password': newPassword,
    });
  }

  Future<Map<String, dynamic>> playersCreate({
    required String playerName,
    required String username,
    required String password,
  }) {
    return _post('players/create.php', {
      'player_name': playerName,
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> playersRead() => _get('players/read.php');

  Future<Map<String, dynamic>> playersUpdate({
    required int playerId,
    required String playerName,
    required String username,
    required String password,
  }) {
    return _post('players/update.php', {
      'player_id': playerId,
      'player_name': playerName,
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> playersDelete({required int playerId}) {
    return _post('players/delete.php', {'player_id': playerId});
  }

  Future<Map<String, dynamic>> monstersCreate({
    required String monsterName,
    required String type,
    required double latitude,
    required double longitude,
    required double radius,
    required String picture,
  }) {
    return _post('monsters/create.php', {
      'monster_name': monsterName,
      'monster_type': type,
      'spawn_latitude': latitude,
      'spawn_longitude': longitude,
      'spawn_radius_meters': radius,
      'picture_url': picture,
    });
  }

  Future<Map<String, dynamic>> monstersRead() => _get('monsters/read.php');

  Future<Map<String, dynamic>> monstersUpdate({
    required int monsterId,
    required String monsterName,
    required String type,
    required double latitude,
    required double longitude,
    required double radius,
    required String picture,
  }) {
    return _post('monsters/update.php', {
      'monster_id': monsterId,
      'monster_name': monsterName,
      'monster_type': type,
      'spawn_latitude': latitude,
      'spawn_longitude': longitude,
      'spawn_radius_meters': radius,
      'picture_url': picture,
    });
  }

  Future<Map<String, dynamic>> monstersDelete({required int monsterId}) {
    return _post('monsters/delete.php', {'monster_id': monsterId});
  }

  Future<Map<String, dynamic>> catchMonster({
    required int playerId,
    required int monsterId,
    required double latitude,
    required double longitude,
  }) {
    return _post('catch/catch_monster.php', {
      'player_id': playerId,
      'monster_id': monsterId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> leaderboard() => _get('leaderboard/top10.php');

  Future<Map<String, dynamic>> ec2Start() {
    if (ec2ControlBaseUrl == null) return _post('ec2/start.php', {});
    if (!_isEc2ControlUrlConfigured) return Future.value(_ec2ConfigError());
    return _ec2LambdaAwareCall(
      primaryCall: () => _postUri(_ec2ControlUri('start'), {}),
      fallbackCall: () => _getUri(_ec2FunctionActionUri('start')),
    );
  }

  Future<Map<String, dynamic>> ec2Stop() {
    if (ec2ControlBaseUrl == null) return _post('ec2/stop.php', {});
    if (!_isEc2ControlUrlConfigured) return Future.value(_ec2ConfigError());
    return _ec2LambdaAwareCall(
      primaryCall: () => _postUri(_ec2ControlUri('stop'), {}),
      fallbackCall: () => _getUri(_ec2FunctionActionUri('stop')),
    );
  }

  Future<Map<String, dynamic>> ec2Status() {
    if (ec2ControlBaseUrl == null) return _get('ec2/status.php');
    if (!_isEc2ControlUrlConfigured) return Future.value(_ec2ConfigError());
    return _ec2LambdaAwareCall(
      primaryCall: () => _getUri(_ec2ControlUri('status')),
      fallbackCall: () => _getUri(_ec2FunctionActionUri('status')),
    );
  }

  Future<Map<String, dynamic>> _ec2LambdaAwareCall({
    required Future<Map<String, dynamic>> Function() primaryCall,
    required Future<Map<String, dynamic>> Function() fallbackCall,
  }) async {
    final primary = await primaryCall();

    final msg = (primary['message'] ?? '').toString().toLowerCase();
    final looksLikeRouteMissing =
        msg.contains('http 404') || msg.contains('not found');

    if (primary['success'] == true || !looksLikeRouteMissing) {
      return primary;
    }

    return fallbackCall();
  }
}
