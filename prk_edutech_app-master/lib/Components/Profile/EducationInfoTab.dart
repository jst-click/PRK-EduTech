import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import '../../Auth/TokenManager.dart';

class EducationInfoTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onUpdate;

  const EducationInfoTab({
    Key? key,
    required this.userData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EducationInfoTabState createState() => _EducationInfoTabState();
}

class _EducationInfoTabState extends State<EducationInfoTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for college
  late TextEditingController _collegeNameController;
  late TextEditingController _collegeMarksController;

  // Controllers for 12th
  late TextEditingController _school12thNameController;
  late TextEditingController _school12thMarksController;

  // Controllers for 10th
  late TextEditingController _school10thNameController;
  late TextEditingController _school10thMarksController;

  // API Base URL
  final String _baseUrl = buildApiUrl('profile/education');

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
    _collegeNameController.dispose();
    _collegeMarksController.dispose();
    _school12thNameController.dispose();
    _school12thMarksController.dispose();
    _school10thNameController.dispose();
    _school10thMarksController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize controllers with existing data if available
    Map<String, dynamic>? education;

    if (widget.userData['profile'] != null &&
        widget.userData['profile']['education'] != null) {
      education = widget.userData['profile']['education'];
    } else {
      education = {};
    }

    final college = education?['college'] ?? {};
    final school12th = education?['school12th'] ?? {};
    final school10th = education?['school10th'] ?? {};

    _collegeNameController = TextEditingController(text: college['name'] ?? '');
    _collegeMarksController = TextEditingController(text: college['marks']?.toString() ?? '');

    _school12thNameController = TextEditingController(text: school12th['name'] ?? '');
    _school12thMarksController = TextEditingController(text: school12th['marks']?.toString() ?? '');

    _school10thNameController = TextEditingController(text: school10th['name'] ?? '');
    _school10thMarksController = TextEditingController(text: school10th['marks']?.toString() ?? '');
  }

  Future<void> _updateEducationInfo() async {
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
          'college': {
            'name': _collegeNameController.text,
            'marks': _collegeMarksController.text,
          },
          'school12th': {
            'name': _school12thNameController.text,
            'marks': _school12thMarksController.text,
          },
          'school10th': {
            'name': _school10thNameController.text,
            'marks': _school10thMarksController.text,
          },
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Educational details updated successfully');
        widget.onUpdate();
      } else {
        _showErrorSnackBar('Failed to update educational details');
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

  Widget _buildEducationSection({
    required String title,
    required TextEditingController nameController,
    required TextEditingController marksController,
    required String namePlaceholder,
    required String marksPlaceholder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 15),

          // Institution Name field
          _buildTextField(
            controller: nameController,
            label: namePlaceholder,
            prefixIcon: Icons.school_outlined,
            validator: (value) => value!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 15),

          // Marks field
          _buildTextField(
            controller: marksController,
            label: marksPlaceholder,
            prefixIcon: Icons.score_outlined,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Marks are required';
              }

              final double? marks = double.tryParse(value);
              if (marks == null) {
                return 'Please enter a valid number';
              }

              if (marks < 0 || marks > 100) {
                return 'Marks should be between 0 and 100';
              }

              return null;
            },
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
    void Function(String)? onChanged,
    int maxLines = 1,
    bool enabled = true,
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
        alignLabelWithHint: maxLines > 1,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
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
              'Educational Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // College Section
            _buildEducationSection(
              title: 'College/University Details',
              nameController: _collegeNameController,
              marksController: _collegeMarksController,
              namePlaceholder: 'College/University Name',
              marksPlaceholder: 'CGPA/Percentage',
            ),

            const SizedBox(height: 20),

            // 12th Standard Section
            _buildEducationSection(
              title: '12th Standard Details',
              nameController: _school12thNameController,
              marksController: _school12thMarksController,
              namePlaceholder: 'School Name',
              marksPlaceholder: 'Percentage',
            ),

            const SizedBox(height: 20),

            // 10th Standard Section
            _buildEducationSection(
              title: '10th Standard Details',
              nameController: _school10thNameController,
              marksController: _school10thMarksController,
              namePlaceholder: 'School Name',
              marksPlaceholder: 'Percentage',
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateEducationInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _accentColor,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _accentColor)
                    : const Text('Update Educational Details'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}