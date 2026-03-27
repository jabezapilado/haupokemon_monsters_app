import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/api_service.dart';

class EditMonsterScreen extends StatefulWidget {
  const EditMonsterScreen({
    super.key,
    required this.apiService,
    required this.monster,
  });

  final ApiService apiService;
  final Map<String, dynamic> monster;

  @override
  State<EditMonsterScreen> createState() => _EditMonsterScreenState();
}

class _EditMonsterScreenState extends State<EditMonsterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _radiusController;
  late final TextEditingController _pictureController;

  GoogleMapController? _mapController;

  bool _loading = false;
  bool _locating = false;
  bool _hasLocationPermission = false;
  bool _touchingMap = false;
  MapType _mapType = MapType.normal;
  String _message = '';

  LatLng? _selectedLatLng;

  double get _radiusMeters =>
      double.tryParse(_radiusController.text.trim()) ?? 100;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.monster['monster_name']?.toString() ?? '',
    );
    _typeController = TextEditingController(
      text: widget.monster['monster_type']?.toString() ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.monster['spawn_radius_meters']?.toString() ?? '100',
    );
    _pictureController = TextEditingController(
      text: widget.monster['picture_url']?.toString() ?? '',
    );

    final lat =
        double.tryParse(widget.monster['spawn_latitude'].toString()) ?? 15.1450;
    final lng = double.tryParse(widget.monster['spawn_longitude'].toString()) ??
        120.5900;
    _selectedLatLng = LatLng(lat, lng);

    _warmUpLocationPermission();
  }

  Future<void> _warmUpLocationPermission() async {
    final position = await _getCurrentPosition(silent: true);
    if (!mounted || position == null) return;

    setState(() {
      _hasLocationPermission = true;
    });
  }

  Future<Position?> _getCurrentPosition({bool silent = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!silent) {
        setState(() {
          _message = 'Location service is disabled.';
        });
      }
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!silent) {
        setState(() {
          _message = 'Location permission was denied.';
        });
      }
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!silent) {
        setState(() {
          _message =
              'Location permission is permanently denied. Enable it in device settings.';
        });
      }
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _moveCamera(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 17),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    setState(() {
      _locating = true;
    });

    final position = await _getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      setState(() {
        _locating = false;
      });
      return;
    }

    final current = LatLng(position.latitude, position.longitude);
    setState(() {
      _selectedLatLng = current;
      _hasLocationPermission = true;
      _locating = false;
    });

    await _moveCamera(current);
  }

  Future<void> _saveMonster() async {
    final monsterName = _nameController.text.trim();
    final monsterType = _typeController.text.trim();
    final picture = _pictureController.text.trim();
    final radius = double.tryParse(_radiusController.text.trim());

    if (monsterName.isEmpty ||
        monsterType.isEmpty ||
        _selectedLatLng == null ||
        radius == null ||
        radius <= 0) {
      setState(() {
        _message = 'Please complete all required fields correctly.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final result = await widget.apiService.monstersUpdate(
      monsterId: int.parse(widget.monster['monster_id'].toString()),
      monsterName: monsterName,
      type: monsterType,
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
      radius: radius,
      picture: picture,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _message = result['message']?.toString() ?? '';
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monster updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _radiusController.dispose();
    _pictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLatLng ?? const LatLng(15.1450, 120.5900);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('spawn_point'),
        position: selected,
        draggable: true,
        onDragEnd: (position) {
          setState(() {
            _selectedLatLng = position;
          });
        },
      ),
    };

    final circles = <Circle>{
      Circle(
        circleId: const CircleId('spawn_radius'),
        center: selected,
        radius: _radiusMeters,
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withValues(alpha: 0.2),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Monster'),
        actions: [
          IconButton(
            onPressed: _toggleMapType,
            icon: Icon(
              _mapType == MapType.normal ? Icons.satellite_alt : Icons.map,
            ),
            tooltip: _mapType == MapType.normal
                ? 'Switch to satellite'
                : 'Switch to normal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: _touchingMap
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Monster Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Monster Type'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _radiusController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Spawn Radius (meters)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pictureController,
              decoration: const InputDecoration(
                labelText: 'Picture URL (optional)',
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Listener(
                onPointerDown: (_) {
                  if (!_touchingMap) {
                    setState(() {
                      _touchingMap = true;
                    });
                  }
                },
                onPointerUp: (_) {
                  if (_touchingMap) {
                    setState(() {
                      _touchingMap = false;
                    });
                  }
                },
                onPointerCancel: (_) {
                  if (_touchingMap) {
                    setState(() {
                      _touchingMap = false;
                    });
                  }
                },
                child: SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: selected,
                          zoom: 17,
                        ),
                        gestureRecognizers: <Factory<
                            OneSequenceGestureRecognizer>>{
                          Factory<EagerGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                        mapType: _mapType,
                        markers: markers,
                        circles: circles,
                        myLocationEnabled: _hasLocationPermission,
                        myLocationButtonEnabled: false,
                        compassEnabled: true,
                        zoomControlsEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (position) {
                          setState(() {
                            _selectedLatLng = position;
                          });
                        },
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'edit_my_location',
                          onPressed: _goToMyLocation,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                      if (_locating)
                        Container(
                          color: Colors.black.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Swipe to move the map, pinch to zoom, drag the pin, or tap the map to place the spawn point.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Latitude: ${selected.latitude.toStringAsFixed(6)}\n'
                'Longitude: ${selected.longitude.toStringAsFixed(6)}\n'
                'Radius: ${_radiusMeters.toStringAsFixed(2)} meters',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveMonster,
                    child: const Text('Save Changes'),
                  ),
            const SizedBox(height: 12),
            if (_message.isNotEmpty)
              Text(
                _message,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
