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
      topCourse: json['topCourse'] ?? false,  // Fix: Handle null values
      paid: json['paid'] ?? false,            // Fix: Handle null values
      isBase64: isBase64Image,
      imageBytes: imageBytes,
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<Course> courses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('courses')),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          courses = jsonResponse.map((course) => Course.fromJson(course)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load courses';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Our Courses',
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
            : courses.isEmpty
            ? Center(
          child: Text(
            'No Courses Available',
            style: TextStyle(
              color: const Color(0xFFDfb7e02),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
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
                    // Course Image
                    // ClipRRect(
                    //   borderRadius: const BorderRadius.vertical(
                    //     top: Radius.circular(15),
                    //   ),
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
                          // Course Name with Top Course Badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.courseName,
                                  style: const TextStyle(
                                    color: Color(0xFF000435),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (course.topCourse)
                                OutlinedButton(
                                  onPressed: () {  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFFfb7e02)), // Orange border
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Container(
                                    // padding: const EdgeInsets.symmetric(
                                    //   horizontal: 2,
                                    //   vertical: 2,
                                    // ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'Top Course',
                                      style: TextStyle(
                                        color: Color(0xFFfb7e02),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                                  const SizedBox(height: 4),
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