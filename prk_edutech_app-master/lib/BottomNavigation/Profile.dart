import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:testing1/constants.dart';

import '../Auth/TokenManager.dart';
import '../Auth/LoginScreen.dart';
import '../Components/Profile/AddressInfoTab.dart';
import '../Components/Profile/BasicInfoTab.dart';
import '../Components/Profile/EducationInfoTab.dart';
import '../Components/Profile/ParentsInfoTab.dart';
import '../Components/Profile/PersonalDetailsTab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Loading state
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  bool _isFaqLoading = true;
  String _faqError = '';
  List<Map<String, String>> _faqItems = [];

  // Color Palette
  final Color _primaryColor = const Color(0xFF000435); // Dark Blue
  final Color _secondaryColor = const Color(0xFFFB7E02); // Orange
  final Color _accentColor = Colors.white;
  final Color _textColor = Colors.black;

  // API Base URL
  final String _baseUrl = buildApiUrl('profile');

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchUserProfile();
    _fetchFaqs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);

    try {
      // Retrieve token
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Authentication required');
        // Navigate to login if no token
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        return;
      }

      // Fetch profile data
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        setState(() {
          _userData = profileData;
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load profile');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFaqs() async {
    setState(() {
      _isFaqLoading = true;
      _faqError = '';
    });

    try {
      final response = await http.get(Uri.parse(buildApiUrl('faqs')));
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<Map<String, String>> parsedFaqs = (decoded is List ? decoded : <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'question': (item['question'] ?? '').toString(),
                'answer': (item['answer'] ?? '').toString(),
              },
            )
            .where((item) => item['question']!.isNotEmpty || item['answer']!.isNotEmpty)
            .toList();

        setState(() {
          _faqItems = parsedFaqs;
          _isFaqLoading = false;
        });
      } else {
        setState(() {
          _faqError = 'Failed to load FAQs';
          _isFaqLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _faqError = 'Error: ${e.toString()}';
        _isFaqLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _accentColor)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _accentColor)),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Authentication required');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return; // User canceled image selection

      File imageFile = File(pickedFile.path);

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/photo'));
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Refresh profile after photo upload
        await _fetchUserProfile();
        _showSuccessSnackBar('Profile Photo Updated');
      } else {
        _showErrorSnackBar('Failed to upload profile photo');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  String _getFormattedPhotoUrl(String photoPath) {
    if (photoPath.startsWith('/')) {
      // Extract the path starting from 'uploads'
      final pathSegments = photoPath.split('/');
      final uploadIndex = pathSegments.indexOf('uploads');
      if (uploadIndex != -1) {
        final relativePath = pathSegments.sublist(uploadIndex).join('/');
        return buildBaseUrl(relativePath);
      }
    }
    // If the path is already a URL or we can't find 'uploads', return as is
    return photoPath;
  }

  Future<void> _logout() async {
    await TokenManager.clearUserData();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _accentColor,
      appBar: AppBar(
        backgroundColor: _accentColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30), // Adjust height as needed
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Allow scrolling if tabs overflow
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Enables scrolling for tabs
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.only(left: 0, right: 50),
              indicatorPadding: EdgeInsets.zero, // Remove indicator padding
              labelColor: _secondaryColor,
              unselectedLabelColor: _primaryColor,
              indicatorColor: _secondaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Basic'),
                Tab(icon: Icon(Icons.family_restroom), text: 'Parents'),
                Tab(icon: Icon(Icons.contact_mail), text: 'Details'),
                Tab(icon: Icon(Icons.home), text: 'Address'),
                Tab(icon: Icon(Icons.school), text: 'Education'),
                Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _secondaryColor))
          : Column(
        children: [
          // Profile Header with Photo
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            // color: _primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _uploadProfilePhoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: _primaryColor.withOpacity(0.1),
                        backgroundImage: _userData['profile'] != null &&
                            _userData['profile']['photo'] != null
                            ? NetworkImage(_getFormattedPhotoUrl(_userData['profile']['photo']))
                            : null,
                        child: _userData['profile'] == null ||
                            _userData['profile']['photo'] == null
                            ? Icon(Icons.person, color: _primaryColor, size: 50)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: _accentColor, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _userData['name'] ?? 'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                Text(
                  _userData['email'] ?? 'email@example.com',
                  style: TextStyle(color: _textColor.withOpacity(0.7)),
                ),
                // ElevatedButton(
                //   onPressed: _logout,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: _secondaryColor, // Button fill color
                //     foregroundColor: _primaryColor, // Text color
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12), // Rounded corners
                //     ),
                //     elevation: 5, // Elevation effect
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button size
                //   ),
                //   child: Text(
                //     'Logout',
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bigger text
                //   ),
                // ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BasicInfoTab(userData: _userData, onUpdate: _fetchUserProfile),
                ParentsInfoTab(userData: _userData, onUpdate: _fetchUserProfile),
                PersonalDetailsTab(userData: _userData, onUpdate: _fetchUserProfile),
                AddressInfoTab(userData: _userData, onUpdate: _fetchUserProfile),
                EducationInfoTab(userData: _userData, onUpdate: _fetchUserProfile),
                _buildFaqTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    if (_isFaqLoading) {
      return Center(child: CircularProgressIndicator(color: _secondaryColor));
    }

    if (_faqError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_faqError, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchFaqs,
                style: ElevatedButton.styleFrom(backgroundColor: _secondaryColor),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_faqItems.isEmpty) {
      return const Center(
        child: Text(
          'No FAQs available right now.',
          style: TextStyle(color: Color(0xFF000435)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFaqs,
      color: _secondaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final faq = _faqItems[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              iconColor: _secondaryColor,
              collapsedIconColor: _primaryColor,
              title: Text(
                faq['question'] ?? '',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq['answer'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFFFB7E02),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}