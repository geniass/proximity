import 'package:proximity/models/place_of_interest.dart';

class Trip {
  final String id;
  final String destination;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final List<PlaceOfInterest> places;

  Trip({
    required this.id,
    required this.destination,
    this.startDateTime,
    this.endDateTime,
    List<PlaceOfInterest>? places,
  }) : places = places ?? [];

  String get avatarLetter =>
      destination.isNotEmpty ? destination[0].toUpperCase() : '';

  Trip copyWith({
    String? id,
    String? destination,
    DateTime? startDateTime,
    DateTime? endDateTime,
    List<PlaceOfInterest>? places,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startDateTime:
          clearStartDate ? null : startDateTime ?? this.startDateTime,
      endDateTime: clearEndDate ? null : endDateTime ?? this.endDateTime,
      places: places ?? this.places,
    );
  }

  // Calculate trip progress as a value between 0.0 and 1.0
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'start_date': startDateTime?.millisecondsSinceEpoch,
      'end_date': endDateTime?.millisecondsSinceEpoch,
    };
  }

  static Trip fromMap(Map<String, dynamic> map, List<PlaceOfInterest> places) {
    return Trip(
      id: map['id'],
      destination: map['destination'],
      startDateTime:
          map['start_date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['start_date'])
              : null,
      endDateTime:
          map['end_date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['end_date'])
              : null,
      places: places,
    );
  }
}
