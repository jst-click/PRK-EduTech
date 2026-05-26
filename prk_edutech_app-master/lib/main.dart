import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Auth/AuthChecker.dart';
import 'Auth/SecurityWrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SecurityWrapper(
      child: MaterialApp(
        title: 'PRK EduTech',
        theme: ThemeData(
          brightness: Brightness.light, // Ensures default is light mode
          primaryColor: const Color(0xFF000435),
          scaffoldBackgroundColor:
              Colors.white, // Default white background for all pages
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF000435),
            primary: const Color(0xFF000435),
            secondary: const Color(0XFFFB7F03),
            background: Colors.white, // Ensure background color is white
          ),
          fontFamily: 'Inter',
        ),
        home: const AuthChecker(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
