
// Additional Screens
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: const Color(0xFF000435),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Terms and Conditions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000435),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Last Updated: March 06, 2025',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '1. Introduction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Welcome to PRK EduTech. These Terms and Conditions govern your use of our mobile application and services. By using our app, you agree to these terms.',
          ),
          SizedBox(height: 16),
          Text(
            '2. Account Registration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you create an account with us, you must provide accurate and complete information. You are responsible for the security of your account and password.',
          ),
          SizedBox(height: 16),
          Text(
            '3. User Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Any content you submit to the platform must be appropriate and not violate any third-party rights. We reserve the right to remove any content that violates our policies.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Intellectual Property',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'All content on the platform, including but not limited to text, graphics, logos, and software, is the property of PRK EduTech and is protected by copyright and other intellectual property laws.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Limitation of Liability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'PRK EduTech shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
          ),
        ],
      ),
    );
  }
}