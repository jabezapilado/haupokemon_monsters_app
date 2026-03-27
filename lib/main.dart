import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config.dart';
import 'services/api_service.dart';
import 'utils/session_manager.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/players/edit_player_screen.dart';
import 'screens/monsters/monster_list_screen.dart';
import 'screens/monsters/add_monster_screen.dart';
import 'screens/catch/catch_monster_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/ec2/ec2_control_screen.dart';
import 'widgets/app_chrome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(
      baseUrl: AppConfig.baseUrl,
      ec2ControlBaseUrl: AppConfig.ec2ControlBaseUrl,
    );

    return MaterialApp(
      title: 'HauPokemon',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.ocean,
          primary: AppPalette.ocean,
          secondary: AppPalette.coral,
          surface: AppPalette.card,
        ),
        scaffoldBackgroundColor: AppPalette.sand,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: AppPalette.deepTeal,
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            color: AppPalette.deepTeal,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.ocean,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.85),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: AuthGate(apiService: apiService),
      routes: {
        RegisterScreen.routeName: (context) =>
            RegisterScreen(apiService: apiService),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return ServerAccessGate(apiService: apiService);
  }
}

class ServerAccessGate extends StatefulWidget {
  const ServerAccessGate({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<ServerAccessGate> createState() => _ServerAccessGateState();
}

class _ServerAccessGateState extends State<ServerAccessGate> {
  bool _checking = true;
  bool _starting = false;
  bool _continueToApp = false;
  String _status = 'unknown';
  String _message = 'Checking server status...';

  bool get _isRunning => _status == 'running';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (!mounted) return;
    setState(() {
      _checking = true;
      _message = 'Checking server status...';
    });

    final result = await widget.apiService.ec2Status();
    final status = (result['instance_state']?.toString() ?? 'unknown')
        .trim()
        .toLowerCase();

    if (!mounted) return;
    setState(() {
      _status = status;
      _checking = false;
      _message = result['message']?.toString() ??
          (_isRunning ? 'Server is online.' : 'Server is offline.');
    });
  }

  Future<void> _startServer() async {
    if (!mounted) return;
    setState(() {
      _starting = true;
      _message = 'Sending start command...';
    });

    final result = await widget.apiService.ec2Start();

    if (!mounted) return;
    setState(() {
      _message =
          result['message']?.toString() ?? 'Start command sent. Waiting...';
    });

    for (int attempt = 0; attempt < 20; attempt++) {
      await Future.delayed(const Duration(seconds: 3));
      final statusResult = await widget.apiService.ec2Status();
      final status = (statusResult['instance_state']?.toString() ?? 'unknown')
          .trim()
          .toLowerCase();

      if (!mounted) return;
      if (status == 'running') {
        setState(() {
          _status = status;
          _starting = false;
          _message = 'Server is now online. You can continue to login.';
        });
        return;
      }

      setState(() {
        _status = status;
        _message =
            'Server state: $status. Waiting for it to become running...';
      });
    }

    if (!mounted) return;
    setState(() {
      _starting = false;
      _message =
          'Server is still not running. Try Refresh Status or Start Server again.';
    });
  }

  Future<void> _continueToLogin() async {
    if (!mounted) return;
    setState(() {
      _checking = true;
      _message = 'Verifying server status before login...';
    });

    final result = await widget.apiService.ec2Status();
    final status = (result['instance_state']?.toString() ?? 'unknown')
        .trim()
        .toLowerCase();

    if (!mounted) return;

    if (status == 'running') {
      setState(() {
        _status = status;
        _checking = false;
        _continueToApp = true;
      });
      return;
    }

    setState(() {
      _status = status;
      _checking = false;
      _message =
          'Server is $status. Start EC2 first before continuing to login.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_continueToApp) {
      return _SessionGate(apiService: widget.apiService);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('HauPokemon')),
      body: AtmosphereBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SoftPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Access Check',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.deepTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The game server must be running before login. Use the controls below to check or start EC2.',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            color: _isRunning
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current state: ${_status.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(_message),
                      if (_checking || _starting) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(minHeight: 5),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (_checking || _starting) ? null : _checkStatus,
                        child: const Text('Refresh Status'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: (_checking || _starting || _isRunning)
                            ? null
                            : _startServer,
                        child: const Text('Start Server'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            (_checking || _starting || !_isRunning)
                                ? null
                                : _continueToLogin,
                        child: const Text('Continue to Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate({required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: SessionManager.getPlayerId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginScreen(apiService: apiService);
        }
        return HomeScreen(
          apiService: apiService,
          loggedInPlayerId: snapshot.data!,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.loggedInPlayerId,
  });

  final ApiService apiService;
  final int loggedInPlayerId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showCards = false;
  String _playerName = 'Trainer';
  Map<String, dynamic>? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlayer();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _showCards = true);
      }
    });
  }

  Future<void> _loadCurrentPlayer() async {
    final result = await widget.apiService.playersRead();
    final players = (result['players'] as List<dynamic>?) ??
        (result['data'] as List<dynamic>?) ??
        [];

    for (final item in players) {
      final player = Map<String, dynamic>.from(item);
      final id = int.tryParse(player['player_id'].toString());
      if (id == widget.loggedInPlayerId) {
        if (!mounted) return;
        setState(() {
          _currentPlayer = player;
          _playerName =
              player['player_name']?.toString().trim().isNotEmpty == true
                  ? player['player_name'].toString().trim()
                  : 'Trainer';
        });
        return;
      }
    }
  }

  Future<void> _openMyAccount() async {
    Map<String, dynamic>? currentPlayer = _currentPlayer;

    if (currentPlayer == null) {
      final result = await widget.apiService.playersRead();
      final players = (result['players'] as List<dynamic>?) ??
          (result['data'] as List<dynamic>?) ??
          [];

      for (final item in players) {
        final player = Map<String, dynamic>.from(item);
        final id = int.tryParse(player['player_id'].toString());
        if (id == widget.loggedInPlayerId) {
          currentPlayer = player;
          _currentPlayer = player;
          break;
        }
      }
    }

    if (!mounted) return;

    if (currentPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your account details.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPlayerScreen(
          apiService: widget.apiService,
          player: currentPlayer!,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(apiService: widget.apiService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HauPokemon'),
        actions: [
          IconButton(
            onPressed: _openMyAccount,
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Account',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AtmosphereBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SoftPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_playerName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.deepTeal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose your mission in HauPokemon: manage monsters, catch nearby monsters, view rankings, and control EC2.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _FeatureTile(
              visible: _showCards,
              index: 0,
              title: 'Add Monsters',
              subtitle: 'Create a new monster spawn point',
              icon: Icons.add_location_alt_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddMonsterScreen(apiService: widget.apiService),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 1,
              title: 'Catch Monsters',
              subtitle: 'Use GPS to catch nearby monsters',
              icon: Icons.radar,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CatchMonsterScreen(
                    apiService: widget.apiService,
                    playerId: widget.loggedInPlayerId,
                  ),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 2,
              title: 'Edit Monsters',
              subtitle: 'Update monster details and spawn settings',
              icon: Icons.edit,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MonsterListScreen(apiService: widget.apiService),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 3,
              title: 'Delete Monsters',
              subtitle: 'Remove monster records',
              icon: Icons.delete_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MonsterListScreen(apiService: widget.apiService),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 4,
              title: 'View Top Monster Hunters',
              subtitle: 'See the leaderboard',
              icon: Icons.leaderboard,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LeaderboardScreen(apiService: widget.apiService),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 5,
              title: 'EC2 Control',
              subtitle: 'Start, stop, and monitor the instance',
              icon: Icons.cloud_circle_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EC2ControlScreen(apiService: widget.apiService),
                ),
              ),
            ),
            _FeatureTile(
              visible: _showCards,
              index: 6,
              title: 'My Account',
              subtitle: 'Edit or delete your account',
              icon: Icons.person_outline,
              onTap: _openMyAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.visible,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool visible;
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delay = (index + 1) * 90;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 340 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: visible ? 1 : 0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SoftPanel(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppPalette.ocean.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppPalette.ocean),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
