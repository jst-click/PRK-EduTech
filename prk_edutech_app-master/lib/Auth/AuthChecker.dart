import 'package:flutter/material.dart';
import '../Auth/TokenManager.dart';
import '../BottomNavigation/AppScaffold.dart';
import '../Screens/SplashScreen.dart';
import 'LoginScreen.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Show splash screen for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await TokenManager.isLoggedIn();

    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (_isAuthenticated) {
      return const AppScaffold();
    } else {
      return const LoginScreen();
    }
  }
}