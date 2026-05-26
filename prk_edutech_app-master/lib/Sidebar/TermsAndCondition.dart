import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  String _termsText = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      final response = await http.get(Uri.parse(buildApiUrl('cms')));
      if (response.statusCode == 200) {
        final Map<String, dynamic> payload = json.decode(response.body);
        setState(() {
          _termsText = (payload['terms'] ?? '').toString().trim();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load terms and conditions';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Error loading terms and conditions';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
              : _termsText.isEmpty
                  ? const Center(
                      child: Text(
                        'No terms and conditions available',
                        style: TextStyle(color: Color(0xFF000435)),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _termsText,
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