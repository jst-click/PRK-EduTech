import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

import '../../Auth/TokenManager.dart';

class ParentsInfoTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onUpdate;

  const ParentsInfoTab({
    Key? key,
    required this.userData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ParentsInfoTabState createState() => _ParentsInfoTabState();
}

class _ParentsInfoTabState extends State<ParentsInfoTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, TextEditingController>> _parentsControllers = [];

  // API Base URL
  final String _baseUrl = buildApiUrl('profile/parents');

  // Colors
  final Color _primaryColor = const Color(0xFF000435);
  final Color _secondaryColor = const Color(0xFFFB7E02);
  final Color _accentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadParentsData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var parent in _parentsControllers) {
      parent['name']!.dispose();
      parent['relationship']!.dispose();
      parent['phone']!.dispose();
      parent['email']!.dispose();
    }
    super.dispose();
  }

  void _loadParentsData() {
    // Check if profile and parents data exists
    if (widget.userData['profile'] != null &&
        widget.userData['profile']['parents'] != null &&
        widget.userData['profile']['parents'] is List) {

      final List parents = widget.userData['profile']['parents'];

      for (var parent in parents) {
        _parentsControllers.add({
          'name': TextEditingController(text: parent['name'] ?? ''),
          'relationship': TextEditingController(text: parent['relationship'] ?? ''),
          'phone': TextEditingController(text: parent['phone'] ?? ''),
          'email': TextEditingController(text: parent['email'] ?? ''),
        });
      }
    }

    // If no parents data exists, add empty form
    if (_parentsControllers.isEmpty) {
      _addNewParentForm();
    }
  }

  void _addNewParentForm() {
    setState(() {
      _parentsControllers.add({
        'name': TextEditingController(),
        'relationship': TextEditingController(),
        'phone': TextEditingController(),
        'email': TextEditingController(),
      });
    });
  }

  void _removeParentForm(int index) {
    setState(() {
      // Dispose controllers
      _parentsControllers[index]['name']!.dispose();
      _parentsControllers[index]['relationship']!.dispose();
      _parentsControllers[index]['phone']!.dispose();
      _parentsControllers[index]['email']!.dispose();

      // Remove from list
      _parentsControllers.removeAt(index);

      // If all removed, add a new empty form
      if (_parentsControllers.isEmpty) {
        _addNewParentForm();
      }
    });
  }

  Future<void> _updateParentsInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Authentication required');
        setState(() => _isLoading = false);
        return;
      }

      // Prepare parents data
      List<Map<String, String>> parentsData = [];
      for (var parent in _parentsControllers) {
        parentsData.add({
          'name': parent['name']!.text,
          'relationship': parent['relationship']!.text,
          'phone': parent['phone']!.text,
          'email': parent['email']!.text,
        });
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'parents': parentsData,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Parents information updated successfully');
        widget.onUpdate();
      } else {
        _showErrorSnackBar('Failed to update parents information');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _accentColor)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _accentColor)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Parents Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: _secondaryColor),
                  onPressed: _addNewParentForm,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Parent forms
            ...List.generate(_parentsControllers.length, (index) {
              return _buildParentForm(index);
            }),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateParentsInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _accentColor,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _accentColor)
                    : const Text('Update Parents Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentForm(int index) {
    final parent = _parentsControllers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parent ${index + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryColor
                ),
              ),
              if (_parentsControllers.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeParentForm(index),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: parent['name']!,
            label: 'Full Name',
            prefixIcon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: parent['relationship']!,
            label: 'Relationship (e.g., Father, Mother)',
            prefixIcon: Icons.family_restroom,
            validator: (value) => value!.isEmpty ? 'Relationship is required' : null,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: parent['phone']!,
            label: 'Phone Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: parent['email']!,
            label: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty || !value.contains('@')
                ? 'Enter a valid email'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _secondaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}