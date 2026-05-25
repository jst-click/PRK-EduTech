import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

import '../../Auth/TokenManager.dart';

class PersonalDetailsTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onUpdate;

  const PersonalDetailsTab({
    Key? key,
    required this.userData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _PersonalDetailsTabState createState() => _PersonalDetailsTabState();
}

class _PersonalDetailsTabState extends State<PersonalDetailsTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _nationalityController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _aadharNumberController;
  late TextEditingController _panController;

  // API Base URL
  final String _baseUrl = buildApiUrl('profile/personal');

  // Colors
  final Color _primaryColor = const Color(0xFF000435);
  final Color _secondaryColor = const Color(0xFFFB7E02);
  final Color _accentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _dobController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _bloodGroupController.dispose();
    _aadharNumberController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize controllers with existing data if available
    Map<String, dynamic>? personalDetails;

    if (widget.userData['profile'] != null &&
        widget.userData['profile']['personalDetails'] != null) {
      personalDetails = widget.userData['profile']['personalDetails'];
    }

    _dobController = TextEditingController(
        text: personalDetails?['dob'] != null
            ? _formatDate(personalDetails!['dob'])
            : ''
    );
    _genderController = TextEditingController(text: personalDetails?['gender'] ?? '');
    _nationalityController = TextEditingController(text: personalDetails?['nationality'] ?? '');
    _bloodGroupController = TextEditingController(text: personalDetails?['bloodGroup'] ?? '');
    _aadharNumberController = TextEditingController(text: personalDetails?['aadharNumber'] ?? '');
    _panController = TextEditingController(text: personalDetails?['pan'] ?? '');
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    String initialDateStr = _dobController.text;
    DateTime initialDate;

    try {
      initialDate = initialDateStr.isNotEmpty
          ? DateTime.parse(initialDateStr)
          : DateTime.now().subtract(const Duration(days: 365 * 18)); // Default to 18 years ago
    } catch (e) {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: _accentColor,
              onSurface: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _updatePersonalDetails() async {
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
          'dob': _dobController.text,
          'gender': _genderController.text,
          'nationality': _nationalityController.text,
          'bloodGroup': _bloodGroupController.text,
          'aadharNumber': _aadharNumberController.text,
          'pan': _panController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Personal details updated successfully');
        widget.onUpdate();
      } else {
        _showErrorSnackBar('Failed to update personal details');
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
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Date of Birth field with date picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  prefixIcon: Icons.calendar_today,
                  validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Gender field
            _buildTextField(
              controller: _genderController,
              label: 'Gender',
              prefixIcon: Icons.person_outline,
              validator: (value) => value!.isEmpty ? 'Gender is required' : null,
            ),
            const SizedBox(height: 15),

            // Nationality field
            _buildTextField(
              controller: _nationalityController,
              label: 'Nationality',
              prefixIcon: Icons.flag_outlined,
              validator: (value) => value!.isEmpty ? 'Nationality is required' : null,
            ),
            const SizedBox(height: 15),

            // Blood Group field
            _buildTextField(
              controller: _bloodGroupController,
              label: 'Blood Group',
              prefixIcon: Icons.bloodtype_outlined,
              validator: (value) => value!.isEmpty ? 'Blood group is required' : null,
            ),
            const SizedBox(height: 15),

            // Aadhar Number field
            _buildTextField(
              controller: _aadharNumberController,
              label: 'Aadhar Number',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty || value.length != 12
                  ? 'Please enter a valid 12-digit Aadhar number'
                  : null,
            ),
            const SizedBox(height: 15),

            // PAN field
            _buildTextField(
              controller: _panController,
              label: 'PAN',
              prefixIcon: Icons.credit_card_outlined,
              validator: (value) => value!.isEmpty || value.length != 10
                  ? 'Please enter a valid 10-character PAN'
                  : null,
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePersonalDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _accentColor,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _accentColor)
                    : const Text('Update Personal Details'),
              ),
            ),
            const SizedBox(height: 20),

            // Document upload info
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