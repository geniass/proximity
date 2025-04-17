import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:proximity/models/place_of_interest.dart';
import 'package:uuid/uuid.dart';

class PlacesService {
  // This API key has to be in the client code but its restricted to this app's fingerprint.
  // nosemgrep: generic.secrets.security.detected-generic-api-key.detected-generic-api-key
  static const String _apiKey = 'AIzaSyCcQKL7nw7OJCc3fKPi9EIEIgkedaebWWQ';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Search for places based on a text query
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/textsearch/json?query=$query&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return (data['results'] as List)
            .map((place) => PlaceSearchResult.fromJson(place))
            .toList();
      }
    }

    return [];
  }

  // Get details for a specific place by place ID
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=place_id,name,formatted_address,geometry,photos&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return PlaceDetails.fromJson(data['result']);
      } else {
        // TODO better logging
        log(
          'Invalid place details status (${data['status']}): ${data['error_message']}',
        );
      }
    } else {
      // TODO better logging
      log(
        'Error fetching place details (${response.statusCode}): ${response.body}',
      );
    }

    return null;
  }

  // Convert a PlaceDetails to a PlaceOfInterest model
  PlaceOfInterest convertToPlaceOfInterest(PlaceDetails place) {
    final uuid = const Uuid();
    return PlaceOfInterest(
      id: uuid.v4(),
      googlePlaceId: place.placeId,
      name: place.name,
      latitude: place.lat,
      longitude: place.lng,
      notes: place.address,
    );
  }
}

class PlaceSearchResult {
  final String placeId;
  final String name;
  final double lat;
  final double lng;

  PlaceSearchResult({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResult(
      placeId: json['place_id'],
      name: json['name'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? photoReference;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.photoReference,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    String? photoRef;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photoRef = json['photos'][0]['photo_reference'];
    }

    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'],
      address: json['formatted_address'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
      photoReference: photoRef,
    );
  }
}
