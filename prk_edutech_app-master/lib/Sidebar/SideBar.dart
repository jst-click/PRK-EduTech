import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:testing1/BottomNavigation/ChatScreen.dart';
import 'package:testing1/Components/NewSidebar/Resume.dart';
import '../Auth/LoginScreen.dart';
import '../Auth/TokenManager.dart';
import 'package:testing1/Components/NewSidebar/FAQ.dart';
import 'package:testing1/Components/NewSidebar/Howtouse.dart';
import 'package:testing1/Components/NewSidebar/Privacy.dart';
import 'package:testing1/Components/NewSidebar/Terms.dart';
import 'package:testing1/Components/NewSidebar/TestimonialPage.dart';
import 'package:testing1/Components/Sidebar/CurrentAffair.dart';

final Color _primaryColor = const Color(0xFF000435);
final Color _secondaryColor = const Color(0xFFFB7E02);

class SideBar extends StatefulWidget {
  final Function? onItemSelected;

  const SideBar({Key? key, this.onItemSelected}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String _userName = 'Loading...';
  String _userEmail = '';
  String? _profileImageUrl;
  bool _isLoading = true;

  final String _baseUrl = buildApiUrl('profile');
  final String _imageBaseUrl = kBaseUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        setState(() {
          _userName = 'Guest';
          _isLoading = false;
        });
        return;
      }

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
          _userName = profileData['name'] ?? 'User';
          _userEmail = profileData['email'] ?? '';
        });
        _fetchProfileImage(token);
      } else {
        setState(() {
          _userName = 'Guest';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Guest';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearUserData();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }


  Future<void> _fetchProfileImage(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/photo'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final imageData = json.decode(response.body);
        String relativePath = imageData['photoUrl'] ?? '';
        if (relativePath.isNotEmpty) {
          relativePath = relativePath.replaceFirst('/root/PRK_Edutech/prk_edutech_backend', '');
        }
        setState(() {
          _profileImageUrl = '$_imageBaseUrl$relativePath';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 350,
      child: Column(
        children: [
          SizedBox(height: 40),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.12, // Adjust height dynamically
            child: Container(
              color: Color(0xFFF5F2F9), // Set background color
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.015),
                child: Image.asset(
                  'assets/img3.png',
                  height: MediaQuery.of(context).size.height * 0.03, // Adjust image height dynamically
                ),
              ),
            ),
          ),
          // Row with profile image and logo
          Row(
            children: [
              // Profile image on left
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueGrey.shade500,
                    backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                    child: _profileImageUrl == null
                        ? Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF000435)),
                    )
                        : null,
                  ),
                ),
              ),
              // Logo on right
              // Expanded(
              //   flex: 1,
              //   child: Container(
              //     color: Colors.transparent,
              //     child: CircleAvatar(
              //       radius: 80,
              //       backgroundColor: Color(0xFFf5f2f9),
              //       child: Padding(
              //         padding: EdgeInsets.symmetric(vertical: 10),
              //         child: Image.asset('assets/logo1.png'),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          // Name and Email below row
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures Column takes minimal space
                crossAxisAlignment: CrossAxisAlignment.center, // Centers text inside Column
                children: [
                  Text(
                    _userName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500),
                    textAlign: TextAlign.center, // Centers text
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
                    textAlign: TextAlign.center, // Centers text
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.chat, 'Chatbot', ChatScreen()),
                _buildDrawerItem(context, Icons.people, 'Resume Builder', ResumeBuilderApp()),
                _buildDrawerItem(context, Icons.help, 'FAQ', FAQ()),
                _buildDrawerItem(context, Icons.newspaper, 'Current Affairs', CurrentAffairsPage()),
                _buildDrawerItem(context, Icons.reviews, 'Testimonials', TestimonialPage()),
                _buildDrawerItem(context, Icons.info, 'How to Use', Howtouse()),
                _buildDrawerItem(context, Icons.description, 'Terms & Conditions', Terms()),
                _buildDrawerItem(context, Icons.privacy_tip, 'Privacy Policy', Privacy()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor, // Button fill color
                foregroundColor: _primaryColor, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 5, // Elevation effect
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button size
              ),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bigger text
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF000435)),
      title: Text(title, style: TextStyle(fontSize: 16, color: Color(0xFF000435))),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}