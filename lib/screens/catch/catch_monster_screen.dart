import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:torch_light/torch_light.dart';

import '../../services/api_service.dart';

class CatchMonsterScreen extends StatefulWidget {
  const CatchMonsterScreen({
    super.key,
    required this.apiService,
    required this.playerId,
  });

  final ApiService apiService;
  final int playerId;

  @override
  State<CatchMonsterScreen> createState() => _CatchMonsterScreenState();
}

class _CatchMonsterScreenState extends State<CatchMonsterScreen> {
  static const Duration _catchAudioDuration = Duration(milliseconds: 5000);
  static const int _catchAudioBpm = 90;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingEffects = false;
  Duration? _cachedWaveformOnsetDelay;

  Duration get _beatDuration {
    final millisPerBeat = (60000 / _catchAudioBpm).round();
    return Duration(milliseconds: millisPerBeat);
  }

  Duration get _halfBeatDuration {
    final halfBeatMillis = (_beatDuration.inMilliseconds / 2).round();
    return Duration(milliseconds: halfBeatMillis.clamp(80, 400));
  }

  int _readUint32LE(ByteData data, int offset) {
    return data.getUint32(offset, Endian.little);
  }

  int _readUint16LE(ByteData data, int offset) {
    return data.getUint16(offset, Endian.little);
  }

  bool _matchesChunkId(Uint8List bytes, int offset, String id) {
    if (offset + 4 > bytes.length) return false;
    return bytes[offset] == id.codeUnitAt(0) &&
        bytes[offset + 1] == id.codeUnitAt(1) &&
        bytes[offset + 2] == id.codeUnitAt(2) &&
        bytes[offset + 3] == id.codeUnitAt(3);
  }

  Duration _estimateWavOnsetDelay(Uint8List wavBytes) {
    if (wavBytes.length < 44) return Duration.zero;
    if (!_matchesChunkId(wavBytes, 0, 'RIFF') ||
        !_matchesChunkId(wavBytes, 8, 'WAVE')) {
      return Duration.zero;
    }

    final byteData = ByteData.sublistView(wavBytes);
    var offset = 12;
    var audioFormat = 0;
    var channels = 0;
    var sampleRate = 0;
    var bitsPerSample = 0;
    var dataOffset = -1;
    var dataSize = 0;

    while (offset + 8 <= wavBytes.length) {
      final chunkSize = _readUint32LE(byteData, offset + 4);
      final chunkDataStart = offset + 8;
      final chunkDataEnd = chunkDataStart + chunkSize;
      if (chunkDataEnd > wavBytes.length) break;

      if (_matchesChunkId(wavBytes, offset, 'fmt ')) {
        if (chunkSize >= 16) {
          audioFormat = _readUint16LE(byteData, chunkDataStart);
          channels = _readUint16LE(byteData, chunkDataStart + 2);
          sampleRate = _readUint32LE(byteData, chunkDataStart + 4);
          bitsPerSample = _readUint16LE(byteData, chunkDataStart + 14);
        }
      } else if (_matchesChunkId(wavBytes, offset, 'data')) {
        dataOffset = chunkDataStart;
        dataSize = chunkSize;
        break;
      }

      offset = chunkDataEnd + (chunkSize.isOdd ? 1 : 0);
    }

    if (audioFormat != 1 || bitsPerSample != 16 || channels <= 0) {
      return Duration.zero;
    }
    if (sampleRate <= 0 || dataOffset < 0 || dataSize <= 0) {
      return Duration.zero;
    }

    final bytesPerFrame = channels * 2;
    final frameCount = dataSize ~/ bytesPerFrame;
    if (frameCount <= 0) return Duration.zero;

    const amplitudeThreshold = 1200;
    final requiredSustainFrames =
        ((sampleRate * 20) / 1000).round().clamp(1, frameCount);
    var sustainedCount = 0;

    for (var frame = 0; frame < frameCount; frame++) {
      final frameOffset = dataOffset + (frame * bytesPerFrame);
      var peakAmplitude = 0;

      for (var ch = 0; ch < channels; ch++) {
        final sampleOffset = frameOffset + (ch * 2);
        final amplitude = byteData.getInt16(sampleOffset, Endian.little).abs();
        if (amplitude > peakAmplitude) {
          peakAmplitude = amplitude;
        }
      }

      if (peakAmplitude >= amplitudeThreshold) {
        sustainedCount++;
      } else {
        sustainedCount = 0;
      }

      if (sustainedCount >= requiredSustainFrames) {
        final onsetFrame = frame - sustainedCount + 1;
        final onsetMs = ((onsetFrame * 1000) / sampleRate).round();
        return Duration(milliseconds: onsetMs.clamp(0, 3000));
      }
    }

    return Duration.zero;
  }

  Future<Duration> _getWaveformOnsetDelay() async {
    if (_cachedWaveformOnsetDelay != null) {
      return _cachedWaveformOnsetDelay!;
    }

    try {
      final data = await rootBundle.load('assets/audio/monster_catched.wav');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      _cachedWaveformOnsetDelay = _estimateWavOnsetDelay(bytes);
    } catch (_) {
      _cachedWaveformOnsetDelay = Duration.zero;
    }

    return _cachedWaveformOnsetDelay!;
  }

  bool _loading = false;
  Position? _currentPosition;
  Map<String, dynamic>? _detectedMonster;
  double? _detectedDistance;
  String _status = 'Press Detect Monsters to scan nearby monsters.';

  @override
  void initState() {
    super.initState();
    _refreshLocation();
  }

  Future<Position?> _getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = 'Location service is disabled.';
      });
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _status = 'Location permission was denied.';
      });
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status =
            'Location permission is permanently denied. Enable it in device settings.';
      });
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _loading = true;
      _status = 'Getting GPS location...';
    });

    final position = await _getLocation();
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      _loading = false;
      if (position != null) {
        _status = 'Location updated. You can now detect monsters.';
      }
    });
  }

  Future<void> _playCatchEffects() async {
    if (_isPlayingEffects) return;
    _isPlayingEffects = true;

    try {
      final onsetDelay = await _getWaveformOnsetDelay();
      final remainingEffectDuration =
          (_catchAudioDuration - onsetDelay).inMilliseconds > 0
              ? _catchAudioDuration - onsetDelay
              : const Duration(milliseconds: 300);

      // Play custom alarm sound and flashlight together for 5 seconds.
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.play(
          AssetSource('audio/monster_catched.wav'),
          volume: 1.0,
        );
      } catch (_) {
        // Fallback for environments where asset playback fails.
        try {
          await SystemSound.play(SystemSoundType.alert);
        } catch (_) {}
      }

      if (onsetDelay > Duration.zero) {
        await Future.delayed(onsetDelay);
      }

      final hapticTask = () async {
        final stopwatch = Stopwatch()..start();
        while (stopwatch.elapsed < remainingEffectDuration) {
          try {
            await HapticFeedback.vibrate();
          } catch (_) {
            try {
              await HapticFeedback.heavyImpact();
            } catch (_) {
              // Ignore device haptic failures.
            }
          }
          await Future.delayed(_beatDuration);
        }
      }();

      final torchTask = () async {
        final stopwatch = Stopwatch()..start();
        var torchOn = false;
        while (stopwatch.elapsed < remainingEffectDuration) {
          try {
            if (torchOn) {
              await TorchLight.disableTorch();
              await Future.delayed(_halfBeatDuration);
            } else {
              await TorchLight.enableTorch();
              await Future.delayed(_halfBeatDuration);
            }
            torchOn = !torchOn;
          } catch (_) {
            // Ignore flashlight failures on devices/emulators without torch support.
            break;
          }
        }

        try {
          await TorchLight.disableTorch();
        } catch (_) {}
      }();

      await Future.wait([hapticTask, torchTask]);

      try {
        await _audioPlayer.stop();
      } catch (_) {}
    } finally {
      _isPlayingEffects = false;
    }
  }

  Future<void> _detectMonsters() async {
    setState(() {
      _loading = true;
      _detectedMonster = null;
      _detectedDistance = null;
      _status = 'Updating GPS location...';
    });

    final position = await _getLocation();
    if (!mounted || position == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      _currentPosition = position;
      _status = 'Checking nearby monsters...';
    });

    final monstersResult = await widget.apiService.monstersRead();
    if (monstersResult['success'] != true) {
      setState(() {
        _loading = false;
        _status =
            monstersResult['message']?.toString() ?? 'Failed to load monsters.';
      });
      return;
    }

    final List monsters = (monstersResult['monsters'] as List<dynamic>?) ??
        (monstersResult['data'] as List<dynamic>?) ??
        [];

    Map<String, dynamic>? nearestMonster;
    double? nearestDistance;

    for (final item in monsters) {
      final monster = Map<String, dynamic>.from(item);

      final monsterLat =
          double.tryParse(monster['spawn_latitude'].toString()) ?? 0;
      final monsterLng =
          double.tryParse(monster['spawn_longitude'].toString()) ?? 0;
      final radius =
          double.tryParse(monster['spawn_radius_meters'].toString()) ?? 0;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        monsterLat,
        monsterLng,
      );

      final isInsideRadius = radius > 0 && distance <= radius;
      if (isInsideRadius &&
          (nearestDistance == null || distance < nearestDistance)) {
        nearestMonster = monster;
        nearestDistance = distance;
      }
    }

    if (nearestMonster == null) {
      setState(() {
        _loading = false;
        _status = 'No monster found nearby.';
      });
      return;
    }

    final result = await widget.apiService.catchMonster(
      playerId: widget.playerId,
      monsterId: int.parse(nearestMonster['monster_id'].toString()),
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (result['success'] == true) {
      setState(() {
        _detectedMonster = nearestMonster;
        _detectedDistance = nearestDistance;
        _status = 'Monster detected near you!';
        _loading = false;
      });

      // Ensure the result card is painted first, then start sound+flash.
      await Future.delayed(const Duration(milliseconds: 50));
      unawaited(_playCatchEffects());
      return;
    }

    setState(() {
      _loading = false;
      _status = result['message']?.toString() ?? 'Failed to catch monster.';
    });
  }

  Widget _coordinateCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label$value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latitudeText = _currentPosition == null
        ? '--'
        : _currentPosition!.latitude.toStringAsFixed(6);
    final longitudeText = _currentPosition == null
        ? '--'
        : _currentPosition!.longitude.toStringAsFixed(6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catch Monsters'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refreshLocation,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _coordinateCard(
              icon: Icons.my_location,
              label: 'Your Latitude: ',
              value: latitudeText,
            ),
            const SizedBox(height: 10),
            _coordinateCard(
              icon: Icons.explore,
              label: 'Your Longitude: ',
              value: longitudeText,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _detectMonsters,
                      icon: const Icon(Icons.radar),
                      label: const Text('Detect Monsters'),
                    ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (_detectedMonster != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Monster: ${_detectedMonster!['monster_name']}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${_detectedMonster!['monster_type']}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distance: ${(_detectedDistance ?? 0).toStringAsFixed(2)} m',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
