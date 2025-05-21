import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        ListTile,
        ListView,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:myapp/player.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Roster')),
      body: ListView(
        children:
            Roster.players.map((player) {
              var listTile = ListTile(
                title: Text('${player.firstName} ${player.lastName}'),
                subtitle: Text(
                  'Age: ${player.age}, Height: ${player.height}, Position: ${player.position}',
                ),
              );
              return newMethod(listTile);
            }).toList(),
      ),
    );
  }

  ListTile newMethod(ListTile listTile) => listTile;
}

class _RosterPageState extends State<RosterPage> {
  @override
  Widget build(BuildContext context) => widget.build(context);
}
