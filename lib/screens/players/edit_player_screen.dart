import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/session_manager.dart';
import '../auth/login_screen.dart';

class EditPlayerScreen extends StatefulWidget {
  const EditPlayerScreen({
    super.key,
    required this.apiService,
    required this.player,
  });

  final ApiService apiService;
  final Map<String, dynamic> player;

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.player['player_name']?.toString() ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.player['username']?.toString() ?? '',
    );
  }

  Future<void> _save() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _message = 'Password is required';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.playersUpdate(
      playerId: int.parse(widget.player['player_id'].toString()),
      playerName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(110, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(110, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.playersDelete(
      playerId: int.parse(widget.player['player_id'].toString()),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
    });

    if (result['success'] == true) {
      await SessionManager.clearSession();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(apiService: widget.apiService),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Player Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Changes'),
                  ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loading ? null : _deleteAccount,
              child: const Text('Delete My Account'),
            ),
            const SizedBox(height: 12),
            if (_message.isNotEmpty) Text(_message),
          ],
        ),
      ),
    );
  }
}
