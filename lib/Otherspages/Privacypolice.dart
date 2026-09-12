import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Introduction',
                "Welcome to O2I SkinSense. We are committed to protecting your privacy and ensuring the security of your personal data."),
            _buildSection('Information We Collect',
                "- Personal Information: Name, email, phone number (if voluntarily provided).\n- Health Data: Skin images and related health data uploaded for analysis.\n- Device Information: IP address, device type, operating system, and usage data.\n- Cookies & Tracking: We may use cookies and similar technologies to enhance user experience."),
            _buildSection('How We Use Your Information',
                "- To analyze and provide AI-generated skin diagnosis results.\n- To improve our AI model and enhance app performance.\n- To communicate with you regarding updates, support, and promotions.\n- To comply with legal obligations and security measures."),
            _buildSection('Data Sharing and Disclosure',
                "We do not sell your personal data. However, we may share your information in the following cases:\n- With Medical Professionals: If you opt for expert review.\n- With Service Providers: Third-party cloud storage, analytics, and AI processing partners.\n- Legal Requirements: If required by law or to protect rights and security."),
            _buildSection('Data Security',
                "We implement strict security measures, including encryption and access controls, to safeguard your data against unauthorized access, loss, or misuse."),
            _buildSection('Data Retention',
                "We retain your data only as long as necessary for the purposes stated. You can request deletion of your data by contacting us at [Contact Email]."),
            _buildSection('Your Rights',
                "Depending on your location, you may have the right to:\n- Access, correct, or delete your data.\n- Withdraw consent for data processing.\n- Opt out of marketing communications."),
            _buildSection('Childrens Privacy',
                "Our app is not intended for children under 13. We do not knowingly collect data from minors without parental consent."),
            _buildSection('Changes to This Policy',
                "We may update this Privacy Policy from time to time. We encourage you to review it periodically for any changes."),
            _buildSection('Contact Us',
                "If you have any questions or concerns about this Privacy Policy, please contact us at:\n O2i\n[Your Contact Email]\n[Your Address]"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
