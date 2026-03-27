import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_chrome.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.apiService});

  static const routeName = '/register';

  final ApiService apiService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _playerNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _message = '';

  Future<void> _register() async {
    final playerName = _playerNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (playerName.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Player name, username, and password are required.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.register(
      playerName: playerName,
      username: username,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registration successful. Please log in.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HauPokemon')),
      body: AtmosphereBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SoftPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Create Your Trainer Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.deepTeal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Register to manage monsters, catch them, and join the leaderboard.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _playerNameController,
                        decoration:
                            const InputDecoration(labelText: 'Player Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 14),
                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _register,
                              child: const Text('Register'),
                            ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login'),
                      ),
                      if (_message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
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
