import 'package:flutter/material.dart';
import 'package:proximity/date_utils.dart';
import 'package:proximity/models/trip.dart';
import 'package:proximity/places_of_interest_screen.dart';
import 'package:uuid/uuid.dart';
import 'trip_form_sheet.dart';

void main() {
  runApp(const ProximityApp());
}

class ProximityApp extends StatelessWidget {
  const ProximityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: const Color(0xFFECF5F5),
        ),
      ),
      home: const TripsScreen(),
    );
  }
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // List of trips that will be displayed
  final List<Trip> _trips = [
    Trip(
      id: 'trip-1',
      destination: 'Tokyo',
      startDateTime: DateTime(2025, 7, 29),
      endDateTime: DateTime(2025, 8, 13),
    ),
  ];

  final _uuid = const Uuid();

  void _showTripSheet({Trip? trip, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: TripFormSheet(
                  id: trip?.id,
                  initialName: trip?.destination,
                  initialStartDate: trip?.startDateTime,
                  initialEndDate: trip?.endDateTime,
                ),
              );
            },
          ),
    ).then((dynamic result) {
      if (result == null || result is! Trip) {
        return;
      }
      setState(() {
        final Trip updatedTrip = Trip(
          id: trip?.id ?? _uuid.v4(),
          destination: result.destination,
          startDateTime: result.startDateTime,
          endDateTime: result.endDateTime,
          places: trip?.places ?? [],
        );

        if (index != null) {
          // Update existing trip
          _trips[index] = updatedTrip;
        } else {
          // Add new trip
          _trips.add(updatedTrip);
        }
      });
    });
  }

  void _showAddTripSheet() {
    _showTripSheet();
  }

  void _showEditTripSheet(int index) {
    _showTripSheet(trip: _trips[index], index: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECF5F5),
        centerTitle: true,
        title: const Text(
          'Trips',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open drawer
          },
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(Icons.person_outline, color: Colors.black54),
            ),
            onPressed: () {
              // Open profile
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _trips.length,
          itemBuilder: (context, index) {
            final trip = _trips[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TripCard(
                trip: trip,
                onTap: () {
                  // Navigate to the places of interest screen when tapping on a trip
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PlacesOfInterestScreen(
                            tripName: trip.destination,
                            initialPlaces: trip.places,
                          ),
                    ),
                  ).then((updatedPlaces) {
                    if (updatedPlaces != null) {
                      setState(() {
                        _trips[index] = trip.copyWith(places: updatedPlaces);
                      });
                    }
                  });
                },
                onEdit: () => _showEditTripSheet(index),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _showAddTripSheet,
        child: const Icon(Icons.add, color: Colors.indigo),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TripCard({super.key, required this.trip, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Calculate trip progress
    final progress = trip.calculateProgress();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              // Left avatar with initial letter
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  trip.avatarLetter,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Middle section with trip details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.startDateTime == null || trip.endDateTime == null
                          ? 'No Start/End'
                          : '${formatDate(trip.startDateTime!)} - ${formatDate(trip.endDateTime!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit icon
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[600],
                  onPressed: onEdit,
                ),
              // Right progress indicator
              SizedBox(
                height: 40,
                width: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      color: Colors.indigo.shade700,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
