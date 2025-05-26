import 'package:flutter/material.dart';
import 'package:hockey_union/mapApi/fulllscreen_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventLocationPage extends StatefulWidget {
  final String locationName;

  const EventLocationPage({super.key, required this.locationName});

  @override
  State<EventLocationPage> createState() => _EventLocationPageState();
}

class _EventLocationPageState extends State<EventLocationPage> {
  double? latitude;
  double? longitude;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
  }

  Future<void> _fetchCoordinates() async {
    final query = Uri.encodeComponent(widget.locationName);
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'HockeyUnion - israelrshingenge@gmail.com', 
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            latitude = double.parse(data[0]['lat']);
            longitude = double.parse(data[0]['lon']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Location not found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error fetching location data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load location data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapWidth = MediaQuery.of(context).size.width.toInt();
    final mapHeight = (mapWidth * 0.6).toInt();

    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      content = Center(
          child: Text(errorMessage!,
              style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)));
    } else if (latitude != null && longitude != null) {
      final staticMapUrl =
          'https://static-maps.yandex.ru/1.x/?ll=$longitude,$latitude&size=$mapWidth,$mapHeight&z=13&l=map&pt=$longitude,$latitude,pm2rdm';

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.locationName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenMapPage(
                    latitude: latitude!,
                    longitude: longitude!,
                    locationName: widget.locationName,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    staticMapUrl,
                    width: mapWidth.toDouble(),
                    height: mapHeight.toDouble(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text('Failed to load map image.',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: const Text(
                        'Tap to interact',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Back',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.blue.shade700,
              elevation: 5,
              shadowColor: Colors.blueAccent,
            ),
          ),
        ],
      );
    } else {
      content = const Center(
          child: Text(
        'Unknown error occurred',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Location',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.black54,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: content,
      ),
    );
  }
}
