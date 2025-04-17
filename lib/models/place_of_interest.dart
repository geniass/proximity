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
}
