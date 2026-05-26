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
  int _expandedIndex = 0;

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
        final decoded = json.decode(response.body);
        final List<dynamic> jsonResponse = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : <dynamic>[];

        setState(() {
          _testimonials = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map((item) => TestimonialModel.fromJson(item))
              .where((item) => item.question.trim().isNotEmpty)
              .toList();
          _expandedIndex = _testimonials.isNotEmpty ? 0 : -1;
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
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(
            color: Color(0xFF0B123F),
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B123F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.search, color: Color(0xFF0B123F)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFfb7e02)),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Color(0xFF0B123F)),
                  ),
                )
              : _testimonials.isEmpty
                  ? const Center(
                      child: Text(
                        'No FAQs available right now.',
                        style: TextStyle(
                          color: Color(0xFF5E6576),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 14),
                        ...List.generate(
                          _testimonials.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildFaqTile(index),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildSupportCard(),
                      ],
                    ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD08A), Color(0xFFFF9D2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.question_answer_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B123F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find answers to common questions quickly and easily.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Color(0xFF61697A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(int index) {
    final item = _testimonials[index];
    final bool expanded = _expandedIndex == index;
    final String number = (index + 1).toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded ? const Color(0xFFF4B16A) : const Color(0xFFECEEF4),
          width: expanded ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _expandedIndex = expanded ? -1 : index;
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, expanded ? 12 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Color(0xFFEE8A2E),
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.question,
                      maxLines: expanded ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0B123F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFFEE8A2E),
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: const Color(0xFFE8EBF3),
                ),
                const SizedBox(height: 10),
                Text(
                  item.answer.trim().isEmpty ? '-' : item.answer,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Color(0xFF5B6378),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7E2C7)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.headset_mic_rounded, color: Color(0xFFFB8700)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Color(0xFF0B123F),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Our support team is here for you.',
                  style: TextStyle(
                    color: Color(0xFF61697A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB8700),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Contact Support',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
