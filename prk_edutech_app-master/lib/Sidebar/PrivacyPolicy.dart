import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _privacyText = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchPrivacy();
  }

  Future<void> _fetchPrivacy() async {
    try {
      final response = await http.get(Uri.parse(buildApiUrl('cms')));
      if (response.statusCode == 200) {
        final Map<String, dynamic> payload = json.decode(response.body);
        setState(() {
          _privacyText = (payload['privacy'] ?? '').toString().trim();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load privacy policy';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Error loading privacy policy';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF000435),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Color(0xFF000435)),
                  ),
                )
              : _privacyText.isEmpty
                  ? const Center(
                      child: Text(
                        'No privacy policy available',
                        style: TextStyle(color: Color(0xFF000435)),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _privacyText,
                        style: const TextStyle(
                          color: Color(0xFF000435),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
    );
  }
}
