import 'package:flutter/material.dart';
import 'package:hockey_union/news/news.dart';

class NewsPreviewCard extends StatelessWidget {
  const NewsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data for latest news (replace with actual data fetching from Firestore)
    final List<Map<String, String>> latestNews = [
      {'title': 'Local Team Wins Championship!', 'date': 'May 20, 2025'},
      {'title': 'New Season Rules Announced', 'date': 'May 18, 2025'},
      {'title': 'Player Spotlight: Jane Doe', 'date': 'May 15, 2025'},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin
      child: InkWell( // Makes the entire card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsPage()), // Navigate to full NewsPage
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
                    'Latest News',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.newspaper, color: Colors.blue[900]), // Icon
                ],
              ),
              const Divider(height: 20, thickness: 1), // Separator
              // List of latest news articles
              ...latestNews.map((news) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          maxLines: 1, // Limit lines for preview
                          overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                        ),
                        Text(
                          news['date']!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )).toList(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view all news >',
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