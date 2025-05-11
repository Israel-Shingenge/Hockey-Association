import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class EditTeamPopup extends StatefulWidget {
  final String initialTeamName;
  final DateTime? initialFoundedDate;

  const EditTeamPopup({
    super.key,
    required this.initialTeamName,
    this.initialFoundedDate,
  });

  @override
  State<EditTeamPopup> createState() => _EditTeamPopupState();
}

class _EditTeamPopupState extends State<EditTeamPopup> {
  final _teamNameController = TextEditingController();
  DateTime? _foundedDate;

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.initialTeamName;
    _foundedDate = widget.initialFoundedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _foundedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _foundedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Dunes', // Should be dynamic based on selected team
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/NHU.png', // Placeholder for team logo
                height: 80,
              ),
              Positioned(
                bottom: 0,
                right: -10,
                child: CircleAvatar(
                  backgroundColor: Colors.blue[200],
                  radius: 16,
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text('Team Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _teamNameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement edit team name functionality if needed
                  print('Edit team name');
                },
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          const Text('Founded', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: () => _selectDate(context),
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _foundedDate != null ? DateFormat('dd MMMM yyyy').format(_foundedDate!) : 'Select Date',
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              final newTeamName = _teamNameController.text.trim();
              // Implement save changes logic here, passing back the new team name and founded date
              Navigator.of(context).pop({'name': newTeamName, 'founded': _foundedDate});
              print('Save Changes clicked with name: $newTeamName, founded: $_foundedDate');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}