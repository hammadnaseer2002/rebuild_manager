import 'package:flutter/material.dart';
import 'dart:ui';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Terms and Conditions', style: TextStyle(color: Colors.white)),
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
                    'Terms and Conditions',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Last updated: September 12, 2026',
                    style: TextStyle(color: Colors.white54),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '1. Acceptance of Terms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By downloading or using the App, these terms will automatically apply to you. You should make sure therefore that you read them carefully before using the App.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '2. Use of the App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The Home Renovation Cost Estimator App provides estimates based on user input and standard market rates you configure. The estimates are provided for informational purposes only and do not constitute professional advice or guaranteed quotes.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '3. Accuracy of Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'While we strive to provide a useful tool, we do not warrant the completeness or accuracy of the generated estimates. Actual construction and renovation costs may vary significantly based on location, contractor, material quality, and market fluctuations.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '4. Modifications to the App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We reserve the right to make changes to the App or to charge for its services, at any time and for any reason. We will never charge you for the App or its services without making it very clear to you exactly what you\'re paying for.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '5. Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us.',
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
