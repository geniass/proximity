import 'package:flutter/material.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:proximity/services/places_service.dart';
import 'package:uuid/uuid.dart';

enum PlacesViewType { map, list }

class PlacesOfInterestViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  final PlacesService _placesService = PlacesService();
  final String tripId;
  
  List<PlaceOfInterest> _places = [];
  List<PlaceOfInterest> get places => _places;
  
  List<PlaceSearchResult> _searchResults = [];
  List<PlaceSearchResult> get searchResults => _searchResults;
  
  String _tripName = '';
  String get tripName => _tripName;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  PlacesViewType _currentView = PlacesViewType.list;
  PlacesViewType get currentView => _currentView;
  
  // Search-related state
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  PlacesOfInterestViewModel(this._tripRepository, this.tripId) {
    loadTrip();
  }
  
  Future<void> loadTrip() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final trip = await _tripRepository.getTripById(tripId);
      if (trip != null) {
        _places = trip.places;
        _tripName = trip.destination;
      } else {
        _places = [];
        _tripName = 'Trip Details';
      }
    } catch (e) {
      debugPrint('Error loading trip: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleViewType() {
    _currentView = _currentView == PlacesViewType.list 
        ? PlacesViewType.map 
        : PlacesViewType.list;
    notifyListeners();
  }
  
  void toggleIgnored(int index, bool value) {
    _places[index] = _places[index].copyWith(isIgnored: value);
    _tripRepository.updateTripPlaces(tripId, _places);
    notifyListeners();
  }
  
  Future<void> addNewPlace(String name) async {
    final uuid = const Uuid();
    
    final place = PlaceOfInterest(
      id: uuid.v4(),
      name: name,
      // Default location set to San Francisco for demo purposes
      latitude: 37.7749,
      longitude: -122.4194,
    );
    
    _places.add(place);
    await _tripRepository.updateTripPlaces(tripId, _places);
    notifyListeners();
  }
  
  // Search state management methods
  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }
  
  void cancelSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
  
  Future<void> searchPlaces(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      cancelSearch();
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
  
  Future<void> addPlaceFromSearch(PlaceSearchResult searchResult) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final placeDetails = await _placesService.getPlaceDetails(searchResult.placeId);
      if (placeDetails != null) {
        final place = _placesService.convertToPlaceOfInterest(placeDetails);
        _places.add(place);
        await _tripRepository.updateTripPlaces(tripId, _places);
      }
    } catch (e) {
      debugPrint('Error adding place: $e');
    } finally {
      _isLoading = false;
      _isSearching = false;
      _searchQuery = '';
      _searchResults = [];
      notifyListeners();
    }
  }
}