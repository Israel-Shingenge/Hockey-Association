class Player {
  final String firstName;
  final String lastName;
  final int age;
  final String height;
  final String position;

  Player({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.height,
    required this.position,
  });
}

class Roster {
  static final List<Player> players = [];

  static void addPlayer(Player player) {
    players.add(player);
  }
}
