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
      paid: json['paid'] == true,
      isBase64: isBase64Image,
      imageBytes: imageBytes,
    );
  }
}

class TopCoursePage extends StatefulWidget {
  const TopCoursePage({Key? key}) : super(key: key);

  @override
  _TopCoursePageState createState() => _TopCoursePageState();
}

class _TopCoursePageState extends State<TopCoursePage> {
  List<Course> topCourses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTopCourses();
  }

  Future<void> fetchTopCourses() async {
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
          // Filter only top courses
          topCourses = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map(Course.fromJson)
              .where((course) => course.id.isNotEmpty)
              .where((course) => course.topCourse)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = lastStatusCode == 401
              ? 'Session expired. Please login again.'
              : 'Failed to load top courses';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Courses',
          style: TextStyle(color: Color(0xff000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFf5f2f9),
        iconTheme: const IconThemeData(color: Color(0xff000435)),
      ),
      body: Container(
        color: const Color(0xFFf5f2f9),
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
            : topCourses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_border,
                size: 100,
                color: const Color(0xFFfb7e02),
              ),
              const SizedBox(height: 20),
              Text(
                'Coming soon',
                style: TextStyle(
                  color: const Color(0xFFfb7e02),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: topCourses.length,
          itemBuilder: (context, index) {
            final course = topCourses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Course Badge
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 10,
                    //           vertical: 5,
                    //         ),
                    //         // decoration: BoxDecoration(
                    //         //   color: const Color(0xFF000435),
                    //         //   borderRadius: BorderRadius.circular(10),
                    //         // ),
                    //         child: const Row(
                    //           children: [
                    //             Icon(
                    //               Icons.star,
                    //               color: Color(0xFFfb7e02),
                    //               size: 16,
                    //             ),
                    //             SizedBox(width: 5),
                    //             Text(
                    //               'Top Course',
                    //               style: TextStyle(
                    //                 color: Color(0xFFfb7e02),
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Course Image
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(15),
                    //   child: Image.network(
                    //     course.imageUrl,
                    //     width: double.infinity,
                    //     height: 200,
                    //     fit: BoxFit.cover,
                    //     errorBuilder: (context, error, stackTrace) {
                    //       return Container(
                    //         height: 200,
                    //         color: Colors.grey,
                    //         child: const Icon(
                    //           Icons.school,
                    //           size: 100,
                    //           color: Colors.white,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Stack(
                      children: [
                        // Image with rounded top corners
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: course.isBase64
                              ? Image.memory(
                            course.imageBytes!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            course.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.school,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        // Paid/Free Badge (Positioned at Top-Right)
                        Positioned(
                          top: 10,  // Adjust vertical position
                          right: 10, // Adjust horizontal position
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // color: course.paid ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              course.paid ? 'Paid' : 'Free',
                              style: TextStyle(
                                color: course.paid ? Colors.red : Colors.green,
                                // color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Course Details
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Name
                          Text(
                            course.courseName,
                            style: const TextStyle(
                              color: Color(0xFF000435),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Instructor and Duration
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Color(0xFF000435),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                course.instructorName,
                                style: const TextStyle(
                                  color: Color(0xFF000435),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF000435),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                course.duration,
                                style: const TextStyle(
                                  color: Color(0xFF000435),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Description
                          Text(
                            course.description,
                            style: const TextStyle(
                              color: Color(0xFF000435),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Additional Details
                          Row(
                            children: [
                              // Course Dates
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Course Period',
                                      style: TextStyle(
                                        color: Color(0xFF000435),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_formatDate(course.startDate)} - ${_formatDate(course.endDate)}',
                                      style: const TextStyle(
                                        color: Color(0xFF000435),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Paid/Free and Language Badges
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8,
                                  //     vertical: 4,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: course.paid
                                  //         ? Colors.red
                                  //         : Colors.green,
                                  //     borderRadius: BorderRadius.circular(10),
                                  //   ),
                                  //   child: Text(
                                  //     course.paid ? 'Paid' : 'Free',
                                  //     style: const TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 12,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 4),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8,
                                  //     vertical: 4,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: const Color(0xFF000435),
                                  //     borderRadius: BorderRadius.circular(10),
                                  //   ),
                                  //   child: Text(
                                  //     course.language,
                                  //     style: const TextStyle(
                                  //       color: Color(0xFFfb7e02),
                                  //       fontSize: 12,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}