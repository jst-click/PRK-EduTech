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
  final bool topCourseEnabled;
  final bool paid;
  final bool isBase64;
  final Uint8List? imageBytes;
  final double rating;
  final int reviewsCount;
  final int lessonsCount;
  final int studentsCount;
  final String level;
  final bool certificate;

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
    required this.topCourseEnabled,
    required this.paid,
    required this.isBase64,
    this.imageBytes,
    required this.rating,
    required this.reviewsCount,
    required this.lessonsCount,
    required this.studentsCount,
    required this.level,
    required this.certificate,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final imageValue = (json['imageUrl'] ?? json['thumbnail'] ?? '').toString();
    final isBase64Image = imageValue.startsWith('data:image');
    final isFreeValue = json['isFree'];
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

    final parsedStartDate =
        DateTime.tryParse((json['startDate'] ?? '').toString());
    final parsedEndDate = DateTime.tryParse((json['endDate'] ?? '').toString());
    final parsedRating = double.tryParse(
            (json['rating'] ?? json['avgRating'] ?? '4.5').toString()) ??
        4.5;
    final parsedReviews = int.tryParse(
            (json['reviewsCount'] ?? json['totalReviews'] ?? '128')
                .toString()) ??
        128;
    final parsedLessons = int.tryParse(
            (json['lessonsCount'] ?? json['lessons'] ?? '28').toString()) ??
        28;
    final parsedStudents = int.tryParse(
            (json['studentsCount'] ?? json['enrolledStudents'] ?? '1200')
                .toString()) ??
        1200;
    final parsedCertificate = json['certificate'] == true ||
        (json['certificate'] ?? '').toString().toLowerCase() == 'yes';
    final topCourseEnabled = json['topCourseEnabled'] == true ||
        json['topCourse'] == true ||
        (json['status'] ?? '').toString().toLowerCase() == 'enabled' ||
        (json['status'] ?? '').toString().toLowerCase() == 'active';

    return Course(
      id: (json['_id'] ?? '').toString(),
      courseName:
          (json['courseName'] ?? json['title'] ?? 'Untitled Course').toString(),
      description:
          (json['description'] ?? json['about'] ?? 'No description available')
              .toString(),
      instructorName:
          (json['instructorName'] ?? 'Unknown Instructor').toString(),
      duration: (json['duration'] ?? 'N/A').toString(),
      startDate: parsedStartDate ?? DateTime.now(),
      endDate: parsedEndDate ?? (parsedStartDate ?? DateTime.now()),
      imageUrl: imageValue,
      language: (json['language'] ?? 'N/A').toString(),
      mode: (json['mode'] ?? json['access'] ?? 'N/A').toString(),
      topCourse: topCourseEnabled,
      topCourseEnabled: topCourseEnabled,
      paid: json['paid'] == true || !isFree,
      isBase64: isBase64Image,
      imageBytes: imageBytes,
      rating: parsedRating,
      reviewsCount: parsedReviews,
      lessonsCount: parsedLessons,
      studentsCount: parsedStudents,
      level: (json['level'] ?? 'Beginner').toString(),
      certificate: parsedCertificate,
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  final bool onlyTopCourses;
  final String headerTitle;
  final String headerSubtitle;

  const CourseDetailScreen({
    Key? key,
    this.onlyTopCourses = false,
    this.headerTitle = 'Our Courses',
    this.headerSubtitle = 'Explore our wide range of courses',
  }) : super(key: key);

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
      final token = await TokenManager.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final endpoints = <String>[
        buildApiUrl('courses'),
      ];

      http.Response? successResponse;
      int? lastStatusCode;
      for (final endpoint in endpoints) {
        final response = await http.get(Uri.parse(endpoint), headers: headers);
        debugPrint('Course API: $endpoint -> ${response.statusCode}');
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
          courses = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map(Course.fromJson)
              .where((course) => course.id.isNotEmpty)
              .where((course) => !widget.onlyTopCourses || course.topCourseEnabled)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = lastStatusCode == 401 || lastStatusCode == 403
              ? 'Session expired. Please login again.'
              : 'Failed to load courses (${lastStatusCode ?? 'unknown'})';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Course API error: $e');
      setState(() {
        errorMessage = 'Error connecting to the server';
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatStudents(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  void _openCourseDetails(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(
          course: course,
          coursePeriod:
              '${_formatDate(course.startDate)} - ${_formatDate(course.endDate)}',
          studentsText:
              '${_formatStudents(course.studentsCount)} Students Enrolled',
        ),
      ),
    );
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

    return InkWell(
      onTap: () => _openCourseDetails(course),
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
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
                      fontSize: 30 / 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person,
                          size: 16, color: Color(0xFF7E729F)),
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
                            horizontal: 10, vertical: 6),
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
                    maxLines: 1,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EDFD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton.icon(
                            onPressed: () => _openCourseDetails(course),
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFF6C55C7),
                            ),
                            label: const Text(
                              'Course Details',
                              style: TextStyle(
                                color: Color(0xFF6C55C7),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A3DE8), Color(0xFF7645F1)],
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => _openCourseDetails(course),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Enroll Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Color(0xFFD9CBFF),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Color(0xFF5B2ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6E44EF),
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Color(0xFF000435)),
                      ),
                    )
                  : courses.isEmpty
                      ? const Center(
                          child: Text(
                            'Coming soon',
                            style: TextStyle(
                              color: Color(0xFF6E44EF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(18),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      color: Color(0xFF1A1438),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.headerTitle,
                                        style: TextStyle(
                                          color: Color(0xFF1B143D),
                                          fontSize: 30 / 2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        widget.headerSubtitle,
                                        style: TextStyle(
                                          color: Color(0xFF7E7893),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2ECFF),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    size: 18,
                                    color: Color(0xFF7457DA),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: ListView.builder(
                                itemCount: courses.length,
                                itemBuilder: (context, index) =>
                                    _buildCourseCard(courses[index]),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}

class CourseDetailsPage extends StatefulWidget {
  final Course course;
  final String coursePeriod;
  final String studentsText;

  const CourseDetailsPage({
    super.key,
    required this.course,
    required this.coursePeriod,
    required this.studentsText,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  int _activeTab = 0;

  Widget _buildDetailImage(Course course) {
    if (course.isBase64 && course.imageBytes != null) {
      return Image.memory(
        course.imageBytes!,
        fit: BoxFit.cover,
      );
    }
    if (course.imageUrl.isNotEmpty) {
      return Image.network(
        course.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF3F4F8),
          child: const Center(
            child: Icon(
              Icons.school_outlined,
              size: 54,
              color: Color(0xFFB0B4C3),
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFFF3F4F8),
      child: const Center(
        child: Icon(
          Icons.school_outlined,
          size: 54,
          color: Color(0xFFB0B4C3),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isActive = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6842E8)
                    : const Color(0xFF706B87),
                fontSize: 14.2,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2.6,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive ? const Color(0xFF6842E8) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final descriptionText = widget.course.description.trim().isNotEmpty
        ? widget.course.description
        : 'This course is designed for beginners who want to build a strong foundation. You will learn step by step with practical examples and real-world projects.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About This Course',
          style: TextStyle(
            color: Color(0xFF1C1739),
            fontSize: 26 / 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          descriptionText,
          style: const TextStyle(
            color: Color(0xFF6D6787),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const _PointTile(
          icon: Icons.menu_book_rounded,
          title: 'Comprehensive Content',
          subtitle: 'All topics covered in detail with easy explanations.',
          iconColor: Color(0xFF7C61E7),
          iconBgColor: Color(0xFFF2EDFF),
        ),
        const SizedBox(height: 10),
        const _PointTile(
          icon: Icons.play_circle_outline_rounded,
          title: 'Practical Learning',
          subtitle: 'Real-world examples and hands-on practice.',
          iconColor: Color(0xFF7C61E7),
          iconBgColor: Color(0xFFF2EDFF),
        ),
        const SizedBox(height: 10),
        const _PointTile(
          icon: Icons.all_inclusive_rounded,
          title: 'Lifetime Access',
          subtitle: 'Access course content anytime, anywhere.',
          iconColor: Color(0xFF7C61E7),
          iconBgColor: Color(0xFFF2EDFF),
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFEAE8F2)),
        const SizedBox(height: 14),
        const Text(
          "What You'll Learn",
          style: TextStyle(
            color: Color(0xFF1C1739),
            fontSize: 26 / 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ChipLabel(title: 'Fundamentals & Basics'),
            _ChipLabel(title: 'Core Concepts'),
            _ChipLabel(title: 'Practical Examples'),
            _ChipLabel(title: 'Real-world Projects'),
            _ChipLabel(title: 'Tips & Best Practices'),
            _ChipLabel(title: 'And much more'),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleContent({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E7F2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6843E7), size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1C1739),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6D6787),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_activeTab == 0) return _buildOverview();
    if (_activeTab == 1) {
      return _buildSimpleContent(
        title: 'Curriculum',
        message: 'Syllabus and chapter modules will be shown here.',
        icon: Icons.view_list_rounded,
      );
    }
    if (_activeTab == 2) {
      return _buildSimpleContent(
        title: 'Instructor',
        message: widget.course.instructorName,
        icon: Icons.person_rounded,
      );
    }
    return _buildSimpleContent(
      title: 'Reviews',
      message:
          '${widget.course.rating.toStringAsFixed(1)} rating from ${widget.course.reviewsCount} learners.',
      icon: Icons.rate_review_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isSmallPhone = MediaQuery.of(context).size.width < 365;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(18),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF1A1438),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Course Details',
                            style: TextStyle(
                              color: Color(0xFF1C1739),
                              fontSize: 30 / 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2ECFF),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: Color(0xFF7457DA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000035),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF6F2FF), Color(0xFFF2EDFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: isSmallPhone ? 185 : 215,
                                    child: _buildDetailImage(course),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  course.courseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF1C1739),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: course.paid
                                            ? const Color(0xFFFFF0EB)
                                            : const Color(0xFFE9F9EE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        course.paid ? 'Paid' : 'Free',
                                        style: TextStyle(
                                          color: course.paid
                                              ? const Color(0xFFF26A47)
                                              : const Color(0xFF2D9A54),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '${course.rating.toStringAsFixed(1)} (${course.reviewsCount} Reviews)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF3A3651),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.studentsText,
                                  style: const TextStyle(
                                    color: Color(0xFF3E395B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFCFF),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE9E7F2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatTile(
                                    icon: Icons.menu_book_outlined,
                                    iconColor: const Color(0xFF6D56DB),
                                    iconBgColor: const Color(0xFFF1EDFF),
                                    title: 'Lessons',
                                    value: '${course.lessonsCount}',
                                  ),
                                ),
                                const _VerticalDivider(),
                                Expanded(
                                  child: _StatTile(
                                    icon: Icons.access_time_rounded,
                                    iconColor: const Color(0xFFF28E3C),
                                    iconBgColor: const Color(0xFFFFF3E8),
                                    title: 'Duration',
                                    value: course.duration,
                                  ),
                                ),
                                const _VerticalDivider(),
                                Expanded(
                                  child: _StatTile(
                                    icon: Icons.bar_chart_rounded,
                                    iconColor: const Color(0xFF30B65D),
                                    iconBgColor: const Color(0xFFE9F9EF),
                                    title: 'Level',
                                    value: course.level,
                                  ),
                                ),
                                const _VerticalDivider(),
                                Expanded(
                                  child: _StatTile(
                                    icon: Icons.workspace_premium_outlined,
                                    iconColor: const Color(0xFF6D56DB),
                                    iconBgColor: const Color(0xFFF1EDFF),
                                    title: 'Certificate',
                                    value: course.certificate ? 'Yes' : 'No',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1000002B),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                            child: Row(
                              children: [
                                _buildTabButton(0, 'Overview'),
                                _buildTabButton(1, 'Curriculum'),
                                _buildTabButton(2, 'Instructor'),
                                _buildTabButton(3, 'Reviews'),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEECF5)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                            child: _buildTabContent(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000030),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: 42,
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E6F0)),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                widget.course.paid ? 'Paid' : 'Free',
                                style: TextStyle(
                                  color: widget.course.paid
                                      ? const Color(0xFFF26A47)
                                      : const Color(0xFF27A04E),
                                  fontSize: 36 / 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (!widget.course.paid) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  '100% Off',
                                  style: TextStyle(
                                    color: Color(0xFF6A6682),
                                    fontSize: 15 / 1.05,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 58,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A3DE8), Color(0xFF7645F1)],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Align(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Enroll Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 9),
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Color(0xFFD9CBFF),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: Color(0xFF5B2ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBgColor;

  const _PointTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1C1739),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6D6787),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String title;

  const _ChipLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: Color(0xFF6D56DB),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3A3651),
              fontSize: 12.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7A7596),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1E193A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: const Color(0xFFE9E7F2),
    );
  }
}
