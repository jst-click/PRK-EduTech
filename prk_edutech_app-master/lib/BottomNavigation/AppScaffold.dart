import 'package:flutter/material.dart';
import 'package:testing1/BottomNavigation/Batches.dart';
import 'package:testing1/BottomNavigation/ChatScreen.dart';
import 'package:testing1/BottomNavigation/JobsListings.dart';
import 'package:testing1/BottomNavigation/Profile.dart';
import 'package:testing1/BottomNavigation/Store.dart';
import 'package:testing1/Components/Sidebar/CourseDetail.dart';
import 'package:testing1/Sidebar/SideBar.dart';
import '../Components/Sidebar/Ebooks.dart';
import '../Screens/Notifications.dart';
import 'HomeScreen.dart';

class AppScaffold extends StatefulWidget {
  final Widget? customBody;
  final String? title;

  const AppScaffold({
    Key? key,
    this.customBody,
    this.title
  }) : super(key: key);

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

  // List of navigation items for bottom bar
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.class_),
      label: 'Books',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.store),
      label: 'Store',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Jobs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
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
        iconTheme: IconThemeData(color: primaryColor), // Color for the drawer icon
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
      //       backgroundColor: Colors.white, // White background
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

      // Bottom Navigation Bar with consistent styling
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor,
          selectedItemColor: accentColor,
          unselectedItemColor: primaryColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: _navItems,
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}