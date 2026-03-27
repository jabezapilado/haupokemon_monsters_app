import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/session_manager.dart';
import '../../main.dart';
import '../../widgets/app_chrome.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _message = '';

  Future<void> _showForgotPasswordDialog() async {
    final playerNameController = TextEditingController();
    final usernameController = TextEditingController();
    final newPasswordController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool resetting = false;
        String resetMessage = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              title: const Text('Forgot Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: playerNameController,
                      enableInteractiveSelection: false,
                      decoration: const InputDecoration(
                        labelText: 'Player Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: usernameController,
                      enableInteractiveSelection: false,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: newPasswordController,
                      enableInteractiveSelection: false,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                    ),
                    if (resetMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        resetMessage,
                        style: TextStyle(
                          color:
                              resetMessage.toLowerCase().contains('successful')
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              buttonPadding: EdgeInsets.zero,
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          onPressed: resetting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: resetting
                              ? null
                              : () async {
                                  final playerName =
                                      playerNameController.text.trim();
                                  final username =
                                      usernameController.text.trim();
                                  final newPassword =
                                      newPasswordController.text;

                                  if (playerName.isEmpty ||
                                      username.isEmpty ||
                                      newPassword.isEmpty) {
                                    setDialogState(() {
                                      resetMessage = 'All fields are required.';
                                    });
                                    return;
                                  }

                                  setDialogState(() {
                                    resetting = true;
                                    resetMessage = '';
                                  });

                                  final result =
                                      await widget.apiService.forgotPassword(
                                    playerName: playerName,
                                    username: username,
                                    newPassword: newPassword,
                                  );

                                  if (!mounted) return;

                                  setDialogState(() {
                                    resetting = false;
                                    resetMessage =
                                        result['message']?.toString() ?? '';
                                  });

                                  if (result['success'] == true) {
                                    _usernameController.text = username;
                                    _passwordController.clear();

                                    if (!dialogContext.mounted) return;
                                    Navigator.pop(dialogContext);

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password reset successful. Please log in.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: resetting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Username and password are required.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.login(
      username: username,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
    });

    if (result['success'] == true) {
      final playerId = result['player']?['player_id'];
      if (playerId != null) {
        await SessionManager.savePlayerId(int.parse(playerId.toString()));
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            apiService: widget.apiService,
            loggedInPlayerId: int.parse(playerId.toString()),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
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
                          'Welcome to HauPokemon',
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
                        child: Text('Sign in to continue your monster hunt.'),
                      ),
                      const SizedBox(height: 16),
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
                              onPressed: _login,
                              child: const Text('Login'),
                            ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              apiService: widget.apiService,
                            ),
                          ),
                        ),
                        child: const Text('No account? Register'),
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text('Forgot password?'),
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
