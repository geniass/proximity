class PlaceOfInterest {
  final String id;
  final String googlePlaceId;
  final String name;
  final bool isIgnored;
  final String? notes;
  final double latitude;
  final double longitude;

  PlaceOfInterest({
    required this.id,
    required this.googlePlaceId,
    required this.name,
    this.isIgnored = false,
    this.notes,
    required this.latitude,
    required this.longitude,
  });

  PlaceOfInterest copyWith({
    String? id,
    String? googlePlaceId,
    String? name,
    bool? isIgnored,
    String? notes,
    double? latitude,
    double? longitude,
  }) {
    return PlaceOfInterest(
      id: id ?? this.id,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      name: name ?? this.name,
      isIgnored: isIgnored ?? this.isIgnored,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap({required String tripId}) {
    return {
      'id': id,
      'trip_id': tripId,
      'google_place_id': googlePlaceId,
      'name': name,
      'is_ignored': isIgnored ? 1 : 0,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static PlaceOfInterest fromMap(Map<String, dynamic> map) {
    return PlaceOfInterest(
      id: map['id'],
      googlePlaceId: map['google_place_id'],
      name: map['name'],
      isIgnored: map['is_ignored'] == 1,
      notes: map['notes'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
