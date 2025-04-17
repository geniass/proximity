import 'package:flutter/material.dart';
import 'package:proximity/services/places_service.dart';
import 'package:proximity/ui/search/place_search_viewmodel.dart';

class PlaceSearchScreen extends StatefulWidget {
  final PlaceSearchViewModel viewModel;

  const PlaceSearchScreen({super.key, required this.viewModel});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addPlaceToTrip(PlaceSearchResult result) async {
    try {
      await widget.viewModel.addPlaceToTrip(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${result.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add place'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for places...',
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: (query) {
            widget.viewModel.searchPlaces(query);
          },
          textInputAction: TextInputAction.search,
        ),
        actions: [
          AnimatedBuilder(
            animation: widget.viewModel,
            builder: (context, child) {
              if (widget.viewModel.searchQuery.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    widget.viewModel.clearSearch();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (widget.viewModel.searchResults.isEmpty) {
            return Center(
              child: Text(
                widget.viewModel.searchQuery.isEmpty
                    ? 'Start typing to search for places'
                    : 'No places found',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          } else {
            return _buildSearchResults();
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final result = widget.viewModel.searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              result.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Latitude: ${result.lat.toStringAsFixed(4)}, '
                    'Longitude: ${result.lng.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Colors.blueGrey,
                size: 32,
              ),
              onPressed: () => _addPlaceToTrip(result),
            ),
          ),
        );
      },
    );
  }
}
