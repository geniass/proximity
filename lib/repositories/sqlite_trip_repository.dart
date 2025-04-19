import 'package:proximity/models/trip.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:proximity/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SqliteTripRepository implements TripRepository {
  final DatabaseService _databaseService;
  final _uuid = const Uuid();

  // Constructor that takes a DatabaseService instance via dependency injection
  SqliteTripRepository(this._databaseService);

  @override
  Future<List<Trip>> getTrips() async {
    return await _databaseService.transaction<List<Trip>>((db) async {
      final List<Map<String, dynamic>> tripMaps = await db.query('trips');

      // Convert the list of trip maps to a list of Trip objects
      List<Trip> trips = [];
      for (var tripMap in tripMaps) {
        final places = await _getPlacesForTrip(db, tripMap['id']);
        trips.add(Trip.fromMap(tripMap, places));
      }

      return trips;
    });
  }

  @override
  Future<Trip?> getTripById(String id) async {
    return await _databaseService.transaction<Trip?>((db) async {
      final List<Map<String, dynamic>> tripMaps = await db.query(
        'trips',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (tripMaps.isEmpty) {
        return null;
      }

      final places = await _getPlacesForTrip(db, tripMaps.first['id']);
      return Trip.fromMap(tripMaps.first, places);
    });
  }

  @override
  Future<void> addTrip(Trip trip) async {
    await _databaseService.transaction<void>((db) async {
      // Create a new trip with the generated ID if needed
      final tripToAdd = trip.id.isEmpty ? trip.copyWith(id: _uuid.v4()) : trip;

      await db.insert(
        'trips',
        tripToAdd.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Add all places if the trip has any
      if (tripToAdd.places.isNotEmpty) {
        for (var place in tripToAdd.places) {
          await _insertPlace(db, tripToAdd.id, place);
        }
      }
    });
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    await _databaseService.transaction<void>((db) async {
      await db.update(
        'trips',
        trip.toMap(),
        where: 'id = ?',
        whereArgs: [trip.id],
      );
    });
  }

  @override
  Future<void> addTripPlace(String tripId, PlaceOfInterest place) async {
    await _databaseService.transaction<void>((db) async {
      await _insertPlace(db, tripId, place);
    });
  }

  @override
  Future<void> updateTripPlaces(
    String tripId,
    List<PlaceOfInterest> places,
  ) async {
    await _databaseService.transaction<void>((db) async {
      // Delete all existing places for this trip
      await db.delete(
        'places_of_interest',
        where: 'trip_id = ?',
        whereArgs: [tripId],
      );

      // Insert all new places
      for (var place in places) {
        await _insertPlace(db, tripId, place);
      }
    });
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _databaseService.transaction<void>((db) async {
      // The foreign key constraint will automatically delete associated places
      await db.delete('trips', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Helper method to insert a place with the given database connection
  Future<void> _insertPlace(
    Transaction db,
    String tripId,
    PlaceOfInterest place,
  ) async {
    // Check if the place already exists in the trip
    final List<Map<String, dynamic>> existingPlaces = await db.query(
      'places_of_interest',
      where: 'trip_id = ? AND google_place_id = ?',
      whereArgs: [tripId, place.googlePlaceId],
    );

    if (existingPlaces.isNotEmpty) {
      return; // Place already exists in this trip
    }

    final placeToAdd =
        place.id.isEmpty ? place.copyWith(id: _uuid.v4()) : place;

    await db.insert(
      'places_of_interest',
      placeToAdd.toMap(tripId: tripId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Helper method to load places for a trip using the given database connection
  Future<List<PlaceOfInterest>> _getPlacesForTrip(
    Transaction db,
    String tripId,
  ) async {
    final List<Map<String, dynamic>> placeMaps = await db.query(
      'places_of_interest',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );

    return placeMaps
        .map((placeMap) => PlaceOfInterest.fromMap(placeMap))
        .toList();
  }
}
