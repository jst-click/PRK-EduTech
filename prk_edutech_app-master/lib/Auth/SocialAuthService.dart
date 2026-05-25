// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:http/http.dart' as http;
//
// import '../Auth/TokenManager.dart';
//
// class SocialAuthService {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email'],
//   );
//
//   // Method to handle Google Sign In
//   static Future<bool> signInWithGoogle(BuildContext context) async {
//     try {
//       // Show loading indicator
//       _showLoadingDialog(context);
//
//       // Start the Google Sign In process
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//       // If user cancelled the sign-in
//       if (googleUser == null) {
//         Navigator.pop(context); // Close loading dialog
//         return false;
//       }
//
//       // Get user details
//       final String name = googleUser.displayName ?? '';
//       final String email = googleUser.email;
//       final String id = googleUser.id;
//
//       // Send to your backend
//       final response = await http.post(
//         Uri.parse('https://server.prkedutech.com/auth/social/token'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'provider': 'google',
//           'providerId': id,
//           'email': email,
//           'name': name,
//         }),
//       );
//
//       // Close loading dialog
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//
//         // Store token and user data
//         await TokenManager.saveUserData(
//           token: responseData['token'],
//           userId: responseData['user']['id'],
//           userName: responseData['user']['name'],
//           userEmail: responseData['user']['email'],
//           userType: responseData['user']['userType'],
//         );
//
//         return true;
//       } else {
//         _showErrorDialog(context, 'Google login failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context); // Close loading dialog
//       }
//       _showErrorDialog(context, 'Error connecting to Google: $e');
//       return false;
//     }
//   }
//
//   // Method to handle Facebook Sign In
//   static Future<bool> signInWithFacebook(BuildContext context) async {
//     try {
//       // Show loading indicator
//       _showLoadingDialog(context);
//
//       // Start the Facebook Login process
//       final LoginResult result = await FacebookAuth.instance.login(
//         permissions: ['email', 'public_profile'],
//       );
//
//       // If user cancelled the login
//       if (result.status != LoginStatus.success) {
//         Navigator.pop(context); // Close loading dialog
//         return false;
//       }
//
//       // Get user data
//       final userData = await FacebookAuth.instance.getUserData();
//
//       // Check if email is available
//       if (userData['email'] == null) {
//         Navigator.pop(context); // Close loading dialog
//         _showErrorDialog(context, 'Email permission is required for Facebook login.');
//         await FacebookAuth.instance.logOut();
//         return false;
//       }
//
//       // Send to your backend
//       final response = await http.post(
//         Uri.parse('https://server.prkedutech.com/auth/social/token'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'provider': 'facebook',
//           'providerId': userData['id'],
//           'email': userData['email'],
//           'name': userData['name'],
//         }),
//       );
//
//       // Close loading dialog
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//
//         // Store token and user data
//         await TokenManager.saveUserData(
//           token: responseData['token'],
//           userId: responseData['user']['id'],
//           userName: responseData['user']['name'],
//           userEmail: responseData['user']['email'],
//           userType: responseData['user']['userType'],
//         );
//
//         return true;
//       } else {
//         _showErrorDialog(context, 'Facebook login failed. Please try again.');
//         return false;
//       }
//     } catch (e) {
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context); // Close loading dialog
//       }
//       _showErrorDialog(context, 'Error connecting to Facebook: $e');
//       return false;
//     }
//   }
//
//   // Alternative method using browser redirect flow (more secure)
//   static Future<bool> signInWithGoogleWebAuth(BuildContext context) async {
//     try {
//       _showLoadingDialog(context);
//
//       // Launch the authentication URL in a browser
//       final result = await FlutterWebAuth.authenticate(
//           url: 'https://server.prkedutech.com/auth/google',
//           callbackUrlScheme: 'prkedutech'
//       );
//
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context); // Close loading dialog
//       }
//
//       // Parse the result URL (contains token and user info)
//       final uri = Uri.parse(result);
//       final params = uri.queryParameters;
//
//       if (params.containsKey('error')) {
//         _showErrorDialog(context, 'Authentication failed. Please try again.');
//         return false;
//       }
//
//       // Save user data
//       await TokenManager.saveUserData(
//         token: params['token'] ?? '',
//         userId: params['userId'] ?? '',
//         userName: params['name'] ?? '',
//         userEmail: params['email'] ?? '',
//         userType: params['userType'] ?? 'free',
//       );
//
//       return true;
//     } catch (e) {
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context); // Close loading dialog
//       }
//       _showErrorDialog(context, 'Authentication canceled or failed.');
//       return false;
//     }
//   }
//
//   // Show loading dialog helper
//   static void _showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(width: 20),
//                 Text("Logging in...")
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Show error dialog helper
//   static void _showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Login Error"),
//           content: Text(message),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }