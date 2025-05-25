// lib/widgets/live_match_card_firestore.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/standings/standings.dart';
import 'dart:async'; // For Timer

class LiveMatchCardFirestore extends StatefulWidget {
  final DocumentSnapshot fixtureDocument;

  const LiveMatchCardFirestore({
    super.key,
    required this.fixtureDocument,
  });

  @override
  State<LiveMatchCardFirestore> createState() => _LiveMatchCardFirestoreState();
}

class _LiveMatchCardFirestoreState extends State<LiveMatchCardFirestore> {
  Timer? _timer;
  String _displayTime = 'N/A';
  String _matchStatus = 'scheduled'; // Default status

  @override
  void initState() {
    super.initState();
    _updateMatchStatusAndTimer();
  }

  @override
  void didUpdateWidget(covariant LiveMatchCardFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fixtureDocument.id != widget.fixtureDocument.id ||
        oldWidget.fixtureDocument.data() != widget.fixtureDocument.data()) {
      _timer?.cancel(); // Cancel old timer if document changes
      _updateMatchStatusAndTimer();
    }
  }

  void _updateMatchStatusAndTimer() {
    final data = widget.fixtureDocument.data() as Map<String, dynamic>;
    final Timestamp? scheduledStartTimestamp = data['timestamp'] as Timestamp?;
    final Timestamp? scheduledEndTimestamp = data['scheduledEndTimeStamp'] as Timestamp?;

    if (scheduledStartTimestamp == null || scheduledEndTimestamp == null) {
      setState(() {
        _matchStatus = 'Error';
        _displayTime = 'Invalid data';
      });
      return;
    }

    final DateTime scheduledStartTime = scheduledStartTimestamp.toDate();
    final DateTime scheduledEndTime = scheduledEndTimestamp.toDate();
    final DateTime now = DateTime.now();

    // Determine match status
    if (now.isBefore(scheduledStartTime)) {
      _matchStatus = 'upcoming';
      _startUpcomingCountdown(scheduledStartTime);
    } else if (now.isAfter(scheduledStartTime) && now.isBefore(scheduledEndTime)) {
      _matchStatus = 'live';
      _startLiveCountdown(scheduledEndTime);
    } else {
      _matchStatus = 'finished';
      _displayTime = 'Finished';
      _updateFirestoreMatchStatus('finished'); // Update status in Firestore
    }

    setState(() {}); // Update UI based on initial status
  }

  void _startUpcomingCountdown(DateTime startTime) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remaining = startTime.difference(DateTime.now());
      if (remaining.isNegative) {
        // Match has started, switch to live countdown
        timer.cancel();
        _updateMatchStatusAndTimer(); // Re-evaluate status
      } else {
        setState(() {
          _displayTime = 'Starts in: ${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _startLiveCountdown(DateTime endTime) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        // Match has ended
        timer.cancel();
        _matchStatus = 'finished';
        _displayTime = 'Finished';
        _updateFirestoreMatchStatus('finished'); // Update status in Firestore
      } else {
        setState(() {
          _displayTime = 'Live: ${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  // Function to update matchStatus in Firestore
  Future<void> _updateFirestoreMatchStatus(String status) async {
    try {
      await FirebaseFirestore.instance.collection('Fixtures').doc(widget.fixtureDocument.id).update({
        'matchStatus': status,
      });
      print('Fixture ${widget.fixtureDocument.id} status updated to $status');
    } catch (e) {
      print('Error updating fixture status: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.fixtureDocument.data() as Map<String, dynamic>;
    final String team1Name = data['team1Name'] ?? 'Team A';
    final String team2Name = data['team2Name'] ?? 'Team B';
    final String team1Logo = 'assets/images/${team1Name.replaceAll(' ', '')}.png';
    final String team2Logo = 'assets/images/${team2Name.replaceAll(' ', '')}.png';

    Color cardColor;
    Color statusTextColor;
    String statusText;

    switch (_matchStatus) {
      case 'live':
        cardColor = Colors.red[700]!;
        statusTextColor = Colors.white;
        statusText = 'LIVE';
        break;
      case 'upcoming':
        cardColor = Colors.blue[700]!;
        statusTextColor = Colors.white;
        statusText = 'UPCOMING';
        break;
      case 'finished':
        cardColor = Colors.grey[600]!;
        statusTextColor = Colors.white;
        statusText = 'FINISHED';
        break;
      case 'scheduled': // Fallback for scheduled if not specifically upcoming/live yet
      default:
        cardColor = Colors.lightBlue[300]!;
        statusTextColor = Colors.white;
        statusText = 'SCHEDULED';
        break;
    }

    final String displayScore = (_matchStatus == 'live' || _matchStatus == 'finished')
        ? (data['score'] ?? '0 - 0')
        : 'vs';

    return GestureDetector( // Added GestureDetector for tapping
      onTap: () {
        // Navigate to the StandingsPage when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StandingsPage()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/NHU.png', // Background image for the card
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _matchStatus == 'live' ? Colors.redAccent : Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusTextColor, fontSize: 12),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(team1Logo, height: 40, width: 40, errorBuilder: (context, error, stackTrace) => Icon(Icons.shield, size: 40, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            team1Name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        displayScore,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Image.asset(team2Logo, height: 40, width: 40, errorBuilder: (context, error, stackTrace) => Icon(Icons.shield, size: 40, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            team2Name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _displayTime,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}