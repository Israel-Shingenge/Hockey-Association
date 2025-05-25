import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class EventLocationPage extends StatefulWidget {
  final String locationName;

  const EventLocationPage({super.key, required this.locationName});

  @override
  State<EventLocationPage> createState() => _EventLocationPageState();
}

class _EventLocationPageState extends State<EventLocationPage> {
  LatLng? _latLng;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(widget.locationName);
      if (locations.isNotEmpty) {
        setState(() {
          _latLng = LatLng(locations[0].latitude, locations[0].longitude);
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        backgroundColor: Colors.blue,
      ),
      body: _latLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _latLng!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('event_location'),
                  position: _latLng!,
                  infoWindow: InfoWindow(title: widget.locationName),
                ),
              },
            ),
    );
  }
}
