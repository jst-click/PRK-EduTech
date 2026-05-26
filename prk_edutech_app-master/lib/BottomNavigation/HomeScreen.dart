import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:testing1/Components/Sidebar/CourseDetail.dart';
import 'package:testing1/Components/Sidebar/Videos.dart';
import 'dart:convert';

// Import your TokenManager
import '../Auth/TokenManager.dart';

// Import all your sidebar page imports
import 'package:testing1/Components/Sidebar/CurrentAffair.dart';
import 'package:testing1/Components/Sidebar/LeaderBoard.dart';
import 'package:testing1/Components/Sidebar/LiveClass.dart';
import 'package:testing1/Components/Sidebar/PaidCourse.dart';
import 'package:testing1/Components/Sidebar/Tests.dart';
import 'package:testing1/Components/Sidebar/TopCourse.dart';
import 'package:testing1/Components/Sidebar/YoutubeLive.dart';

import '../Components/Sidebar/AllNotesPage.dart';
import '../Components/Sidebar/EbookApp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryColor = Color(0xFF000435);
  static const Color _accentColor = Color(0xFFFB7F03);
  static const Color _screenColor = Color(0xFFF6F7FC);

  // Profile data variables
  String _userName = 'Guest';
  String _userEmail = '';
  String? _profileImageUrl;
  List<String> carouselImages = [];
  bool isLoading = true;
  String errorMessage = '';

  // Sidebar menu items
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.contact_support,
      'title': 'Course Detail',
      'subtitle': 'Explore course content',
      'iconColor': Color(0xFFFF8A00),
      'page': CourseDetailScreen(),
    },
    {
      'icon': Icons.video_library,
      'title': 'All Videos',
      'subtitle': 'Watch video lectures',
      'iconColor': Color(0xFF6D5EF7),
      'page': AllVideosPage(),
    },
    {
      'icon': Icons.note,
      'title': 'All Notes',
      'subtitle': 'Download study materials',
      'iconColor': Color(0xFF4F9CFF),
      'page': AllNotesPage(),
    },
    {
      'icon': Icons.quiz,
      'title': 'All Test',
      'subtitle': 'Attempt chapter wise tests',
      'iconColor': Color(0xFF62BE5A),
      'page': AllTestsPage(),
    },
    {
      'icon': Icons.live_tv,
      'title': 'Online Class',
      'subtitle': 'View online class cards',
      'iconColor': Color(0xFFF34D88),
      'page': LiveClassPage(),
    },
    {
      'icon': Icons.ondemand_video,
      'title': 'YouTube Links',
      'subtitle': 'Open uploaded video links',
      'iconColor': Color(0xFFF44336),
      'page': YouTubeLiveClassPage(),
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Paid Course',
      'subtitle': 'Browse premium courses',
      'iconColor': Color(0xFFFF9800),
      'page': PaidCoursePage(),
    },
    {
      'icon': Icons.analytics,
      'title': 'Smart Test',
      'subtitle': 'AI powered mock tests',
      'iconColor': Color(0xFF26A69A),
      'page': AllTestsPage(),
    },
    {
      'icon': Icons.newspaper,
      'title': 'Current Affairs',
      'subtitle': 'Stay updated daily',
      'iconColor': Color(0xFF6C63FF),
      'page': CurrentAffairsPage(),
    },
    {
      'icon': Icons.book,
      'title': 'E Books',
      'subtitle': 'Read handpicked e-books',
      'iconColor': Color(0xFF42A5F5),
      'page': EbookApp(),
    },
    {
      'icon': Icons.star,
      'title': 'Top Course',
      'subtitle': 'Explore best programs',
      'iconColor': Color(0xFFFFC107),
      'page': TopCoursePage(),
    },
    {
      'icon': Icons.leaderboard,
      'title': 'Leaderboard',
      'subtitle': 'Track your ranking',
      'iconColor': Color(0xFF8E24AA),
      'page': LeaderboardApp(),
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchCarouselImages();
  }

  Future<void> fetchUserProfile() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(buildApiUrl('profile')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        setState(() {
          _userName = profileData['name'] ?? 'Guest';
          _userEmail = profileData['email'] ?? '';
          _profileImageUrl = profileData['profile']?['photo'];
          isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'Guest';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        _userName = 'Guest';
        isLoading = false;
      });
    }
  }

  Future<void> fetchCarouselImages() async {
    try {
      final imagesResponse =
          await http.get(Uri.parse(buildApiUrl('carouselImages/withIds')));

      if (imagesResponse.statusCode == 200) {
        final List<dynamic> responseData = json.decode(imagesResponse.body);

        // Process image URLs similar to React implementation
        final processedImages = responseData.map((image) {
          String imageUrl = image['imageUrl'];
          return imageUrl.startsWith('http')
              ? imageUrl
              : buildBaseUrl(imageUrl);
        }).toList();

        setState(() {
          carouselImages = processedImages;
        });
      } else {
        throw Exception('Failed to load carousel images');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        errorMessage = 'Failed to load data from API. Please try again later.';
      });
    }
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => item['page']));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7EAF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (item['iconColor'] as Color).withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], color: item['iconColor'], size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              item['title'],
              style: const TextStyle(
                fontSize: 13,
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Text(
                item['subtitle'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: _primaryColor.withOpacity(0.75),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: (item['iconColor'] as Color).withOpacity(0.5),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: item['iconColor'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniActionCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item['page']),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8EAF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      color: _accentColor,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: _primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 5,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFECEBFF), Color(0xFFF3EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back! ${_userName.split(' ').first} 👋',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor.withOpacity(0.75),
                  ),
                ),
                if (_userEmail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryColor.withOpacity(0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                    children: [
                      TextSpan(text: 'Continue Your\n'),
                      TextSpan(
                        text: 'Learning ',
                        style: TextStyle(color: _accentColor),
                      ),
                      TextSpan(text: 'Journey'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore courses, watch videos, attend live classes and much more.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _primaryColor.withOpacity(0.75),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (menuItems.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => menuItems[0]['page']),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Resume Learning',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 104,
            height: 148,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: (_profileImageUrl?.isNotEmpty == true ||
                    carouselImages.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _profileImageUrl?.isNotEmpty == true
                          ? _profileImageUrl!
                          : carouselImages.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Color(0xFF4A4ECB),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.school_rounded,
                    size: 60,
                    color: Color(0xFF4A4ECB),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: Color(0xFFE6A100), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keep Learning, Keep Growing!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Check your progress and achieve your goals with PRKEDUTECH.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F5F6E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(96, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'View Progress',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningList() {
    final demoCourses = [
      {
        'title': 'Mathematics',
        'topic': 'Algebra Basics',
        'progress': 0.75,
        'color': Color(0xFFEFE8FF)
      },
      {
        'title': 'Physics',
        'topic': 'Laws of Motion',
        'progress': 0.40,
        'color': Color(0xFFE1F8F4)
      },
      {
        'title': 'Chemistry',
        'topic': 'Atomic Structure',
        'progress': 0.60,
        'color': Color(0xFFFFEAF2)
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: demoCourses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final course = demoCourses[index];
          final progress = course['progress'] as double;
          return Container(
            width: 170,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: course['color'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] as String,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course['topic'] as String,
                  style: TextStyle(
                    color: _primaryColor.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: _accentColor,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = '';
                  });
                  fetchUserProfile();
                  fetchCarouselImages();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _screenColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildHeroCard(),
              ),

              // Menu Grid
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: menuItems.take(9).length,
                  itemBuilder: (context, index) {
                    return _buildMenuItem(menuItems[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: SizedBox(
                  height: 94,
                  child: Row(
                    children: [
                      Expanded(child: _buildMiniActionCard(menuItems[9])),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMiniActionCard(menuItems[10])),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMiniActionCard(menuItems[11])),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _buildProgressBanner(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'Continue Learning',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => menuItems[0]['page']),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF3E4CA6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildContinueLearningList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
