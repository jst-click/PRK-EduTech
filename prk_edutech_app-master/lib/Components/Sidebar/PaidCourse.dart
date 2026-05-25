import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
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
    bool isBase64Image = json['imageUrl'] != null &&
        json['imageUrl'].startsWith('data:image');

    Uint8List? imageBytes;
    if (isBase64Image) {
      final base64Str = json['imageUrl'].split(',')[1]; // Remove data:image/png;base64,
      imageBytes = base64Decode(base64Str);
    }
    return Course(
      id: json['_id'],
      courseName: json['courseName'],
      description: json['description'],
      instructorName: json['instructorName'],
      duration: json['duration'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      imageUrl: json['imageUrl'],
      language: json['language'],
      mode: json['mode'],
      topCourse: json['topCourse'],
      paid: json['paid'],
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
      final response = await http.get(
        Uri.parse(buildApiUrl('courses')),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          // Filter only paid courses
          paidCourses = jsonResponse
              .map((course) => Course.fromJson(course))
              .where((course) => course.paid)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load paid courses';
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
          'Paid Courses',
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
            style: const TextStyle(color: Colors.white),
          ),
        )
            : paidCourses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.paid,
                size: 100,
                color: const Color(0xFFfb7e02),
              ),
              const SizedBox(height: 20),
              Text(
                'No Paid Courses Available',
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
          itemCount: paidCourses.length,
          itemBuilder: (context, index) {
            final course = paidCourses[index];
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
                    // Paid Course Badge
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       // Container(
                    //       //   padding: const EdgeInsets.symmetric(
                    //       //     horizontal: 10,
                    //       //     vertical: 5,
                    //       //   ),
                    //       //   // decoration: BoxDecoration(
                    //       //   //   color: const Color(0xFF000435),
                    //       //   //   borderRadius: BorderRadius.circular(10),
                    //       //   // ),
                    //       //   // child: const Row(
                    //       //   //   children: [
                    //       //   //     Icon(
                    //       //   //       Icons.monetization_on,
                    //       //   //       color: Color(0xFFfb7e02),
                    //       //   //       size: 16,
                    //       //   //     ),
                    //       //   //     SizedBox(width: 5),
                    //       //   //     Text(
                    //       //   //       'Paid Course',
                    //       //   //       style: TextStyle(
                    //       //   //         color: Color(0xFFfb7e02),
                    //       //   //         fontWeight: FontWeight.bold,
                    //       //   //       ),
                    //       //   //     ),
                    //       //   //   ],
                    //       //   // ),
                    //       // ),
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

                              // Paid Badge and Language Badge
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.end,
                              //   children: [
                              //     Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 8,
                              //         vertical: 4,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: Colors.red,
                              //         borderRadius: BorderRadius.circular(10),
                              //       ),
                              //       child: const Text(
                              //         'Paid',
                              //         style: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //     const SizedBox(height: 4),
                              //     Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 8,
                              //         vertical: 4,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: const Color(0xFF000435),
                              //         borderRadius: BorderRadius.circular(10),
                              //       ),
                              //       child: Text(
                              //         course.language,
                              //         style: const TextStyle(
                              //           color: Color(0xFFfb7e02),
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
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