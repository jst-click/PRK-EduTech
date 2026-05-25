import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri.parse('mailto:$email');
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch $email');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri.parse('tel:$phone');
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phone');
    }
  }

  Widget _buildContactCard({
    required String name,
    required String position,
    String? phone,
    required String email,
    required String website,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              position,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFB7F03),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFFB7F03)),
            const SizedBox(height: 12),
            if (phone != null)
              InkWell(
                onTap: () => _launchPhone(phone),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Color(0xFF000435)),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000435),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            InkWell(
              onTap: () => _launchEmail(email),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Color(0xFF000435)),
                    const SizedBox(width: 8),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF000435),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => _launchURL(website),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Color(0xFF000435)),
                    const SizedBox(width: 8),
                    Text(
                      website,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF000435),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFB7F03),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF000435),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: const Color(0xFFFB7F03),
              child: const Column(
                children: [
                  Text(
                    'PRKEdutech Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get in touch with our team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              name: 'Shivakumar Patil',
              position: 'CEO and Founder | PRKEdutech',
              phone: '9606171055',
              email: 'shivakumar@prkedutech.com',
              website: 'www.prkedutech.com',
            ),
            _buildContactCard(
              name: 'Praveen N',
              position: 'COO | PRKEdutech',
              email: 'coo@prkedutech.com',
              website: 'www.prkedutech.com',
            ),
            _buildContactCard(
              name: 'Arjun',
              position: 'CTO | PRKEdutech',
              email: 'cto@prkedutech.com',
              website: 'www.prkedutech.com',
            ),
            _buildContactCard(
              name: 'Mayur Hegde',
              position: 'CDO | PRKEdutech',
              email: 'support@prkedutech.com',
              website: 'www.prkedutech.com',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}