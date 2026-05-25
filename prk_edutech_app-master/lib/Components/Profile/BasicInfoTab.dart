import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

import '../../Auth/TokenManager.dart';

class BasicInfoTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onUpdate;

  const BasicInfoTab({
    Key? key,
    required this.userData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _BasicInfoTabState createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();

  // API Base URL
  final String _baseUrl = buildApiUrl('profile');

  // Colors
  final Color _primaryColor = const Color(0xFF000435);
  final Color _secondaryColor = const Color(0xFFFB7E02);
  final Color _accentColor = Colors.white;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _nameController.text = widget.userData['name'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';

    if (widget.userData['profile'] != null) {
      _aboutController.text = widget.userData['profile']['about'] ?? '';
      _rollNumberController.text = widget.userData['profile']['rollNumber'] ?? '';
    }
  }

  Future<void> _updateBasicInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Authentication required');
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'about': _aboutController.text,
          'rollNumber': _rollNumberController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Basic information updated successfully');
        widget.onUpdate();
      } else {
        _showErrorSnackBar('Failed to update basic information');
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
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person,
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Phone is required' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _rollNumberController,
              label: 'Roll Number',
              prefixIcon: Icons.numbers,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _aboutController,
              label: 'About Me',
              prefixIcon: Icons.info_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateBasicInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _accentColor,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _accentColor)
                    : const Text('Update Basic Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _secondaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }
}