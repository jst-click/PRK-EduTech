import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'dart:convert';

class TestimonialPage extends StatefulWidget {
  const TestimonialPage({Key? key}) : super(key: key);

  @override
  _TestimonialPageState createState() => _TestimonialPageState();
}

class TestimonialModel {
  final String id;
  final String name;
  final String designation;
  final String message;
  final int rating;

  TestimonialModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.message,
    required this.rating,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    final parsedRating = int.tryParse((json['rating'] ?? 5).toString()) ?? 5;
    return TestimonialModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['question'] ?? '').toString(),
      designation: (json['designation'] ?? '').toString(),
      message: (json['message'] ?? json['answer'] ?? '').toString(),
      rating: parsedRating.clamp(1, 5),
    );
  }
}

class _TestimonialPageState extends State<TestimonialPage> {
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
        Uri.parse(buildApiUrl('testimonials')),
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
          _error = 'Failed to load testimonials';
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
          'Testimonials',
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
                    testimonial.name,
                    style: TextStyle(
                      color: Color(0xFF000435),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (testimonial.designation.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      testimonial.designation,
                      style: TextStyle(
                        color: Color(0xFF000435).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      testimonial.rating,
                          (index) => const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(Icons.star, size: 16, color: Color(0xFFDFA408)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    testimonial.message,
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