import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  // Fetch suggestions based on the query, restricted to Namibia (countrycode=na)
  static Future<List<NominatimPlace>> fetchSuggestions(String query) async {
    final url = Uri.parse(
      '$_baseUrl?q=$query&format=json&addressdetails=1&countrycodes=na&limit=5',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'Hockey Union - israelrshingenge@gmail.com'  // Replace with your info
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => NominatimPlace.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}

class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
