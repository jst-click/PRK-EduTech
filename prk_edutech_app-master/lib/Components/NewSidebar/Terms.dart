import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'dart:convert';

class Terms extends StatefulWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
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
      final response = await http.get(
        Uri.parse(buildApiUrl('cms')),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final terms = (jsonResponse['terms'] ?? '').toString().trim();

        setState(() {
          _termsText = terms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load terms and conditions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Color(0xFF000435),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFA408)),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: TextStyle(color: Color(0xFF000435)),
                  ),
                )
              : _termsText.isEmpty
                  ? Center(
                      child: Text(
                        'No terms and conditions available',
                        style: TextStyle(color: Color(0xFF000435)),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF000435).withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFFDFA408).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            _termsText,
                            style: TextStyle(
                              color: Color(0xFF000435),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }
}