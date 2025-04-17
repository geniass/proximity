import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proximity/models/trip.dart';
import 'package:proximity/ui/trips_list/trip_card.dart';
import 'package:proximity/ui/trips_list/trips_list_viewmodel.dart';
import 'trip_form_sheet.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key, required this.viewModel});

  final TripsListViewModel viewModel;

  void _showTripSheet({required BuildContext context, Trip? trip, int? index}) {
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

      final Trip updatedTrip = Trip(
        id: trip?.id ?? '',
        destination: result.destination,
        startDateTime: result.startDateTime,
        endDateTime: result.endDateTime,
        places: trip?.places ?? [],
      );

      if (index != null) {
        // Update existing trip
        viewModel.updateTrip(updatedTrip, index: index);
      } else {
        // Add new trip
        viewModel.addTrip(updatedTrip);
      }
    });
  }

  void _showAddTripSheet(BuildContext context) {
    _showTripSheet(context: context);
  }

  void _showEditTripSheet(BuildContext context, int index) {
    _showTripSheet(
      context: context,
      trip: viewModel.trips[index],
      index: index,
    );
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
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () {
        //     // Open drawer
        //   },
        // ),
        // actions: [
        //   IconButton(
        //     icon: const CircleAvatar(
        //       backgroundColor: Colors.black12,
        //       child: Icon(Icons.person_outline, color: Colors.black54),
        //     ),
        //     onPressed: () {
        //       // Open profile
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${viewModel.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.trips.isEmpty) {
              return const Center(
                child: Text(
                  'No trips yet.\nTap + to add your first trip!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: viewModel.trips.length,
              itemBuilder: (context, index) {
                final trip = viewModel.trips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TripCard(
                    trip: trip,
                    onTap: () {
                      context.go('/trip/${trip.id}');
                    },
                    onEdit: () => _showEditTripSheet(context, index),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _showAddTripSheet(context),
        child: const Icon(Icons.add, color: Colors.indigo),
      ),
    );
  }
}
