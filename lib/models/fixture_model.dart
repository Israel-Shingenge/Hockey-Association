class Fixture {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime date;
  final String venue;
  final int? homeScore;
  final int? awayScore;
  final bool isCompleted;

  Fixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.venue,
    this.homeScore,
    this.awayScore,
    required this.isCompleted,
  });
}