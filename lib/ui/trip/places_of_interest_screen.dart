import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/services/permission_service.dart';
import 'package:proximity/ui/trip/map_view.dart';
import 'package:proximity/ui/trip/places_of_interest_viewmodel.dart';

class PlacesOfInterestScreen extends StatefulWidget {
  final PlacesOfInterestViewModel viewModel;

  const PlacesOfInterestScreen({super.key, required this.viewModel});

  @override
  State<PlacesOfInterestScreen> createState() => _PlacesOfInterestScreenState();
}

class _PlacesOfInterestScreenState extends State<PlacesOfInterestScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _toggleViewType() {
    widget.viewModel.toggleViewType();

    if (widget.viewModel.currentView == PlacesViewType.map) {
      // Request location permission when switching to map view
      PermissionService.requestLocationPermission();
    }
  }

  void _onPlaceSelected(PlaceOfInterest place) {
    // Handle place selection from map
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: ${place.name}')));
  }

  // Navigate to the search screen
  void _navigateToSearch() {
    context.go('/trip/${widget.viewModel.tripId}/add');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.viewModel.tripName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black54),
                onPressed: _navigateToSearch,
              ),
              IconButton(
                icon: Icon(
                  widget.viewModel.currentView == PlacesViewType.list
                      ? Icons.map
                      : Icons.list,
                  color: Colors.black54,
                ),
                onPressed: _toggleViewType,
              ),
            ],
          ),
          floatingActionButton:
              widget.viewModel.currentView == PlacesViewType.map
                  ? null
                  : FloatingActionButton(
                    onPressed: _navigateToSearch,
                    backgroundColor: Colors.blueGrey,
                    child: const Icon(Icons.add),
                  ),
          body:
              widget.viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                    color: const Color(
                      0xFFE9F0F3,
                    ), // Light blue-gray background
                    child:
                        widget.viewModel.places.isEmpty
                            ? const Center(
                              child: Text(
                                'No places of interest yet.\nTap + to add some!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : widget.viewModel.currentView ==
                                PlacesViewType.list
                            ? _buildListView()
                            : PlacesMapView(
                              places: widget.viewModel.places,
                              onPlaceSelected: _onPlaceSelected,
                            ),
                  ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.viewModel.places.length,
          itemBuilder: (context, index) {
            final place = widget.viewModel.places[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  place.name,
                  style: TextStyle(
                    color: place.isIgnored ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle:
                    place.notes != null
                        ? Text(
                          place.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                place.isIgnored ? Colors.grey : Colors.black54,
                          ),
                        )
                        : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.isIgnored ? "Ignored" : "Active",
                      style: TextStyle(
                        color: place.isIgnored ? Colors.grey : Colors.green,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: place.isIgnored,
                      onChanged:
                          (value) =>
                              widget.viewModel.toggleIgnored(index, value),
                      activeColor: Colors.grey,
                      inactiveTrackColor: Colors.green.withAlpha(128),
                      inactiveThumbColor: Colors.white,
                    ),
                  ],
                ),
                onTap: () {
                  // View or edit place details
                },
              ),
            );
          },
        );
      },
    );
  }
}
