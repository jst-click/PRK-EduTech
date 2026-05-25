import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:testing1/Components/NewSidebar/Leaderboard.dart';
import 'package:testing1/Components/Sidebar/CourseDetail.dart';
import 'package:testing1/Components/Sidebar/Ebooks.dart';
import 'package:testing1/Components/Sidebar/ResourcePage.dart';
import 'package:testing1/Components/Sidebar/VideoListScreen.dart';
import 'dart:convert';

// Import your TokenManager
import '../Auth/TokenManager.dart';

// Import all your sidebar page imports
import 'package:testing1/Components/Sidebar/Contactus.dart';
import 'package:testing1/Components/Sidebar/CurrentAffair.dart';
import 'package:testing1/Components/Sidebar/LeaderBoard.dart';
import 'package:testing1/Components/Sidebar/LiveClass.dart';
import 'package:testing1/Components/Sidebar/Notes.dart';
import 'package:testing1/Components/Sidebar/PaidCourse.dart';
import 'package:testing1/Components/Sidebar/SmartTest.dart';
import 'package:testing1/Components/Sidebar/Tests.dart';
import 'package:testing1/Components/Sidebar/TopCourse.dart';
import 'package:testing1/Components/Sidebar/Videos.dart';
import 'package:testing1/Components/Sidebar/YoutubeLive.dart';

import '../Components/Sidebar/AllNotesPage.dart';
import '../Components/Sidebar/EbookApp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      'page': CourseDetailScreen(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.video_library,
      'title': 'All Videos',
      'page': AllVideosPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.note,
      'title': 'All Notes',
      'page': AllNotesPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.quiz,
      'title': 'All Test',
      'page': AllTestsPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.live_tv,
      'title': 'Live Class',
      'page': LiveClassPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.ondemand_video,
      'title': 'YouTube Live',
      'page': YouTubeLiveClassPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Paid Course',
      'page': PaidCoursePage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.analytics,
      'title': 'Smart Test',
      'page': AllTestsPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.newspaper,
      'title': 'Current Affairs',
      'page': CurrentAffairsPage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.book,
      'title': 'E Books',
      'page': EbookApp(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.star,
      'title': 'Top Course',
      'page': TopCoursePage(),
      'hasNewBadge': false,
    },
    {
      'icon': Icons.leaderboard,
      'title': 'Leaderboard',
      'page': LeaderboardApp(),
      'hasNewBadge': false,
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
      final imagesResponse = await http.get(
          Uri.parse(buildApiUrl('carouselImages/withIds'))
      );

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
            context,
            MaterialPageRoute(builder: (context) => item['page'])
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                          item['icon'],
                          color: const Color(0xFFFB7F03),
                          size: 40
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'],
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000435),
                            fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (item['hasNewBadge'])
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000435),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom colored line
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFfb7e02), // The color you specified
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: carouselImages.isEmpty
                    ? Center(child: Text('No carousel images available'))
                    : CarouselSlider(
                  options: CarouselOptions(
                    // height: 300.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayInterval: Duration(seconds: 3),
                    viewportFraction: 0.9,
                  ),
                  items: carouselImages.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blue.shade50,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              item,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Image not available', style: TextStyle(color: Colors.grey))
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              // Menu Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItem(menuItems[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}