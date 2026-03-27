import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_player_screen.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  bool _loading = true;
  String _message = '';
  List<dynamic> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _loading = true;
    });

    final result = await widget.apiService.playersRead();
    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
      _players = (result['players'] as List<dynamic>?) ?? (result['data'] as List<dynamic>?) ?? [];
    });
  }

  Future<void> _deletePlayer(int playerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Player'),
        content: const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await widget.apiService.playersDelete(playerId: playerId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
    );
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player List'),
        actions: [
          IconButton(onPressed: _loadPlayers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? Center(child: Text(_message.isEmpty ? 'No players found' : _message))
              : ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final p = _players[index] as Map<String, dynamic>;
                    final playerId = int.parse(p['player_id'].toString());

                    return ListTile(
                      title: Text(p['player_name']?.toString() ?? ''),
                      subtitle: Text(p['username']?.toString() ?? ''),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPlayerScreen(
                                    apiService: widget.apiService,
                                    player: p,
                                  ),
                                ),
                              );
                              _loadPlayers();
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => _deletePlayer(playerId),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
