import 'package:flutter/material.dart';
import 'package:testing1/BottomNavigation/JobsListings.dart';
import 'package:testing1/BottomNavigation/Profile.dart';
import 'package:testing1/Components/Sidebar/CourseDetail.dart';
import 'package:testing1/Sidebar/SideBar.dart';
import '../Components/Sidebar/Ebooks.dart';
import '../Screens/Notifications.dart';
import 'HomeScreen.dart';

class AppScaffold extends StatefulWidget {
  final Widget? customBody;
  final String? title;

  const AppScaffold({Key? key, this.customBody, this.title}) : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  // Constants for app-wide styling
  static const Color primaryColor = Color(0xFF000435);
  static const Color accentColor = Color(0xFFFB7F03);
  static const Color backgroundColor = Colors.white;

  int _currentIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    HomeScreen(),
    BatchScreen(),
    CourseDetailScreen(),
    JobsPage(),
    const ProfileScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with centered logo and side elements
      appBar: AppBar(
        // Keep the default drawer hamburger menu by NOT specifying a custom leading widget
        // This will automatically connect to the drawer
        iconTheme:
            IconThemeData(color: primaryColor), // Color for the drawer icon
        title: widget.title != null
            ? Text(
                widget.title!,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        centerTitle: true, // Center the title if present
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: primaryColor,
            onPressed: () => showNotifications(context),
          ),
        ],
        // Center logo with flexible spacing
        flexibleSpace: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double imageSize = constraints.maxWidth * 0.1;
              return Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Image.asset(
                  'assets/img.png',
                  height: imageSize.clamp(30.0, 50.0), // Min 30, Max 50
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
      ),

      // Side drawer
      drawer: const SideBar(),
      // Rest of your scaffold content@override
      // Widget build(BuildContext context) {
      //   return Scaffold(
      //     // AppBar with centered logo and side elements
      //     appBar: AppBar(
      //       backgroundColor: const Color(0xFFFFF3E0), // White background
      //       // Keep the default drawer hamburger menu by NOT specifying a custom leading widget
      //       // This will automatically connect to the drawer
      //       iconTheme: IconThemeData(color: primaryColor), // Color for the drawer icon
      //       title: widget.title != null
      //           ? Text(
      //               widget.title!,
      //               style: const TextStyle(
      //                 color: primaryColor,
      //                 fontSize: 18,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             )
      //           : null,
      //       centerTitle: true, // Center the title if present
      //       actions: [
      //         IconButton(
      //           icon: const Icon(Icons.notifications),
      //           color: primaryColor,
      //           onPressed: () => showNotifications(context),
      //         ),
      //       ],
      //       // Center logo with flexible spacing
      //       flexibleSpace: Center(
      //         child: LayoutBuilder(
      //           builder: (context, constraints) {
      //             double imageSize = constraints.maxWidth * 0.1;
      //             return Padding(
      //               padding: const EdgeInsets.only(top: 30.0),
      //               child: Image.asset(
      //                 'assets/img.png',
      //                 height: imageSize.clamp(30.0, 50.0), // Min 30, Max 50
      //                 fit: BoxFit.contain,
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     ),
      //
      //     // Side drawer
      //     drawer: const SideBar(),
      //     // Rest of your scaffold content
      //   );
      // }
      // Body with current screen or custom body
      body: widget.customBody ?? _screens[_currentIndex],

      // Rounded floating bottom navigation, closer to mock UI
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onNavItemTapped,
            backgroundColor: backgroundColor,
            indicatorColor: accentColor.withOpacity(0.2),
            shadowColor: Colors.black.withOpacity(0.18),
            elevation: 8,
            height: 68,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.menu_book_rounded), label: 'Books'),
              NavigationDestination(
                  icon: Icon(Icons.school_rounded), label: 'Course'),
              NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded), label: 'Jobs'),
              NavigationDestination(
                  icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
