import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _loading = true;
  List<dynamic> _leaderboard = [];
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);

    final result = await widget.apiService.leaderboard();

    if (!mounted) return;

    setState(() {
      _loading = false;
      _leaderboard = (result['leaderboard'] as List<dynamic>?) ??
          (result['data'] as List<dynamic>?) ??
          [];
      _message = result['message']?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Monster Hunters'),
        actions: [
          IconButton(
            onPressed: _loadLeaderboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
              ? Center(
                  child: Text(
                    _message.isEmpty ? 'No leaderboard data yet' : _message,
                  ),
                )
              : ListView.separated(
                  itemCount: _leaderboard.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = Map<String, dynamic>.from(_leaderboard[index]);
                    final playerName =
                        row['player_name']?.toString() ?? 'Unknown';
                    final username = row['username']?.toString() ?? '';
                    final totalCatches =
                        row['total_catches']?.toString() ?? '0';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        playerName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: username.isEmpty ? null : Text('@$username'),
                      trailing: Text(
                        totalCatches,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
