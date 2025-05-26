import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullscreenMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const FullscreenMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locationName)),
      body: FlutterMap(
        options: MapOptions(
        initialCenter: LatLng(latitude, longitude),
        initialZoom: 15.0,
      ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 60,
                height: 60,
                point: LatLng(latitude, longitude),
                child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
