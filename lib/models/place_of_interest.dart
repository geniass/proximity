class PlaceOfInterest {
  final String id;
  final String name;
  final bool isIgnored;
  final String? notes;
  
  PlaceOfInterest({
    required this.id,
    required this.name,
    this.isIgnored = false,
    this.notes,
  });

  PlaceOfInterest copyWith({
    String? id,
    String? name,
    bool? isIgnored,
    String? notes,
  }) {
    return PlaceOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      isIgnored: isIgnored ?? this.isIgnored,
      notes: notes ?? this.notes,
    );
  }
}