import 'package:proximity/models/trip.dart';
import 'package:proximity/models/place_of_interest.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTripById(String id);
  Future<void> addTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> addTripPlace(String tripId, PlaceOfInterest place);
  Future<void> updateTripPlaces(String tripId, List<PlaceOfInterest> places);
  Future<void> deleteTrip(String id);
}
