import 'package:flutter/material.dart';
import 'package:proximity/ui/core/date_utils.dart';
import 'package:proximity/models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TripCard({super.key, required this.trip, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Calculate trip progress
    final progress = trip.calculateProgress();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  trip.avatarLetter,
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
                      trip.destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.startDateTime == null || trip.endDateTime == null
                          ? 'No Start/End'
                          : '${formatDate(trip.startDateTime!)} - ${formatDate(trip.endDateTime!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit icon
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[600],
                  onPressed: onEdit,
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
      ),
    );
  }
}
