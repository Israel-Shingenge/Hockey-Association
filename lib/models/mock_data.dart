import 'package:hockey_union/api/hockey/models/news_model.dart';
import 'package:hockey_union/api/hockey/models/fixture_model.dart';
import 'package:hockey_union/api/hockey/models/standing_model.dart';

// Mock news data
final List<News> mockNews = [
  News(
    id: '1',
    title: 'Namibia Hockey Union Announces New Season',
    content: 'The Namibia Hockey Union has announced the dates for the upcoming 2023 season...',
    date: DateTime(2023, 2, 15),
    imageUrl: 'https://example.com/hockey1.jpg',
    author: 'NHU Admin',
  ),
  News(
    id: '2',
    title: 'National Team Prepares for African Cup',
    content: 'The Namibian national hockey team has begun intensive training...',
    date: DateTime(2023, 2, 10),
    imageUrl: 'https://example.com/hockey2.jpg',
    author: 'Sports Reporter',
  ),
];

// Mock fixture data
final List<Fixture> mockFixtures = [
  Fixture(
    id: '1',
    homeTeam: 'Windhoek HC',
    awayTeam: 'Swakopmund HC',
    date: DateTime(2023, 3, 15, 16, 0),
    venue: 'Windhoek Hockey Stadium',
    isCompleted: false,
  ),
  Fixture(
    id: '2',
    homeTeam: 'Coastal Raiders',
    awayTeam: 'Northern Stars',
    date: DateTime(2023, 3, 16, 14, 0),
    venue: 'Swakopmund Sports Complex',
    isCompleted: false,
  ),
  Fixture(
    id: '3',
    homeTeam: 'Windhoek HC',
    awayTeam: 'Coastal Raiders',
    date: DateTime(2023, 2, 10, 16, 0),
    venue: 'Windhoek Hockey Stadium',
    homeScore: 3,
    awayScore: 1,
    isCompleted: true,
  ),
];

// Mock standing data
final List<Standing> mockStandings = [
  Standing(
    team: 'Windhoek HC',
    division: 'Premier League',
    played: 5,
    won: 4,
    drawn: 1,
    lost: 0,
    goalsFor: 15,
    goalsAgainst: 5,
    points: 13,
  ),
  Standing(
    team: 'Coastal Raiders',
    division: 'Premier League',
    played: 5,
    won: 3,
    drawn: 1,
    lost: 1,
    goalsFor: 12,
    goalsAgainst: 8,
    points: 10,
  ),
  Standing(
    team: 'Northern Stars',
    division: 'First Division',
    played: 4,
    won: 3,
    drawn: 0,
    lost: 1,
    goalsFor: 10,
    goalsAgainst: 6,
    points: 9,
  ),
];