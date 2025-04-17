import 'package:flutter/material.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:proximity/services/places_service.dart';

class PlaceSearchViewModel extends ChangeNotifier {
  PlaceSearchViewModel({
    required TripRepository tripRepository,
    required PlacesService placesService,
    required String tripId,
  }) : _tripRepository = tripRepository,
       _placesService = placesService,
       _tripId = tripId;

  final TripRepository _tripRepository;
  final PlacesService _placesService;
  final String _tripId;

  List<PlaceSearchResult> _searchResults = [];
  List<PlaceSearchResult> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> searchPlaces(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await _placesService.searchPlaces(query);
      _searchResults = results;
    } catch (e) {
      debugPrint('Error searching places: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Updated to work with the separate search screen
  Future<void> addPlaceToTrip(PlaceSearchResult searchResult) async {
    _isLoading = true;
    notifyListeners();

    // TODO better logging
    debugPrint("Adding place to trip: ${searchResult.placeId} to $_tripId");
    try {
      final placeDetails = await _placesService.getPlaceDetails(
        searchResult.placeId,
      );
      if (placeDetails != null) {
        final place = _placesService.convertToPlaceOfInterest(placeDetails);
        await _tripRepository.addTripPlace(_tripId, place);
      }
    } catch (e) {
      debugPrint('Error adding place: $e');
      rethrow; // Let the UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
