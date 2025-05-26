import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hockey_union/events/view_events.dart'; // Assuming EventDetailPage is your full events listing page

class EventsPreviewCard extends StatelessWidget {
  const EventsPreviewCard({super.key}); // Removed the 'events' parameter

  @override
  Widget build(BuildContext context) {
    // Reference to your 'events' collection in Firestore.
    // Make sure the collection name matches exactly in Firestore.
    final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

    // Get the start of today to filter for upcoming events.
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell( // Makes the entire card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventDetailPage()), // Navigate to full EventsListingPage
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Removed 'Upcoming Events' header and icon as HomePage provides it.
              // The entire card is now tappable to navigate to all events.
              // Use StreamBuilder to fetch real-time event data
              StreamBuilder<QuerySnapshot>(
                // Query for events where 'date' (your Timestamp field) is today or in the future
                // Ordered by 'date' to get the soonest events first, and limited to 3 for preview.
                stream: eventsCollection
                    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
                    .orderBy('date', descending: false)
                    .limit(3) // Limit to show only a few upcoming events
                    .snapshots(),
                builder: (context, snapshot) {
                  // Handle error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }

                  // Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // If no upcoming events are found
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No upcoming events scheduled.',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  // Display the list of upcoming events
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.docs.map((document) {
                      final data = document.data() as Map<String, dynamic>;
                      final String eventName = data['nameOfEvent'] ?? 'No Name';
                      final Timestamp eventTimestamp = data['date'] as Timestamp;
                      final DateTime eventDate = eventTimestamp.toDate();
                      final String? location = data['location']; // Assuming you have a 'location' field
                      final String? imageUrl = data['imageUrl']; // Assuming you have an 'imageUrl' field

                      // Format the date for display
                      final String formattedDate = DateFormat('MMM d, y').format(eventDate);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased padding
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.asset( // Assuming image is an asset
                                      imageUrl,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container( // Fallback if image not found
                                          height: 60,
                                          width: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.event, color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container( // Fallback if imageUrl is null or empty
                                      height: 60,
                                      width: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.event, color: Colors.grey),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Event Details (Name, Date, Location)
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
                                    formattedDate,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (location != null && location.isNotEmpty) // Display location if available
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
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view all events >', // This text indicates the card is tappable
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}