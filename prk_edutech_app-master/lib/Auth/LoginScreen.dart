import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

import '../BottomNavigation/AppScaffold.dart';
import '../Auth/TokenManager.dart';
import 'ForgotPasswordScreen.dart';
import 'SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Make API call to login endpoint
        final response = await http.post(
          Uri.parse(buildApiUrl('auth/login')),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Use TokenManager to store user data
          await TokenManager.saveUserData(
            token: responseData['token'],
            userId: responseData['user']['id'],
            userName: responseData['user']['name'],
            userEmail: responseData['user']['email'],
            userType: responseData['user']['userType'],
          );

          if (!mounted) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AppScaffold()));
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'Login failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Connection error. Please check your internet connection.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Rest of your LoginScreen code remains unchanged
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        // Your existing UI code...
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                // App logo
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Login to Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000435),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email ID';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure; // Toggle the password visibility
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen())
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFFFB7F03)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000435),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFFB7F03),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../BottomNavigation/AppScaffold.dart';
// import '../Auth/TokenManager.dart';
// import '../Auth/SocialAuthService.dart'; // Import the new service
// import 'SignupScreen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isObscure = true;
//   String? _errorMessage;
//
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
//
//       try {
//         // Make API call to login endpoint
//         final response = await http.post(
//           Uri.parse('https://server.prkedutech.com/api/auth/login'),
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({
//             'email': _emailController.text.trim(),
//             'password': _passwordController.text,
//           }),
//         );
//
//         final responseData = jsonDecode(response.body);
//
//         if (response.statusCode == 200) {
//           // Use TokenManager to store user data
//           await TokenManager.saveUserData(
//             token: responseData['token'],
//             userId: responseData['user']['id'],
//             userName: responseData['user']['name'],
//             userEmail: responseData['user']['email'],
//             userType: responseData['user']['userType'],
//           );
//
//           if (!mounted) return;
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => const AppScaffold()));
//         } else {
//           setState(() {
//             _errorMessage = responseData['message'] ?? 'Login failed. Please try again.';
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Connection error. Please check your internet connection.';
//         });
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   // Handle social login success
//   void _handleSocialLoginSuccess(bool success) {
//     if (success && mounted) {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AppScaffold())
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF3E0),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 50),
//                 // App logo
//                 Center(
//                   child: Image.asset(
//                     'assets/logo.png',
//                     width: 150,
//                     height: 150,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Login to Your Account',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF000435),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//
//                 // Error message
//                 if (_errorMessage != null)
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.only(bottom: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       _errorMessage!,
//                       style: TextStyle(color: Colors.red.shade800),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: 'Email ID',
//                     prefixIcon: const Icon(Icons.email),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your Email ID';
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _isObscure,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: const Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isObscure ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isObscure = !_isObscure; // Toggle the password visibility
//                         });
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {},
//                     child: const Text(
//                       'Forgot Password?',
//                       style: TextStyle(color: Color(0xFFFB7F03)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF000435),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     disabledBackgroundColor: Colors.grey,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                       : const Text(
//                     'Login',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // OR divider
//                 Row(
//                   children: const [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text("OR", style: TextStyle(color: Colors.grey)),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Google login button
//                 OutlinedButton.icon(
//                   icon: Image.asset(
//                     'assets/google_logo.png', // Add this image to your assets
//                     height: 24,
//                     width: 24,
//                   ),
//                   label: const Text(
//                     'Continue with Google',
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () async {
//                     final success = await SocialAuthService.signInWithGoogle(context);
//                     _handleSocialLoginSuccess(success);
//                   },
//                 ),
//
//                 const SizedBox(height: 15),
//
//                 // Facebook login button
//                 OutlinedButton.icon(
//                   icon: Image.asset(
//                     'assets/facebook_logo.png', // Add this image to your assets
//                     height: 24,
//                     width: 24,
//                   ),
//                   label: const Text(
//                     'Continue with Facebook',
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () async {
//                     final success = await SocialAuthService.signInWithFacebook(context);
//                     _handleSocialLoginSuccess(success);
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const SignupScreen()),
//                         );
//                       },
//                       child: const Text(
//                         'Sign Up',
//                         style: TextStyle(
//                           color: Color(0xFFFB7F03),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }