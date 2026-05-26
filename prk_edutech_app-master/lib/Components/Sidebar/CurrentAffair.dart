import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing1/constants.dart';

class CurrentAffairsPage extends StatefulWidget {
  const CurrentAffairsPage({Key? key}) : super(key: key);

  @override
  _CurrentAffairsPageState createState() => _CurrentAffairsPageState();
}

class TestimonialModel {
  final String id;
  final String question;
  final String answer;
  final String source;
  final DateTime? publishedAt;

  TestimonialModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.source,
    required this.publishedAt,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['publishedAt'] ?? json['createdAt'] ?? '').toString();
    final parsedDate = DateTime.tryParse(rawDate);
    return TestimonialModel(
      id: (json['_id'] ?? '').toString(),
      question: (json['question'] ?? 'Question coming soon').toString(),
      answer: (json['answer'] ?? 'Answer coming soon').toString(),
      source: (json['source'] ?? '').toString(),
      publishedAt: parsedDate,
    );
  }
}

class _CurrentAffairsPageState extends State<CurrentAffairsPage> {
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
        Uri.parse(buildApiUrl('current-affairs')),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jsonResponse = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : <dynamic>[];

        setState(() {
          _testimonials = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map(TestimonialModel.fromJson)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load Current Affairs';
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
          'Current Affairs',
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
          : _testimonials.isEmpty
          ? Center(
        child: Text(
          'Coming soon',
          style: TextStyle(
            color: Color(0xFFfb7e02),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
                  if (testimonial.source.isNotEmpty) ...[
                    SizedBox(height: 10),
                    Text(
                      'Source: ${testimonial.source}',
                      style: TextStyle(
                        color: Color(0xFF000435).withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (testimonial.publishedAt != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Date: ${testimonial.publishedAt!.day.toString().padLeft(2, '0')}-${testimonial.publishedAt!.month.toString().padLeft(2, '0')}-${testimonial.publishedAt!.year}',
                      style: TextStyle(
                        color: Color(0xFF000435).withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}