import 'package:flutter/material.dart';
import 'trip_form_sheet.dart';
import 'package:intl/intl.dart';

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
  final List<Map<String, dynamic>> _trips = [
    {
      'destination': 'Tokyo',
      'startDate': '29 July',
      'endDate': '13 August',
      'avatarLetter': 'T',
      'startDateTime': DateTime(2025, 7, 29),
      'endDateTime': DateTime(2025, 8, 13),
    }
  ];

  void _showAddTripSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: const TripFormSheet(),
          );
        },
      ),
    ).then((result) {
      if (result != null && result['name'] != null && result['name'].isNotEmpty) {
        setState(() {
          _trips.add({
            'destination': result['name'],
            'startDate': result['startDate'] != null
                ? '${result['startDate'].day} ${_getMonthName(result['startDate'].month)}'
                : 'No date',
            'endDate': result['endDate'] != null
                ? '${result['endDate'].day} ${_getMonthName(result['endDate'].month)}'
                : '',
            'avatarLetter': result['name'][0].toUpperCase(),
            'startDateTime': result['startDate'],
            'endDateTime': result['endDate'],
          });
        });
      }
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
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
              child: Icon(
                Icons.person_outline,
                color: Colors.black54,
              ),
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
                destination: trip['destination'],
                startDate: trip['startDate'],
                endDate: trip['endDate'],
                avatarLetter: trip['avatarLetter'],
                startDateTime: trip['startDateTime'],
                endDateTime: trip['endDateTime'],
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
  final String destination;
  final String startDate;
  final String endDate;
  final String avatarLetter;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const TripCard({
    super.key,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.avatarLetter,
    this.startDateTime,
    this.endDateTime,
  });

  double calculateProgress() {
    // Today's date
    final today = DateTime.now();

    // If no dates are set, return 0
    if (startDateTime == null || endDateTime == null) {
      return 0.0;
    }

    // If the trip hasn't started yet
    if (today.isBefore(startDateTime!)) {
      return 0.0;
    }

    // If the trip is already over
    if (today.isAfter(endDateTime!)) {
      return 1.0;
    }

    // Calculate the total trip duration in days
    final totalDuration = endDateTime!.difference(startDateTime!).inDays;
    if (totalDuration <= 0) return 0.0;

    // Calculate days elapsed since start
    final elapsedDuration = today.difference(startDateTime!).inDays;

    // Calculate and return progress as a value between 0.0 and 1.0
    return elapsedDuration / totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate trip progress
    final progress = calculateProgress();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                avatarLetter,
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
                    destination,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endDate.isEmpty ? startDate : '$startDate - $endDate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
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
    );
  }
}