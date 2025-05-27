import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hockey_union/events/view_events.dart'; 

class EventsPreviewCard extends StatelessWidget {
  const EventsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the Firestore collection reference once.
    final CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    // Calculate the start of today for filtering upcoming events.
    final DateTime today = DateTime.now().startOfDay; // Using a convenient extension

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to the full events listing page.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventDetailPage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                // Fetch upcoming events, ordered by date and limited to 3.
                stream: eventsCollection
                    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
                    .orderBy('date') // Default to ascending for upcoming events
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Handle different connection states and errors.
                  if (snapshot.hasError) {
                    return _buildMessage('Error loading events: ${snapshot.error}',
                        color: Colors.red);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingIndicator();
                  }

                  // If no upcoming events, display a message.
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildMessage('No upcoming events scheduled.');
                  }

                  // Display the list of upcoming events.
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.docs
                        .map((document) =>
                            _buildEventListItem(document.data() as Map<String, dynamic>))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build individual event list items.
  Widget _buildEventListItem(Map<String, dynamic> data) {
    final String eventName = data['nameOfEvent'] ?? 'No Name';
    final DateTime eventDate = (data['date'] as Timestamp).toDate();
    final String? location = data['location'];
    final String? imageUrl = data['imageUrl'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventImage(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d, y').format(eventDate),
                  style: const TextStyle(color: Colors.grey),
                ),
                if (location != null && location.isNotEmpty)
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for displaying messages (errors, no data).
  Widget _buildMessage(String message, {Color color = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: color),
        ),
      ),
    );
  }
}

// Custom widget for the loading indicator.
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Custom widget for displaying event images with fallbacks.
class _EventImage extends StatelessWidget {
  final String? imageUrl;

  const _EventImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.asset(
              imageUrl!,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackImage();
              },
            )
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.event, color: Colors.grey),
    );
  }
}

// Extension to easily get the start of the day.
extension DateTimeExtension on DateTime {
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }
}