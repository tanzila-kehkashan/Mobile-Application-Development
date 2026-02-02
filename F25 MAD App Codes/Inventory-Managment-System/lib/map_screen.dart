import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Default location - Islamabad, Pakistan
  static const LatLng _defaultLocation = LatLng(33.6844, 73.0479);

  LatLng _currentPosition = _defaultLocation;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _addMarker(_defaultLocation);
  }

  void _addMarker(LatLng position) {
    setState(() {
      _currentPosition = position;
      _markers = [
        Marker(
          point: position,
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ];
    });
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    _addMarker(point);
  }

  void _saveLocation() {
    Navigator.pop(context, _currentPosition);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location saved: ${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _goToLocation(LatLng location, String name) {
    _addMarker(location);
    _mapController.move(location, 12);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Moved to $name')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F487B),
        foregroundColor: Colors.white,
        title: const Text('Select Location'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveLocation,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 12,
              onTap: _onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.inventory_management_system',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Location Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF1F487B)),
                      SizedBox(width: 8),
                      Text(
                        'Selected Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_currentPosition.latitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    'Lng: ${_currentPosition.longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap on the map to select a different location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Location Buttons
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              children: [
                _buildQuickLocationButton(
                  'Islamabad',
                  const LatLng(33.6844, 73.0479),
                  Icons.location_city,
                ),
                const SizedBox(height: 8),
                _buildQuickLocationButton(
                  'Lahore',
                  const LatLng(31.5204, 74.3587),
                  Icons.location_city,
                ),
                const SizedBox(height: 8),
                _buildQuickLocationButton(
                  'Karachi',
                  const LatLng(24.8607, 67.0011),
                  Icons.location_city,
                ),
                const SizedBox(height: 8),
                _buildQuickLocationButton(
                  'Peshawar',
                  const LatLng(34.0151, 71.5249),
                  Icons.location_city,
                ),
              ],
            ),
          ),

          // Zoom Controls
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                }),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLocationButton(
    String name,
    LatLng location,
    IconData icon,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _goToLocation(location, name),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1F487B)),
              const SizedBox(width: 4),
              Text(name, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: const Color(0xFF1F487B)),
        ),
      ),
    );
  }
}
