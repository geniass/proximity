import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/services/permission_service.dart';

class PlacesMapView extends StatefulWidget {
  final List<PlaceOfInterest> places;
  final Function(PlaceOfInterest) onPlaceSelected;

  const PlacesMapView({
    super.key,
    required this.places,
    required this.onPlaceSelected,
  });

  @override
  State<PlacesMapView> createState() => _PlacesMapViewState();
}

class _PlacesMapViewState extends State<PlacesMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _createMarkers();
  }

  @override
  void didUpdateWidget(PlacesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places != widget.places) {
      _createMarkers();
    }
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await PermissionService.requestLocationPermission();
    setState(() {
      _locationPermissionGranted = hasPermission;
    });
  }

  void _createMarkers() {
    setState(() {
      _markers =
          widget.places
              .where((place) => !place.isIgnored)
              .map(
                (place) => Marker(
                  markerId: MarkerId(place.id),
                  position: LatLng(place.latitude, place.longitude),
                  infoWindow: InfoWindow(
                    title: place.name,
                    snippet: place.notes,
                    onTap: () => widget.onPlaceSelected(place),
                  ),
                ),
              )
              .toSet();
    });

    _focusMapOnMarkers();
  }

  void _focusMapOnMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    // Default to San Francisco, doesn't actually get used
    LatLngBounds bounds = LatLngBounds(
      southwest: const LatLng(37.7749, -122.4194),
      northeast: const LatLng(37.7749, -122.4194),
    );

    if (_markers.isNotEmpty) {
      bounds = _createBoundsFromMarkers();
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    }
  }

  LatLngBounds _createBoundsFromMarkers() {
    double? minLat, maxLat, minLng, maxLng;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = minLat == null ? lat : math.min(minLat, lat);
      maxLat = maxLat == null ? lat : math.max(maxLat, lat);
      minLng = minLng == null ? lng : math.min(minLng, lng);
      maxLng = maxLng == null ? lng : math.max(maxLng, lng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            // Default to San Francisco, doesn't actually get used
            target: LatLng(37.7749, -122.4194),
            zoom: 12,
          ),
          markers: _markers,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: _locationPermissionGranted,
          onMapCreated: (controller) {
            _mapController = controller;
            _focusMapOnMarkers();
          },
        ),
        if (!_locationPermissionGranted)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              onPressed: () async {
                final granted =
                    await PermissionService.requestLocationPermission();
                setState(() {
                  _locationPermissionGranted = granted;
                });
                if (!granted) {
                  // Show dialog to open settings
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Location Permission'),
                            content: const Text(
                              'Location permission is required to show your current location on the map. '
                              'Please open settings and enable location permission.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  openAppSettings();
                                },
                                child: const Text('Open Settings'),
                              ),
                            ],
                          ),
                    );
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Enable Location'),
              ),
            ),
          ),
      ],
    );
  }
}
