import 'dart:developer';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:uuid/uuid.dart';

class PlacesService {
  // This API key has to be in the client code but its restricted to this app's fingerprint.
  // nosemgrep: generic.secrets.security.detected-generic-api-key.detected-generic-api-key
  static const String _apiKey = 'AIzaSyCcQKL7nw7OJCc3fKPi9EIEIgkedaebWWQ';

  final FlutterGooglePlacesSdkPlatform _placesClient =
      FlutterGooglePlacesSdkPlatform.instance;
  Future<void>? _initialization;

  PlacesService() {
    // HACK use platform interface directly because the lib doesn't support searchByText yet
    // _placesClient = FlutterGooglePlacesSdk(_apiKey, useNewApi: true);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _placesClient.initialize(
      _apiKey,
      useNewApi: true,
    )..catchError((dynamic err) {
      print('FlutterGooglePlacesSdk::_ensureInitialized error: $err');
      _initialization = null;
    });
  }

  // Search for places based on a text query
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      await _ensureInitialized();
      final response = await _placesClient.searchByText(
        query,
        fields: [PlaceField.Id, PlaceField.Name, PlaceField.Location],
      );

      return response.places
          .map(
            (prediction) => PlaceSearchResult(
              placeId: prediction.id!,
              name: prediction.name!,
              lat: prediction.latLng?.lat ?? 0.0,
              lng: prediction.latLng?.lng ?? 0.0,
            ),
          )
          .toList();
    } catch (e) {
      log('Error searching places: $e');
      return [];
    }
  }

  // Get details for a specific place by place ID
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _placesClient.fetchPlace(
        placeId,
        fields: [
          PlaceField.Id,
          PlaceField.Name,
          PlaceField.Address,
          PlaceField.Location,
          PlaceField.PhotoMetadatas,
        ],
      );

      final place = response.place;
      String? photoReference;

      if (place?.photoMetadatas != null && place!.photoMetadatas!.isNotEmpty) {
        photoReference = place.photoMetadatas![0].photoReference;
      }

      return PlaceDetails(
        placeId: place?.id ?? placeId,
        name: place?.name ?? '',
        address: place?.address ?? '',
        lat: place?.latLng?.lat ?? 0.0,
        lng: place?.latLng?.lng ?? 0.0,
        photoReference: photoReference,
      );
    } catch (e) {
      log('Error fetching place details: $e');
      return null;
    }
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
}
