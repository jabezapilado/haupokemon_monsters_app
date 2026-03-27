import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EC2ControlScreen extends StatefulWidget {
  const EC2ControlScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  State<EC2ControlScreen> createState() => _EC2ControlScreenState();
}

class _EC2ControlScreenState extends State<EC2ControlScreen> {
  String _state = 'unknown';
  String _message = '';
  bool _loading = false;
  Timer? _pollTimer;

  bool get _configured => widget.apiService.isBaseUrlConfigured;

  bool get _isRunning => _state.toLowerCase() == 'running';
  bool get _isStopped => _state.toLowerCase() == 'stopped';
  bool get _isTransitioning =>
      _state.toLowerCase() == 'pending' || _state.toLowerCase() == 'stopping';

  Color _stateColor() {
    switch (_state.toLowerCase()) {
      case 'running':
        return Colors.green.shade700;
      case 'stopped':
        return Colors.red.shade700;
      case 'pending':
      case 'stopping':
        return Colors.orange.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  IconData _stateIcon() {
    switch (_state.toLowerCase()) {
      case 'running':
        return Icons.check_circle;
      case 'stopped':
        return Icons.cancel;
      case 'pending':
      case 'stopping':
        return Icons.sync;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_configured) {
      _refreshStatus(showLoader: true);
      _startAutoRefresh();
    } else {
      _message = 'Set AppConfig.baseUrl first, then reopen this page.';
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && !_loading && _configured) {
        _refreshStatus(showLoader: false);
      }
    });
  }

  Future<void> _refreshStatus({bool showLoader = true}) async {
    if (!_configured) {
      setState(() {
        _message = 'Set AppConfig.baseUrl first, then reopen this page.';
      });
      return;
    }

    if (showLoader) {
      setState(() => _loading = true);
    }

    final result = await widget.apiService.ec2Status();

    if (!mounted) return;

    setState(() {
      _loading = false;
      _state = result['instance_state']?.toString() ?? 'unknown';
      _message = result['message']?.toString() ??
          (result['success'] == true
              ? 'Instance status loaded.'
              : 'Failed to load instance status.');
    });
  }

  Future<void> _start() async {
    if (!_configured) {
      setState(() {
        _message = 'Set AppConfig.baseUrl first, then reopen this page.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.ec2Start();

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ??
          (result['success'] == true
              ? 'Start command sent.'
              : 'Failed to start instance.');
    });

    await Future.delayed(const Duration(seconds: 2));
    await _refreshStatus(showLoader: false);
  }

  Future<void> _stop() async {
    if (!_configured) {
      setState(() {
        _message = 'Set AppConfig.baseUrl first, then reopen this page.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.ec2Stop();

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ??
          (result['success'] == true
              ? 'Stop command sent.'
              : 'Failed to stop instance.');
    });

    await Future.delayed(const Duration(seconds: 2));
    await _refreshStatus(showLoader: false);
  }

  Future<void> _confirmAndStop() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Turn Off EC2?'),
          content: const Text(
            'If EC2 is turned off, login and most app features will not work until EC2 is turned on again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Turn Off'),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      await _stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _stateColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EC2 Control'),
        actions: [
          IconButton(
            onPressed: _configured && !_loading ? () => _refreshStatus() : null,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EC2 Instance Status',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(_stateIcon(), color: statusColor, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          _state.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRunning
                          ? 'The EC2 instance is currently running.'
                          : _isStopped
                              ? 'The EC2 instance is currently stopped.'
                              : _isTransitioning
                                  ? 'The EC2 instance is changing state.'
                                  : 'The EC2 instance state is unknown.',
                      style: TextStyle(color: Colors.blueGrey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_isStopped)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EC2 is OFF. The app backend is unavailable.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Turn on EC2 from this page to restore login and other online features.',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ],
                  ),
                ),
              if (_isStopped) const SizedBox(height: 14),
              if (!_configured)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    'Backend URL is not configured. Open lib/config.dart and set AppConfig.baseUrl.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!_configured) const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ElevatedButton.icon(
                        onPressed:
                            _configured && !_isRunning && !_isTransitioning
                                ? _start
                                : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start EC2'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed:
                            _configured && !_isStopped && !_isTransitioning
                                ? _confirmAndStop
                                : null,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Stop EC2'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _configured ? () => _refreshStatus() : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Status'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Text(
                  _message.isEmpty ? 'Waiting for action...' : _message,
                  style: TextStyle(
                    color: _message.toLowerCase().contains('failed') ||
                            _message.toLowerCase().contains('not configured')
                        ? Colors.red.shade700
                        : Colors.blueGrey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
