import 'package:flutter/material.dart';
import 'dart:ui';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/b.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: const SizedBox.expand(),
            ),
          ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Last updated: September 12, 2026',
                    style: TextStyle(color: Colors.white54),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '1. Information Collection and Use',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The Home Renovation Cost Estimator App ("we", "us", or "our") operates as a standalone application. We do not collect, store, or transmit any personally identifiable information or user data to external servers. All data you enter, such as project details, rates, and estimated costs, is stored locally on your device.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '2. Local Storage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The App utilizes local database storage (SQLite) and local preferences on your device to save your configurations and projects. This data remains on your device and is not shared with us or any third parties.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '3. Third-Party Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The App does not integrate with third-party tracking, analytics, or advertising services that would collect your data.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '4. Changes to This Privacy Policy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '5. Contact Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at the developer email provided on our Google Play Store page.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
