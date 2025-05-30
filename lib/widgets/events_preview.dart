import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hockey_union/events/view_events.dart'; // Make sure this imports EventDetailPage as well, or adjust

class EventsPreviewCard extends StatelessWidget {
  const EventsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    // Calculate the start of today for filtering upcoming events.
    final DateTime today = DateTime.now().startOfDay;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to the full events listing page.
          // Assuming EventDetailPage is the main view for all events, or you have a dedicated EventsListPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventDetailPage()), // Or your main EventsList/Calendar page
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                // Fetch upcoming events, ordered by date and limited to 3.
                stream: eventsCollection
                    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
                    .orderBy('date')
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Handle different connection states and errors.
                  if (snapshot.hasError) {
                    return _buildErrorState(context, snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined, // A fitting icon for no events
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              'No upcoming events scheduled.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Stay tuned for exciting new announcements!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 10),
            Text(
              'Oops! Could not load events.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Error: $error', // Show error in debug, or a generic message
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
        child: CircularProgressIndicator(strokeWidth: 2), // Consistent stroke width
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
      color: Colors.grey[200], // Lighter grey for placeholder background
      child: Icon(Icons.event, color: Colors.grey[500], size: 36), // Slightly darker grey for icon
    );
  }
}

// Extension to easily get the start of the day.
extension DateTimeExtension on DateTime {
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }
}