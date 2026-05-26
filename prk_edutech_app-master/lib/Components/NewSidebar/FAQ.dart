import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'dart:convert';

class FAQ extends StatefulWidget {
  const FAQ({Key? key}) : super(key: key);

  @override
  _FAQState createState() => _FAQState();
}

class TestimonialModel {
  final String id;
  final String question;
  final String answer;

  TestimonialModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: (json['_id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
    );
  }
}

class _FAQState extends State<FAQ> {
  List<TestimonialModel> _testimonials = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTestimonials();
  }

  Future<void> _fetchTestimonials() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('faqs')),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          _testimonials = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map((item) => TestimonialModel.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(
            color: Color(0xFF000435),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
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
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _testimonials.length,
        itemBuilder: (context, index) {
          final testimonial = _testimonials[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial.question,
                    style: TextStyle(
                      color: Color(0xFF000435),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    testimonial.answer,
                    style: TextStyle(
                      color: Color(0xFFfb7e02).withOpacity(0.9),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}