import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EditTeamPage extends StatefulWidget {
  final String teamName; // Pass the team name to edit
  final String? initialClubName;
  final String? initialContactPerson;
  final String? initialEmail;
  final String? initialDescription;
  final String? teamLogoUrl; // Optional: pass the logo URL

  const EditTeamPage({
    super.key,
    required this.teamName,
    this.initialClubName,
    this.initialContactPerson,
    this.initialEmail,
    this.initialDescription,
    this.teamLogoUrl,
  });

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  final _clubNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clubNameController.text = widget.initialClubName ?? '';
    _contactPersonController.text = widget.initialContactPerson ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
  }

  void _saveChanges() {
    // Implement your logic to save the edited team details
    final updatedClubName = _clubNameController.text;
    final updatedContactPerson = _contactPersonController.text;
    final updatedEmail = _emailController.text;
    final updatedDescription = _descriptionController.text;

    print('Saving changes for ${widget.teamName}');
    print('Updated Club Name: $updatedClubName');
    print('Updated Contact Person: $updatedContactPerson');
    print('Updated Email: $updatedEmail');
    print('Updated Description: $updatedDescription');

    // After saving, you might want to navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit ${widget.teamName}'),
        centerTitle: true,
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.teamName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                      image: widget.teamLogoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.teamLogoUrl!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/default_team_logo.png'), // Replace with your default logo
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    radius: 16.0,
                    child: const Icon(Icons.edit, size: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              labelText: 'Club Name',
              controller: _clubNameController,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              labelText: 'Club contact person',
              controller: _contactPersonController,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              labelText: 'Club description',
              controller: _descriptionController,
              maxLines: null,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.edit_outlined),
      ),
    );
  }
}