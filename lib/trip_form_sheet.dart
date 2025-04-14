import 'package:flutter/material.dart';
import 'package:proximity/date_utils.dart';
import 'package:proximity/models/place_of_interest.dart';
import 'package:proximity/places_of_interest_screen.dart';

class TripFormSheet extends StatefulWidget {
  final String? initialName;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<PlaceOfInterest>? initialPlaces;

  const TripFormSheet({
    super.key,
    this.initialName,
    this.initialStartDate,
    this.initialEndDate,
    this.initialPlaces,
  });

  @override
  State<TripFormSheet> createState() => _TripFormSheetState();
}

class _TripFormSheetState extends State<TripFormSheet> {
  late TextEditingController _nameController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _noStartEndDate = false;
  List<PlaceOfInterest> _places = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
    _places = widget.initialPlaces ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showStartDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
        // If end date is before the new start date or not set, update it
        if (_selectedEndDate == null || _selectedEndDate!.isBefore(pickedDate)) {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  void _showEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

  void _navigateToPlacesOfInterest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesOfInterestScreen(
          tripName: _nameController.text.isEmpty ? 'Trip' : _nameController.text,
          initialPlaces: _places,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _places = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE9F0F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
          ),
          
          // Header with close and save buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // Save the trip and close the sheet
                  final result = {
                    'name': _nameController.text,
                    'startDate': _noStartEndDate ? null : _selectedStartDate,
                    'endDate': _noStartEndDate ? null : _selectedEndDate,
                    'places': _places,
                  };
                  Navigator.pop(context, result);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Name',
              filled: true,
              fillColor: Colors.white70,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => _nameController.clear(),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          
          // No Start/End Date toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No Start/End Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _noStartEndDate,
                onChanged: (value) {
                  setState(() {
                    _noStartEndDate = value;
                  });
                },
                activeTrackColor: Colors.grey[350],
                activeColor: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Date selection containers
          if (!_noStartEndDate)
            Column(
              children: [
                // Start date field
                GestureDetector(
                  onTap: _showStartDatePicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedStartDate != null 
                              ? formatDate(_selectedStartDate!)
                              : 'Select a date',
                          style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // End date field
                GestureDetector(
                  onTap: _showEndDatePicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedEndDate != null 
                              ? formatDate(_selectedEndDate!)
                              : 'Select a date',
                          style: TextStyle(
                            color: Colors.purple[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
    
          // Places of Interest Button
          InkWell(
            onTap: _navigateToPlacesOfInterest,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueGrey.withAlpha(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Places of Interest',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _places.isEmpty 
                            ? 'Add places to visit' 
                            : '${_places.length} places added',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blueGrey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 300), // Extra space for the sheet
        ],
      ),
    );
  }
}