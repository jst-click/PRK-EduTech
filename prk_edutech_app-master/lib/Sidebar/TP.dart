// // import 'package:flutter/material.dart';
//
// // class SideBar extends StatelessWidget {
// //   final Function? onItemSelected;
//
// //   const SideBar({Key? key, this.onItemSelected}) : super(key: key);
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Drawer(
// //       width: 350,
// //       child: ListView(
// //         padding: EdgeInsets.zero,
// //         children: [
// //           UserAccountsDrawerHeader(
// //             accountName: const Text('Amit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             accountEmail: const Text('Organization Code VGCKR'),
// //             currentAccountPicture: CircleAvatar(
// //               backgroundColor: const Color(0xFFFFF3E0),
// //               child: Icon(Icons.person, size: 50, color: Colors.black87),
// //             ),
// //             decoration: const BoxDecoration(
// //               color: Color(0xFF000435),
// //             ),
// //           ),
// //           _buildDrawerItem(context, Icons.download, 'Offline Downloads'),
// //           _buildDrawerItem(context, Icons.folder, 'Study Material'),
// //           _buildDrawerItemWithNewBadge(context, Icons.assignment, 'Free Tests'),
// //           _buildDrawerItemWithNewBadge(context, Icons.reviews, 'Students Testimonial'),
// //           _buildDrawerItem(context, Icons.edit, 'Edit Profile'),
// //           _buildDrawerItem(context, Icons.settings, 'Settings'),
// //           _buildDrawerItemWithNewBadge(context, Icons.help, 'How to use the App'),
// //           _buildDrawerItem(context, Icons.privacy_tip, 'Privacy Policy'),
// //           _buildDrawerItem(context, Icons.payment, 'Payments'),
// //           const SizedBox(height: 20),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //             child: ElevatedButton.icon(
// //               onPressed: () {},
// //               icon: const Icon(Icons.facebook, color: Colors.white),
// //               label: const Text('Share on Facebook'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.black,
// //                 foregroundColor: Colors.white,
// //                 minimumSize: const Size(double.infinity, 45),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
//
// //   Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
// //     return ListTile(
// //       leading: Icon(icon, color: Colors.black87),
// //       title: Text(title, style: const TextStyle(fontSize: 16)),
// //       onTap: () {
// //         // Close the drawer when an item is tapped
// //         Navigator.of(context).pop();
// //         // Call the callback if provided
// //         if (onItemSelected != null) {
// //           onItemSelected!(title);
// //         }
// //       },
// //     );
// //   }
//
// //   Widget _buildDrawerItemWithNewBadge(BuildContext context, IconData icon, String title) {
// //     return ListTile(
// //       leading: Icon(icon, color: Colors.black87),
// //       title: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(title, style: const TextStyle(fontSize: 16)),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //             decoration: BoxDecoration(
// //               color: Colors.black,
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: const Text('NEW',
// //                 style: TextStyle(color: Colors.white, fontSize: 12)),
// //           ),
// //         ],
// //       ),
// //       onTap: () {
// //         // Close the drawer when an item is tapped
// //         Navigator.of(context).pop();
// //         // Call the callback if provided
// //         if (onItemSelected != null) {
// //           onItemSelected!(title);
// //         }
// //       },
// //     );
// //   }
// // }
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// // Import your TokenManager
// import '../Auth/TokenManager.dart';
//
// // Import all your existing sidebar page imports
// import 'package:testing1/Components/Sidebar/Contactus.dart';
// import 'package:testing1/Components/Sidebar/CurrentAffair.dart';
// import 'package:testing1/Components/Sidebar/Ebooks.dart';
// import 'package:testing1/Components/Sidebar/LeaderBoard.dart';
// import 'package:testing1/Components/Sidebar/LiveClass.dart';
// import 'package:testing1/Components/Sidebar/Notes.dart';
// import 'package:testing1/Components/Sidebar/PaidCourse.dart';
// import 'package:testing1/Components/Sidebar/SmartTest.dart';
// import 'package:testing1/Components/Sidebar/Tests.dart';
// import 'package:testing1/Components/Sidebar/TopCourse.dart';
// import 'package:testing1/Components/Sidebar/Videos.dart';
// import 'package:testing1/Components/Sidebar/YoutubeLive.dart';
//
// class SideBar extends StatefulWidget {
//   final Function? onItemSelected;
//
//   const SideBar({Key? key, this.onItemSelected}) : super(key: key);
//
//   @override
//   _SideBarState createState() => _SideBarState();
// }
//
// class _SideBarState extends State<SideBar> {
//   // Profile data variables
//   String _userName = 'Loading...';
//   String _userEmail = '';
//   String? _profileImageUrl;
//   bool _isLoading = true;
//
//   // API endpoint
//   final String _baseUrl = 'http://82.25.110.246:5000/api/profile';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }
//
//   Future<void> _fetchUserProfile() async {
//     try {
//       // Retrieve token
//       final token = await TokenManager.getToken();
//       if (token == null) {
//         setState(() {
//           _userName = 'Guest';
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // Fetch profile data
//       final response = await http.get(
//         Uri.parse(_baseUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final profileData = json.decode(response.body);
//         setState(() {
//           _userName = profileData['name'] ?? 'User';
//           _userEmail = profileData['email'] ?? '';
//           _profileImageUrl = profileData['profile']?['photo'];
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _userName = 'Guest';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _userName = 'Guest';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       width: 350,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             accountName: Text(
//                 _userName,
//                 style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white
//                 )
//             ),
//             accountEmail: Text(
//                 _userEmail,
//                 style: const TextStyle(color: Colors.white70)
//             ),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: const Color(0xFFFFF3E0),
//               backgroundImage: _profileImageUrl != null
//                   ? NetworkImage(_profileImageUrl!)
//                   : null,
//               child: _profileImageUrl == null
//                   ? Text(
//                   _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
//                   style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF000435)
//                   )
//               )
//                   : null,
//             ),
//             decoration: const BoxDecoration(
//               color: Color(0xFF000435),
//             ),
//           ),
//           _buildDrawerItem(context, Icons.contact_support, 'Course Detail', CourseDetailsPage(courseTitle: '',)),
//           _buildDrawerItem(context, Icons.video_library, 'All Videos', AllVideosPage(courseId: '',)),
//           _buildDrawerItem(context, Icons.note, 'All Notes', AllNotesPage()),
//           _buildDrawerItem(context, Icons.quiz, 'All Test', AllTestsPage()),
//           _buildDrawerItem(context, Icons.live_tv, 'Live Class', LiveClassPage()),
//           _buildDrawerItem(context, Icons.ondemand_video, 'YouTube Live Class', YouTubeLiveClassPage()),
//           _buildDrawerItemWithNewBadge(context, Icons.shopping_cart, 'Paid Course', PaidCoursePage()),
//           _buildDrawerItem(context, Icons.analytics, 'Smart Test', SmartTestPage()),
//           _buildDrawerItemWithNewBadge(context, Icons.newspaper, 'Current Affairs', CurrentAffairsPage()),
//           _buildDrawerItem(context, Icons.book, 'E Books', EBooksPage()),
//           _buildDrawerItem(context, Icons.star, 'Top Course', TopCoursePage()),
//           _buildDrawerItem(context, Icons.leaderboard, 'Leaderboard', LeaderboardPage()),
//           _buildDrawerItem(context, Icons.contact_support, 'Contact Us', ContactUsPage()),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.share, color: Colors.white),
//               label: const Text('Share App'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF000435),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 45),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF000435)),
//       title: Text(title,
//           style: const TextStyle(fontSize: 16, color: Color(0xFF000435))),
//       onTap: () {
//         Navigator.of(context).pop();
//         Navigator.push(context, MaterialPageRoute(builder: (context) => page));
//       },
//     );
//   }
//
//   Widget _buildDrawerItemWithNewBadge(BuildContext context, IconData icon, String title, Widget page) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF000435)),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title,
//               style: const TextStyle(fontSize: 16, color: Color(0xFF000435))),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: const Color(0xFF000435),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Text('NEW',
//                 style: TextStyle(color: Colors.white, fontSize: 12)),
//           ),
//         ],
//       ),
//       onTap: () {
//         Navigator.of(context).pop();
//         Navigator.push(context, MaterialPageRoute(builder: (context) => page));
//       },
//     );
//   }
// }