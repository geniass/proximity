import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/ui/trips_list/trips_list_viewmodel.dart';
import 'package:uuid/uuid.dart';

enum PlacesViewType { map, list }

class PlacesOfInterestScreen extends StatefulWidget {
  final String tripId;

  const PlacesOfInterestScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<PlacesOfInterestScreen> createState() => _PlacesOfInterestScreenState();
}

class _PlacesOfInterestScreenState extends State<PlacesOfInterestScreen> {
  late List<PlaceOfInterest> _places;
  final _uuid = const Uuid();
  
  @override
  void initState() {
    super.initState();
  }

  void _toggleIgnored(int index, bool value) {
    setState(() {
      _places[index] = _places[index].copyWith(isIgnored: value);
    });
    
    // Update the places in the view model
    final viewModel = Provider.of<TripsListViewModel>(context, listen: false);
    viewModel.updateTripPlaces(widget.tripId, _places);
  }

  void _addNewPlace() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Place of Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter place name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _places.add(PlaceOfInterest(
                    id: _uuid.v4(),
                    name: controller.text,
                  ));
                });
                
                // Update the places in the view model
                final viewModel = Provider.of<TripsListViewModel>(context, listen: false);
                viewModel.updateTripPlaces(widget.tripId, _places);
                
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "KADJFBAKDFJADKFJND", // TODO
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black54),
            onPressed: () {
              // Show on map functionality would go here
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFE9F0F3), // Light blue-gray background
        child: _places.isEmpty
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
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
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
                          onChanged: (value) => _toggleIgnored(index, value),
                          activeColor: Colors.grey,
                          inactiveTrackColor: Colors.green.withOpacity(0.5),
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
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlace,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }
}