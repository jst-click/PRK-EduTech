import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF000435),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Privacy Policy',
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
            '1. Information We Collect',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We collect information you provide directly to us, such as your name, email address, phone number, and any other information you choose to provide when you register for an account or communicate with us.',
          ),
          SizedBox(height: 16),
          Text(
            '2. How We Use Your Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We use the information we collect to provide, maintain, and improve our services, communicate with you, and personalize your experience.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Data Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We take reasonable measures to help protect information about you from loss, theft, misuse, unauthorized access, disclosure, alteration, and destruction.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Data Sharing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We do not share your personal information with third parties except as described in this policy or when required by law.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Your Rights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have the right to access, update, and delete your personal information. You can do this by accessing your account settings or contacting us directly.',
          ),
        ],
      ),
    );
  }
}
