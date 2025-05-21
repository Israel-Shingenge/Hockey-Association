import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class CommitteePage extends StatelessWidget {
  const CommitteePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30, // Adjust height as needed
            child: Image.asset(
              'assets/images/NHU.png', // Replace with the actual URL of the logo
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56), // To center the title
        ],
      ),
      drawer: const HomeDrawer(), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Stack(
            alignment: Alignment.center, // Align the children of the Stack to the center
            children: <Widget>[
              Image.asset(
                'assets/images/commitee.png', // Replace with the actual URL of the banner image
                fit: BoxFit.cover,
                height: 150, // Adjust height as needed
                width: double.infinity,
              ),
              Positioned( // Use Positioned to fine-tune the text's position
                bottom: 60.0, // Adjust this value to move the text up or down
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Comitee',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
            const SizedBox(height: 20.0),
            _buildCommitteeTable(context),
            const SizedBox(height: 20.0),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildCommitteeTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(3),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Position',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Name',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          _buildTableRow('President', 'Reagon Graig'),
          _buildTableRow('Secretary', 'Jens Unterlerchner'),
          _buildTableRow('Coaching', 'Conrad Wessels'),
          _buildTableRow('Tours & Tournaments', 'Yolande Fourie'),
          _buildTableRow('Media & Communications', 'Janine van der Merwe'),
          _buildTableRow('Leagues', 'Maryke Short'),
          _buildTableRow('Rules & Technical', 'Salma Wiese'),
          _buildTableRow('Athletes Representative', 'Magreth Mengo'),
          _buildTableRow('Development', 'Izzy Tjizake'),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String position, String name) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(position),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(name),
        ),
      ],
    );
  }
}