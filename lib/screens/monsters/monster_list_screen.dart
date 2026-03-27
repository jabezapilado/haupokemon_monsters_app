import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_monster_screen.dart';
import 'add_monster_screen.dart';

class MonsterListScreen extends StatefulWidget {
  const MonsterListScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<MonsterListScreen> createState() => _MonsterListScreenState();
}

class _MonsterListScreenState extends State<MonsterListScreen> {
  bool _loading = true;
  List<dynamic> _monsters = [];
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    setState(() => _loading = true);

    final result = await widget.apiService.monstersRead();

    if (!mounted) return;

    setState(() {
      _loading = false;
      _monsters = (result['monsters'] as List<dynamic>?) ??
          (result['data'] as List<dynamic>?) ??
          [];
      _message = result['message']?.toString() ?? '';
    });
  }

  Future<void> _deleteMonster(int monsterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete Monster'),
        content: const Text('Are you sure you want to delete this monster?'),
        actionsAlignment: MainAxisAlignment.end,
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

    final result = await widget.apiService.monstersDelete(
      monsterId: monsterId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
    );

    _loadMonsters();
  }

  String _buildSubtitle(Map<String, dynamic> m) {
    final type = m['monster_type']?.toString() ?? '';
    final radius = m['spawn_radius_meters']?.toString() ?? '';
    final lat = m['spawn_latitude']?.toString() ?? '';
    final lng = m['spawn_longitude']?.toString() ?? '';

    return 'Type: $type | Radius: ${radius}m\nLat: $lat | Lng: $lng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monster Management'),
        actions: [
          IconButton(
            onPressed: _loadMonsters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMonsterScreen(apiService: widget.apiService),
            ),
          );
          _loadMonsters();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _monsters.isEmpty
              ? Center(
                  child: Text(
                    _message.isEmpty ? 'No monsters found' : _message,
                  ),
                )
              : ListView.builder(
                  itemCount: _monsters.length,
                  itemBuilder: (context, index) {
                    final m = Map<String, dynamic>.from(_monsters[index]);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          m['monster_name']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_buildSubtitle(m)),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Edit Monster',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditMonsterScreen(
                                      apiService: widget.apiService,
                                      monster: m,
                                    ),
                                  ),
                                );
                                _loadMonsters();
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Delete Monster',
                              onPressed: () => _deleteMonster(
                                int.parse(m['monster_id'].toString()),
                              ),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
