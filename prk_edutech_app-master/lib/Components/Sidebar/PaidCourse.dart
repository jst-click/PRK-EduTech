import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:testing1/Auth/TokenManager.dart';
import 'package:testing1/constants.dart';

class Course {
  final String id;
  final String courseName;
  final String description;
  final String instructorName;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String language;
  final String mode;
  final bool topCourse;
  final bool paid;
  final bool isBase64;
  final Uint8List? imageBytes;

  Course({
    required this.id,
    required this.courseName,
    required this.description,
    required this.instructorName,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.language,
    required this.mode,
    required this.topCourse,
    required this.paid,
    required this.isBase64,
    this.imageBytes,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final imageValue = (json['imageUrl'] ?? '').toString();
    final isBase64Image = imageValue.startsWith('data:image');
    final paidValue = json['paid'];
    final pricingValue = (json['pricing'] ?? '').toString().toLowerCase();
    final isFreeValue = json['isFree'];
    final hasIsFree = json.containsKey('isFree') && isFreeValue != null;

    final isPaidFromPaidField = paidValue == true ||
        paidValue?.toString().toLowerCase() == 'true' ||
        paidValue?.toString() == '1' ||
        paidValue?.toString().toLowerCase() == 'paid';

    final isPaidFromPricing =
        pricingValue == 'paid' || pricingValue == 'premium';

    final isFree = isFreeValue == true ||
        isFreeValue?.toString().toLowerCase() == 'true' ||
        isFreeValue?.toString() == '1';

    Uint8List? imageBytes;
    if (isBase64Image) {
      try {
        final base64Str = imageValue.split(',')[1];
        imageBytes = base64Decode(base64Str);
      } catch (_) {
        imageBytes = null;
      }
    }

    final parsedStartDate = DateTime.tryParse((json['startDate'] ?? '').toString());
    final parsedEndDate = DateTime.tryParse((json['endDate'] ?? '').toString());

    return Course(
      id: (json['_id'] ?? '').toString(),
      courseName: (json['courseName'] ?? 'Untitled Course').toString(),
      description: (json['description'] ?? 'No description available').toString(),
      instructorName: (json['instructorName'] ?? 'Unknown Instructor').toString(),
      duration: (json['duration'] ?? 'N/A').toString(),
      startDate: parsedStartDate ?? DateTime.now(),
      endDate: parsedEndDate ?? (parsedStartDate ?? DateTime.now()),
      imageUrl: imageValue,
      language: (json['language'] ?? 'N/A').toString(),
      mode: (json['mode'] ?? 'N/A').toString(),
      topCourse: json['topCourse'] == true,
      paid: isPaidFromPaidField || isPaidFromPricing || (hasIsFree && !isFree),
      isBase64: isBase64Image,
      imageBytes: imageBytes,
    );
  }
}

class PaidCoursePage extends StatefulWidget {
  const PaidCoursePage({Key? key}) : super(key: key);

  @override
  _PaidCoursePageState createState() => _PaidCoursePageState();
}

class _PaidCoursePageState extends State<PaidCoursePage> {
  List<Course> paidCourses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPaidCourses();
  }

  Future<void> fetchPaidCourses() async {
    try {
      final token = await TokenManager.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final endpoints = <String>[
        buildApiUrl('courses'),
        buildBaseUrl('courses'),
      ];

      http.Response? successResponse;
      int? lastStatusCode;
      for (final endpoint in endpoints) {
        final response = await http.get(Uri.parse(endpoint), headers: headers);
        lastStatusCode = response.statusCode;
        if (response.statusCode == 200) {
          successResponse = response;
          break;
        }
      }

      if (successResponse != null) {
        final decoded = json.decode(successResponse.body);
        final List<dynamic> jsonResponse = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : <dynamic>[];
        setState(() {
          // Filter only paid courses
          paidCourses = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map(Course.fromJson)
              .where((course) => course.id.isNotEmpty)
              .where((course) => course.paid)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = lastStatusCode == 401
              ? 'Session expired. Please login again.'
              : 'Failed to load paid courses';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to the server';
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCourseImage(Course course) {
    if (course.isBase64 && course.imageBytes != null) {
      return Image.memory(
        course.imageBytes!,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
      );
    }

    if (course.imageUrl.isNotEmpty) {
      return Image.network(
        course.imageUrl,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 190,
            color: const Color(0xFFF3F4F8),
            child: const Center(
              child: Icon(
                Icons.school_outlined,
                size: 72,
                color: Color(0xFFB0B4C3),
              ),
            ),
          );
        },
      );
    }

    return Container(
      height: 190,
      color: const Color(0xFFF3F4F8),
      child: const Center(
        child: Icon(
          Icons.school_outlined,
          size: 72,
          color: Color(0xFFB0B4C3),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final badgeBg =
        course.paid ? const Color(0xFFFFF0EB) : const Color(0xFFE9F9EE);
    final badgeText =
        course.paid ? const Color(0xFFF26A47) : const Color(0xFF37A45E);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000435),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: _buildCourseImage(course),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.paid ? 'Paid' : 'Free',
                    style: TextStyle(
                      color: badgeText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: Color(0xFF6D6290),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF10023C),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Color(0xFF7E729F)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        course.instructorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF3F3560),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF6E53D8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            course.duration,
                            style: const TextStyle(
                              color: Color(0xFF6E53D8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5A5372),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFEDEAF3)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: Color(0xFFF2822B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course Period',
                            style: TextStyle(
                              color: Color(0xFF150C3C),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${_formatDate(course.startDate)} - ${_formatDate(course.endDate)}',
                            style: const TextStyle(
                              color: Color(0xFF4F476A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paid Courses',
          style: TextStyle(color: Color(0xff000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFf5f2f9),
        iconTheme: const IconThemeData(color: Color(0xff000435)),
      ),
      body: Container(
        color: const Color(0xFFF6F7FC),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFfb7e02),
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFF000435)),
                    ),
                  )
            : paidCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.paid,
                          size: 100,
                          color: Color(0xFFfb7e02),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            color: Color(0xFFfb7e02),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: paidCourses.length,
                    itemBuilder: (context, index) =>
                        _buildCourseCard(paidCourses[index]),
                  ),
      ),
    );
  }
}