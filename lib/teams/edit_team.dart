import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EditTeamPage extends StatefulWidget {
  final String teamName;
  final String? initialClubName;
  final String? initialContactPerson;
  final String? initialEmail;
  final String? initialDescription;
  final String? teamLogoUrl;

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

  File? _localImageFile;

  @override
  void initState() {
    super.initState();
    _clubNameController.text = widget.initialClubName ?? '';
    _contactPersonController.text = widget.initialContactPerson ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('team_logo_${widget.teamName}');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _localImageFile = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${widget.teamName}_logo.png';
      final savedImage = await File(pickedFile.path).copy(path);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('team_logo_${widget.teamName}', savedImage.path);

      setState(() {
        _localImageFile = savedImage;
      });
    }
  }

  void _saveChanges() {
    final updatedClubName = _clubNameController.text;
    final updatedContactPerson = _contactPersonController.text;
    final updatedEmail = _emailController.text;
    final updatedDescription = _descriptionController.text;

    print('Saving changes for ${widget.teamName}');
    print('Updated Club Name: $updatedClubName');
    print('Updated Contact Person: $updatedContactPerson');
    print('Updated Email: $updatedEmail');
    print('Updated Description: $updatedDescription');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                        image: DecorationImage(
                          image: _localImageFile != null
                              ? FileImage(_localImageFile!)
                              : widget.teamLogoUrl != null
                                  ? NetworkImage(widget.teamLogoUrl!) as ImageProvider
                                  : const AssetImage('assets/images/default_team_logo.png'),
                          fit: BoxFit.cover,
                        ),
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
            _buildTextField(labelText: 'Club Name', controller: _clubNameController),
            const SizedBox(height: 16.0),
            _buildTextField(labelText: 'Club contact person', controller: _contactPersonController),
            const SizedBox(height: 16.0),
            _buildTextField(labelText: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16.0),
            _buildTextField(labelText: 'Club description', controller: _descriptionController, maxLines: null),
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
