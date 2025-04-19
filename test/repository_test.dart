import 'package:flutter_test/flutter_test.dart';
import 'package:proximity/models/trip.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/repositories/sqlite_trip_repository.dart';
import 'package:proximity/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late SqliteTripRepository repository;

  setUpAll(() {
    // Initialize FFI for testing without actual device
    sqfliteFfiInit();
  });

  setUp(() async {
    // Create a new in-memory database for each test
    databaseService = DatabaseService(databaseFactory: databaseFactoryFfi);
    repository = SqliteTripRepository(databaseService);
  });

  tearDown(() async {
    // Close the database to prevent leaks
    await databaseService.close();
  });

  group('ProviderSqliteTripRepository Tests', () {
    test('Add and retrieve a trip', () async {
      // Create a test trip
      final trip = Trip(
        id: const Uuid().v4(),
        destination: 'Paris',
        startDateTime: DateTime.now(),
        endDateTime: DateTime.now().add(const Duration(days: 7)),
      );

      // Add trip to repository
      await repository.addTrip(trip);

      // Retrieve the trip
      final retrievedTrip = await repository.getTripById(trip.id);

      // Verify trip was stored correctly
      expect(retrievedTrip, isNotNull);
      expect(retrievedTrip!.destination, equals('Paris'));
      expect(retrievedTrip.places, isEmpty);
    });

    test('Add a place to a trip', () async {
      // Create and add a test trip
      final tripId = const Uuid().v4();
      final trip = Trip(id: tripId, destination: 'Tokyo');
      await repository.addTrip(trip);

      // Create and add a place to the trip
      final place = PlaceOfInterest(
        id: const Uuid().v4(),
        googlePlaceId: 'google123',
        name: 'Tokyo Tower',
        latitude: 35.6586,
        longitude: 139.7454,
      );
      await repository.addTripPlace(tripId, place);

      // Retrieve the trip with the place
      final retrievedTrip = await repository.getTripById(tripId);

      // Verify place was added
      expect(retrievedTrip!.places.length, equals(1));
      expect(retrievedTrip.places.first.name, equals('Tokyo Tower'));
    });

    test('Delete a trip', () async {
      // Create and add a test trip
      final tripId = const Uuid().v4();
      final trip = Trip(id: tripId, destination: 'Sydney');
      await repository.addTrip(trip);

      // Verify trip exists
      expect(await repository.getTripById(tripId), isNotNull);

      // Delete the trip
      await repository.deleteTrip(tripId);

      // Verify trip no longer exists
      expect(await repository.getTripById(tripId), isNull);
    });

    test('Update trip places', () async {
      // Create and add a test trip with a place
      final tripId = const Uuid().v4();
      final trip = Trip(id: tripId, destination: 'Rome');
      await repository.addTrip(trip);

      final place1 = PlaceOfInterest(
        id: const Uuid().v4(),
        googlePlaceId: 'google123',
        name: 'Colosseum',
        latitude: 41.8902,
        longitude: 12.4922,
      );
      await repository.addTripPlace(tripId, place1);

      // Create a new list of places to replace the old ones
      final place2 = PlaceOfInterest(
        id: const Uuid().v4(),
        googlePlaceId: 'google456',
        name: 'Vatican',
        latitude: 41.9022,
        longitude: 12.4533,
      );

      final newPlaces = [place2];

      // Update the trip places
      await repository.updateTripPlaces(tripId, newPlaces);

      // Retrieve the trip
      final retrievedTrip = await repository.getTripById(tripId);

      // Verify places were updated
      expect(retrievedTrip!.places.length, equals(1));
      expect(retrievedTrip.places.first.name, equals('Vatican'));
      expect(retrievedTrip.places.every((p) => p.name != 'Colosseum'), isTrue);
    });
  });
}
