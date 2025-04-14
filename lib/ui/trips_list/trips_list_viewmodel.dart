import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:proximity/models/trip.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/trip_repository.dart';

class TripsListViewModel extends ChangeNotifier {
  final TripRepository _repository;
  
  TripsListViewModel(this._repository);
  
  List<Trip> _trips = [];
  UnmodifiableListView<Trip> get trips => UnmodifiableListView(_trips);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _error = '';
  String get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _trips = await _repository.getTrips();
    } catch (e) {
      _error = 'Failed to load trips: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      await _repository.addTrip(trip);
      await load(); // Refresh list from repository
    } catch (e) {
      _error = 'Failed to add trip: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateTrip(Trip trip, {int? index}) async {
    try {
      await _repository.updateTrip(trip);
      await load(); // Refresh list from repository
    } catch (e) {
      _error = 'Failed to update trip: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateTripPlaces(String tripId, List<PlaceOfInterest> places) async {
    try {
      await _repository.updateTripPlaces(tripId, places);
      await load(); // Refresh list from repository
    } catch (e) {
      _error = 'Failed to update trip places: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      await _repository.deleteTrip(id);
      await load(); // Refresh list from repository
    } catch (e) {
      _error = 'Failed to delete trip: ${e.toString()}';
      notifyListeners();
    }
  }
}
