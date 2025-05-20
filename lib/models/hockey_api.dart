import 'package:hockey_union/api/hockey/models/news_model.dart';
import 'package:hockey_union/api/hockey/models/fixture_model.dart';
import 'package:hockey_union/api/hockey/models/standing_model.dart';
import 'package:hockey_union/api/hockey/mock_data.dart';

class HockeyApi {
  // Simulate network delay
  final Duration _delay = const Duration(milliseconds: 500);

  // Get latest news
  Future<List<News>> getNews() async {
    await Future.delayed(_delay);
    return mockNews;
  }

  // Get upcoming fixtures
  Future<List<Fixture>> getUpcomingFixtures() async {
    await Future.delayed(_delay);
    return mockFixtures.where((f) => !f.isCompleted).toList();
  }

  // Get completed fixtures
  Future<List<Fixture>> getCompletedFixtures() async {
    await Future.delayed(_delay);
    return mockFixtures.where((f) => f.isCompleted).toList();
  }

  // Get standings for a league/division
  Future<List<Standing>> getStandings(String division) async {
    await Future.delayed(_delay);
    return mockStandings.where((s) => s.division == division).toList();
  }

  // Get all divisions with standings
  Future<Map<String, List<Standing>>> getAllStandings() async {
    await Future.delayed(_delay);
    return {
      'Premier League': mockStandings.where((s) => s.division == 'Premier League').toList(),
      'First Division': mockStandings.where((s) => s.division == 'First Division').toList(),
    };
  }
}