import 'package:proximity/models/trip.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:uuid/uuid.dart';

class MockTripRepository implements TripRepository {
  final _uuid = const Uuid();
  final List<Trip> _trips = [
    Trip(
      id: 'trip-1',
      destination: 'Tokyo',
      startDateTime: DateTime(2025, 7, 29),
      endDateTime: DateTime(2025, 8, 13),
    ),
  ];
  
  @override
  Future<List<Trip>> getTrips() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _trips.toList();
  }
  
  @override
  Future<Trip?> getTripById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> addTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTrip = Trip(
      id: trip.id.isEmpty ? _uuid.v4() : trip.id,
      destination: trip.destination,
      startDateTime: trip.startDateTime,
      endDateTime: trip.endDateTime,
      places: trip.places,
    );
    _trips.add(newTrip);
  }
  
  @override
  Future<void> updateTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
    }
  }
  
  @override
  Future<void> updateTripPlaces(String tripId, List<PlaceOfInterest> places) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index >= 0) {
      _trips[index] = _trips[index].copyWith(places: places);
    }
  }
  
  @override
  Future<void> deleteTrip(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _trips.removeWhere((trip) => trip.id == id);
  }
}