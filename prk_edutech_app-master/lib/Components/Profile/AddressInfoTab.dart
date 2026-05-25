import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

import '../../Auth/TokenManager.dart';

class AddressInfoTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function onUpdate;

  const AddressInfoTab({
    Key? key,
    required this.userData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _AddressInfoTabState createState() => _AddressInfoTabState();
}

class _AddressInfoTabState extends State<AddressInfoTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sameAsPermament = false;

  // Controllers for permanent address
  late TextEditingController _permanentAddressController;
  late TextEditingController _permanentPinController;

  // Controllers for corresponding address
  late TextEditingController _correspondingAddressController;
  late TextEditingController _correspondingPinController;

  // API Base URL
  final String _baseUrl = buildApiUrl('profile/address');

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
    _permanentAddressController.dispose();
    _permanentPinController.dispose();
    _correspondingAddressController.dispose();
    _correspondingPinController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize controllers with existing data if available
    Map<String, dynamic>? permanentAddress;
    Map<String, dynamic>? correspondingAddress;

    if (widget.userData['profile'] != null &&
        widget.userData['profile']['address'] != null) {

      if (widget.userData['profile']['address']['permanent'] != null) {
        permanentAddress = widget.userData['profile']['address']['permanent'];
      }

      if (widget.userData['profile']['address']['corresponding'] != null) {
        correspondingAddress = widget.userData['profile']['address']['corresponding'];
      }
    }

    _permanentAddressController = TextEditingController(text: permanentAddress?['address'] ?? '');
    _permanentPinController = TextEditingController(text: permanentAddress?['pin'] ?? '');
    _correspondingAddressController = TextEditingController(text: correspondingAddress?['address'] ?? '');
    _correspondingPinController = TextEditingController(text: correspondingAddress?['pin'] ?? '');

    // Check if addresses are the same
    if (_permanentAddressController.text.isNotEmpty &&
        _correspondingAddressController.text.isNotEmpty &&
        _permanentAddressController.text == _correspondingAddressController.text &&
        _permanentPinController.text == _correspondingPinController.text) {
      _sameAsPermament = true;
    }
  }

  void _updateCorrespondingAddress() {
    if (_sameAsPermament) {
      _correspondingAddressController.text = _permanentAddressController.text;
      _correspondingPinController.text = _permanentPinController.text;
    }
  }

  Future<void> _updateAddressInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Authentication required');
        setState(() => _isLoading = false);
        return;
      }

      // Update corresponding address if checkbox is checked
      if (_sameAsPermament) {
        _correspondingAddressController.text = _permanentAddressController.text;
        _correspondingPinController.text = _permanentPinController.text;
      }

      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'permanent': {
            'address': _permanentAddressController.text,
            'pin': _permanentPinController.text,
          },
          'corresponding': {
            'address': _correspondingAddressController.text,
            'pin': _correspondingPinController.text,
          },
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Address information updated successfully');
        widget.onUpdate();
      } else {
        _showErrorSnackBar('Failed to update address information');
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
              'Address Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Permanent Address Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permanent Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Permanent Address field
                  _buildTextField(
                    controller: _permanentAddressController,
                    label: 'Address',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 3,
                    onChanged: (value) {
                      if (_sameAsPermament) {
                        _updateCorrespondingAddress();
                      }
                    },
                    validator: (value) => value!.isEmpty ? 'Permanent address is required' : null,
                  ),
                  const SizedBox(height: 15),

                  // Permanent PIN field
                  _buildTextField(
                    controller: _permanentPinController,
                    label: 'PIN Code',
                    prefixIcon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_sameAsPermament) {
                        _updateCorrespondingAddress();
                      }
                    },
                    validator: (value) => value!.isEmpty || value.length != 6
                        ? 'Please enter a valid 6-digit PIN code'
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Same as Permanent Address Checkbox
            Row(
              children: [
                Checkbox(
                  value: _sameAsPermament,
                  activeColor: _secondaryColor,
                  onChanged: (value) {
                    setState(() {
                      _sameAsPermament = value ?? false;
                      if (_sameAsPermament) {
                        _updateCorrespondingAddress();
                      }
                    });
                  },
                ),
                SizedBox(
                  child: Text(
                    'Correspondence address\nsame as permanent address',
                    style: TextStyle(color: _primaryColor),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Corresponding Address Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correspondence Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Corresponding Address field
                  _buildTextField(
                    controller: _correspondingAddressController,
                    label: 'Address',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 3,
                    enabled: !_sameAsPermament,
                    validator: (value) => value!.isEmpty ? 'Correspondence address is required' : null,
                  ),
                  const SizedBox(height: 15),

                  // Corresponding PIN field
                  _buildTextField(
                    controller: _correspondingPinController,
                    label: 'PIN Code',
                    prefixIcon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    enabled: !_sameAsPermament,
                    validator: (value) => value!.isEmpty || value.length != 6
                        ? 'Please enter a valid 6-digit PIN code'
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateAddressInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _accentColor,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: _accentColor)
                    : const Text('Update Address Information'),
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
}