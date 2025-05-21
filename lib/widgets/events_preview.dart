import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hockey_union/events/view_events.dart'; // Assuming EventDetailPage is your full events listing page

class EventsPreviewCard extends StatelessWidget {
  const EventsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference to your 'events' collection in Firestore.
    // Make sure the collection name matches exactly in Firestore.
    final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('Events');

    // Get the start of today to filter for upcoming events.
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.calendar_today, color: Colors.blue[900]), // Icon
                ],
              ),
              const Divider(height: 20, thickness: 1), // Separator
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
                      // Use 'nameOfEvent' as per your JSON payload
                      final String eventName = data['nameOfEvent'] ?? 'No Name';
                      // Use 'date' as per your JSON payload, which is a Timestamp
                      final Timestamp eventTimestamp = data['date'] as Timestamp;
                      final DateTime eventDate = eventTimestamp.toDate();

                      // Format the date for display
                      final String formattedDate = DateFormat('MMM d, yyyy').format(eventDate);

                      // You can add more fields here if you want to display them,
                      // for example:
                      // final String? location = data['location'];
                      // final String? duration = data['duration'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              maxLines: 1, // Limit lines for preview
                              overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            // Example of adding another field:
                            // if (location != null)
                            //   Text(
                            //     'Location: $location',
                            //     style: const TextStyle(fontSize: 11, color: Colors.grey),
                            //   ),
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
                  'Tap to view all events >',
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