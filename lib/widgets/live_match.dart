import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/standings/standings.dart';
import 'dart:async'; 

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
  String _matchStatus = 'scheduled';
  bool _standingsUpdated = false;

  @override
  void initState() {
    super.initState();
    final data = widget.fixtureDocument.data() as Map<String, dynamic>;
    _matchStatus = data['matchStatus'] ?? 'scheduled';
    // Check if standings were already updated for a finished match
    _standingsUpdated = data['standingsUpdated'] ?? false;
    _updateMatchStatusAndTimer();
  }

  @override
  void didUpdateWidget(covariant LiveMatchCardFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fixtureDocument.id != widget.fixtureDocument.id ||
        oldWidget.fixtureDocument.data() != widget.fixtureDocument.data()) {
      _timer?.cancel();
      final data = widget.fixtureDocument.data() as Map<String, dynamic>;
      _matchStatus = data['matchStatus'] ?? 'scheduled';
      _standingsUpdated = data['standingsUpdated'] ?? false; 
      _updateMatchStatusAndTimer();
    }
  }

  void _updateMatchStatusAndTimer() {
    final data = widget.fixtureDocument.data() as Map<String, dynamic>;
    final Timestamp? scheduledStartTimestamp = data['timestamp'] as Timestamp?;
    final Timestamp? scheduledEndTimestamp = data['scheduledEndTimeStamp'] as Timestamp?;
    final String currentDbStatus = data['matchStatus'] ?? 'scheduled'; // Get status from DB

    if (currentDbStatus == 'finished' && _standingsUpdated) {
      setState(() {
        _matchStatus = 'finished';
        _displayTime = 'Finished';
      });
      _timer?.cancel();
      return;
    }

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
      // Match is theoretically finished based on schedule
      _matchStatus = 'finished';
      _displayTime = 'Finished';
      _updateFirestoreMatchStatus('finished'); 
    }

    setState(() {});
  }

  void _startUpcomingCountdown(DateTime startTime) {
    _timer?.cancel(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remaining = startTime.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        _updateMatchStatusAndTimer(); 
      } else {
        setState(() {
          _displayTime = 'Starts in: ${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _startLiveCountdown(DateTime endTime) {
    _timer?.cancel(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final Duration remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        _matchStatus = 'finished';
        _displayTime = 'Finished';
        _updateFirestoreMatchStatus('finished'); 
      } else {
        setState(() {
          _displayTime = 'Live: ${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  // Function to update matchStatus in Firestore AND trigger standings update
  Future<void> _updateFirestoreMatchStatus(String status) async {
    try {
      final data = widget.fixtureDocument.data() as Map<String, dynamic>;
      final String currentDbStatus = data['matchStatus'] ?? 'scheduled';
      final bool alreadyUpdated = data['standingsUpdated'] ?? false;

      // Only update if the status is changing to 'finished' and standings haven't been updated yet
      if (status == 'finished' && currentDbStatus != 'finished' && !alreadyUpdated) {
        await FirebaseFirestore.instance.collection('Fixtures').doc(widget.fixtureDocument.id).update({
          'matchStatus': status,
          'standingsUpdated': true, 
        });
        print('Fixture ${widget.fixtureDocument.id} status updated to $status and standings process initiated.');
        setState(() {
          _standingsUpdated = true; 
        });

        _updateStandings();
      } else if (status == 'finished' && alreadyUpdated) {
        print('Fixture ${widget.fixtureDocument.id} already finished and standings already updated. Skipping.');
      } else {

        await FirebaseFirestore.instance.collection('Fixtures').doc(widget.fixtureDocument.id).update({
          'matchStatus': status,
        });
        print('Fixture ${widget.fixtureDocument.id} status updated to $status.');
      }
    } catch (e) {
      print('Error updating fixture status or standings: $e');

    }
  }

  Future<void> _updateStandings() async {
    final data = widget.fixtureDocument.data() as Map<String, dynamic>;
    final String team1Name = data['team1Name'] ?? '';
    final String team2Name = data['team2Name'] ?? '';
    final String leagueType = data['leagueType'] ?? ''; 
    final String scoreString = data['score'] ?? '0 - 0';

    // Parse scores
    List<String> scores = scoreString.split(' - ');
    if (scores.length != 2) {
      print('Invalid score format: $scoreString');
      return; // Exit if score format is unexpected
    }
    final int team1Score = int.tryParse(scores[0].trim()) ?? 0;
    final int team2Score = int.tryParse(scores[1].trim()) ?? 0;

    print('Processing match: $team1Name vs $team2Name. Score: $team1Score - $team2Score');

    try {
      // Get references to the teams in the Standings collection
      final QuerySnapshot team1Snapshot = await FirebaseFirestore.instance
          .collection('Standings')
          .where('clubName', isEqualTo: team1Name)
          .where('leagueType', isEqualTo: leagueType)
          .limit(1)
          .get();

      final QuerySnapshot team2Snapshot = await FirebaseFirestore.instance
          .collection('Standings')
          .where('clubName', isEqualTo: team2Name)
          .where('leagueType', isEqualTo: leagueType)
          .limit(1)
          .get();

      if (team1Snapshot.docs.isEmpty || team2Snapshot.docs.isEmpty) {
        print('Error: One or both teams not found in Standings collection.');

        return;
      }

      final DocumentReference team1Ref = team1Snapshot.docs.first.reference;
      final DocumentReference team2Ref = team2Snapshot.docs.first.reference;
      Map<String, dynamic> team1Data = team1Snapshot.docs.first.data() as Map<String, dynamic>;
      Map<String, dynamic> team2Data = team2Snapshot.docs.first.data() as Map<String, dynamic>;

      // Initialize defaults if fields are missing (though your existing addTeamDialog should prevent this)
      int team1Points = team1Data['points'] ?? 0;
      int team1Wins = team1Data['wins'] ?? 0;
      int team1Losses = team1Data['losses'] ?? 0;
      int team1Draws = team1Data['draws'] ?? 0;
      int team1GamesPlayed = team1Data['gamesPlayed'] ?? 0;
      int team1GoalsFor = team1Data['goalsFor'] ?? 0;
      int team1GoalsAgainst = team1Data['goalsAgainst'] ?? 0;

      int team2Points = team2Data['points'] ?? 0;
      int team2Wins = team2Data['wins'] ?? 0;
      int team2Losses = team2Data['losses'] ?? 0;
      int team2Draws = team2Data['draws'] ?? 0;
      int team2GamesPlayed = team2Data['gamesPlayed'] ?? 0;
      int team2GoalsFor = team2Data['goalsFor'] ?? 0;
      int team2GoalsAgainst = team2Data['goalsAgainst'] ?? 0;

      // Increment Games Played for both teams
      team1GamesPlayed++;
      team2GamesPlayed++;

      // Update Goals For and Goals Against
      team1GoalsFor += team1Score;
      team1GoalsAgainst += team2Score;
      team2GoalsFor += team2Score;
      team2GoalsAgainst += team1Score;

      // Apply Hockey Specific Scoring Rules
      if (team1Score > team2Score) {
        team1Points += 2;
        team1Wins++;
        team2Losses++;
     } else if (team2Score > team1Score) {
        // Team 2 wins
        team2Points += 2;
        team2Wins++;
        team1Losses++;
      } else {
        team1Points += 1;
        team2Points += 1;
        team1Draws++;
        team2Draws++;
      }

      // Update Firestore documents
      await team1Ref.update({
        'points': team1Points,
        'wins': team1Wins,
        'losses': team1Losses,
        'draws': team1Draws,
        'gamesPlayed': team1GamesPlayed,
        'goalsFor': team1GoalsFor,
        'goalsAgainst': team1GoalsAgainst,
      });

      await team2Ref.update({
        'points': team2Points,
        'wins': team2Wins,
        'losses': team2Losses,
        'draws': team2Draws,
        'gamesPlayed': team2GamesPlayed,
        'goalsFor': team2GoalsFor,
        'goalsAgainst': team2GoalsAgainst,
      });

      print('Standings updated successfully for $team1Name and $team2Name.');
    } catch (e) {
      print('Error updating standings for match: $e');
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
      case 'scheduled':
      default:
        cardColor = Colors.lightBlue[300]!;
        statusTextColor = Colors.white;
        statusText = 'SCHEDULED';
        break;
    }

    final String displayScore = (_matchStatus == 'live' || _matchStatus == 'finished')
        ? (data['score'] ?? '0 - 0')
        : 'vs';

    return GestureDetector(
      onTap: () {
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
                    'assets/images/NHU.png',
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
                          Image.asset(team1Logo,
                              height: 40,
                              width: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.shield, size: 40, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            team1Name,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        displayScore,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Image.asset(team2Logo,
                              height: 40,
                              width: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.shield, size: 40, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            team2Name,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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