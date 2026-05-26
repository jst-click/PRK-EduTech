import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/BottomNavigation/ChatScreen.dart';
import 'package:testing1/Components/NewSidebar/FAQ.dart';
import 'package:testing1/Components/NewSidebar/Howtouse.dart';
import 'package:testing1/Components/NewSidebar/Privacy.dart';
import 'package:testing1/Components/NewSidebar/Resume.dart';
import 'package:testing1/Components/NewSidebar/TestimonialPage.dart';
import 'package:testing1/Components/NewSidebar/Terms.dart';
import 'package:testing1/BottomNavigation/JobsListings.dart';
import 'package:testing1/Components/Sidebar/CurrentAffair.dart';
import 'package:testing1/constants.dart';

import '../Auth/LoginScreen.dart';
import '../Auth/TokenManager.dart';

final Color _secondaryColor = const Color(0xFFFB7E02);

class SideBar extends StatefulWidget {
  final Function? onItemSelected;

  const SideBar({super.key, this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String _userName = 'Loading...';
  String _userEmail = '';
  String? _profileImageUrl;
  bool _isProfileLoading = true;

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
          _isProfileLoading = false;
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
        await _fetchProfileImage(token);
      } else {
        setState(() {
          _userName = 'Guest';
          _isProfileLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _userName = 'Guest';
        _isProfileLoading = false;
      });
    }
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
          relativePath = relativePath.replaceFirst(
              '/root/PRK_Edutech/prk_edutech_backend', '');
        }

        setState(() {
          _profileImageUrl = '$_imageBaseUrl$relativePath';
          _isProfileLoading = false;
        });
      } else {
        setState(() {
          _isProfileLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearUserData();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _openPage(Widget page) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.9;

    return Drawer(
      width: drawerWidth.clamp(290.0, 390.0),
      backgroundColor: const Color(0xFFF5F6FB),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F9),
              ),
              child: Image.asset(
                'assets/img3.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Menu'),
                  _buildDrawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chatbot',
                    subtitle: 'Ask anything, get instant answers',
                    iconBackground: const Color(0xFFF2EEFF),
                    iconColor: const Color(0xFF7A3FF5),
                    onTap: () => _openPage(ChatScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_search_rounded,
                    title: 'Resume Builder',
                    subtitle: 'Create professional resumes',
                    iconBackground: const Color(0xFFFFF4E9),
                    iconColor: const Color(0xFFFF8C1A),
                    onTap: () => _openPage(ResumeBuilderApp()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_rounded,
                    title: 'FAQ',
                    subtitle: 'Find answers to common questions',
                    iconBackground: const Color(0xFFEAF9EF),
                    iconColor: const Color(0xFF00A85A),
                    onTap: () => _openPage(FAQ()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Current Affairs',
                    subtitle: 'Stay updated with latest news',
                    iconBackground: const Color(0xFFE9F3FF),
                    iconColor: const Color(0xFF1E88E5),
                    onTap: () => _openPage(CurrentAffairsPage()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.work_outline_rounded,
                    title: 'Jobs',
                    subtitle: 'Government and private openings',
                    iconBackground: const Color(0xFFEFF7F0),
                    iconColor: const Color(0xFF2E7D32),
                    onTap: () => _openPage(const JobsPage()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_rounded,
                    title: 'Testimonials',
                    subtitle: 'See what our learners say',
                    iconBackground: const Color(0xFFFFEEF4),
                    iconColor: const Color(0xFFEC407A),
                    onTap: () => _openPage(TestimonialPage()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: 'How to Use',
                    subtitle: 'Learn how to use the app',
                    iconBackground: const Color(0xFFF0ECFF),
                    iconColor: const Color(0xFF7E57C2),
                    onTap: () => _openPage(Howtouse()),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionLabel('More'),
                  _buildDrawerItem(
                    icon: Icons.gavel_rounded,
                    title: 'Terms and Conditions',
                    iconBackground: const Color(0xFFF0F2FA),
                    iconColor: const Color(0xFF5D657F),
                    onTap: () => _openPage(const Terms()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    iconBackground: const Color(0xFFEAF4FF),
                    iconColor: const Color(0xFF1E88E5),
                    onTap: () => _openPage(const Privacy()),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF8BB0C7),
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00133E),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isProfileLoading ? 'Loading...' : _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E1238),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isProfileLoading ? '' : _userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF5C607B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2D9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Premium Learner',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD08400),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF2F3559),
                  size: 30,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          Row(
            children: const [
              _ProfileMetric(
                icon: Icons.menu_book_rounded,
                value: '12',
                label: 'Courses',
                iconColor: Color(0xFF6A5BFF),
              ),
              _MetricDivider(),
              _ProfileMetric(
                icon: Icons.assignment_turned_in_rounded,
                value: '28',
                label: 'Tests',
                iconColor: Color(0xFF4CAF50),
              ),
              _MetricDivider(),
              _ProfileMetric(
                icon: Icons.access_time_rounded,
                value: '35',
                label: 'Hours',
                iconColor: Color(0xFFFFA000),
              ),
              _MetricDivider(),
              _ProfileMetric(
                icon: Icons.workspace_premium_rounded,
                value: '6',
                label: 'Certificates',
                iconColor: Color(0xFF42A5F5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF7A7E94),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF11163A),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6D728D),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF53587A),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _ProfileMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF161A3D),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF70748E),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: const Color(0xFFE9EBF3),
    );
  }
}
