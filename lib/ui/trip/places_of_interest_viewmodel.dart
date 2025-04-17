import 'package:flutter/material.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/trip_repository.dart';

enum PlacesViewType { map, list }

class PlacesOfInterestViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  final String tripId;

  List<PlaceOfInterest> _places = [];
  List<PlaceOfInterest> get places => _places;

  String _tripName = '';
  String get tripName => _tripName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PlacesViewType _currentView = PlacesViewType.list;
  PlacesViewType get currentView => _currentView;

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
    _currentView =
        _currentView == PlacesViewType.list
            ? PlacesViewType.map
            : PlacesViewType.list;
    notifyListeners();
  }

  void toggleIgnored(int index, bool value) {
    _places[index] = _places[index].copyWith(isIgnored: value);
    _tripRepository.updateTripPlaces(tripId, _places);
    notifyListeners();
  }
}
