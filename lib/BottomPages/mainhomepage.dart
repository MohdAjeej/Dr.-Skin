import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';
import 'package:O2ISkinSense/Otherspages/cropimage.dart';
import 'package:O2ISkinSense/Otherspages/DiagnoseAnimationPage.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:O2ISkinSense/Otherspages/Completeprofile.dart';
import 'package:O2ISkinSense/Otherspages/DoctorProfileCompete.dart';
import 'package:O2ISkinSense/Patient/DermatologyDoctorSearch.dart';
import 'package:O2ISkinSense/Patient/PatientAppointments.dart';

/// Professional Dermatology-Focused Patient Home Page
/// 100% Dermatology Content - No Other Medical Specialties
class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  XFile? _image;
  bool _isProcessing = false;
  String _userName = "";
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _initializeHomePage();
  }

  Future<void> _initializeHomePage() async {
    await _loadUserInfo();
    await _checkProfileStatus();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString("username");
      if (mounted) {
        setState(() {
          _userName = username ?? "User";
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _checkProfileStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");
      final userRole = prefs.getString("roles");

      if (token == null) return;

      final apiService = ApiService();

      // Check if doctor role
      if (userRole == "ROLE_DOCTOR") {
        final isDoctorProfileComplete = await apiService.getDoctorProfile(token);
        if (!isDoctorProfileComplete && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorProfilePage()),
          );
          return;
        }
      }

      // Check patient profile
      final isPatientProfileComplete = await apiService.getUserProfile(token);
      if (!isPatientProfileComplete && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateProfilePage()),
        );
      }
    } catch (e) {
      debugPrint('Profile check error: $e');
    }
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedImage != null && mounted) {
        final croppedFile = await Navigator.push<File>(
          context,
          MaterialPageRoute(
            builder: (context) => CropImagePage(image: File(pickedImage.path)),
          ),
        );

        if (croppedFile != null && mounted) {
          setState(() => _image = XFile(croppedFile.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _startDiagnosis() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a skin photo first'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosePage(image: File(_image!.path)),
      ),
    );
  }

  String _getGreeting() {
    final hour = int.parse(DateFormat('kk').format(DateTime.now()));
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour <= 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: _isLoadingProfile
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfessionalHeader(),
                      _buildDermatologyHeroSection(),
                      _buildSkinConcernsSection(),
                      _buildAIDiagnosisSection(),
                      _buildQuickActionsSection(),
                      const SizedBox(height: AppTheme.spacing32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Professional Medical Header with Greeting
  Widget _buildProfessionalHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: AppTheme.shadowSoft,
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          
          // Greeting and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}, $_userName',
                  style: AppTheme.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Your skin health, simplified',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Notification Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.textPrimary,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Section - Dermatology Focus
  Widget _buildDermatologyHeroSection() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing20),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.shadowPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppTheme.textWhite,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Skin Health Matters',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Consult qualified dermatologists',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          
          // Find Dermatologist Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DermatologyDoctorSearch(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textWhite,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Find a Dermatologist',
                    style: AppTheme.buttonMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dermatology Services - Skin Concerns
  Widget _buildSkinConcernsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
          ),
          child: Text(
            'Common Skin Concerns',
            style: AppTheme.headingMedium,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing20,
            ),
            itemCount: AppTheme.skinConcerns.length,
            itemBuilder: (context, index) {
              final concern = AppTheme.skinConcerns[index];
              return _buildSkinConcernCard(
                concern['name'] as String,
                concern['icon'] as String,
                concern['color'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkinConcernCard(String name, String icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            name,
            style: AppTheme.captionLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// AI Skin Diagnosis Section
  Widget _buildAIDiagnosisSection() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing20),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Skin Diagnosis',
                      style: AppTheme.titleLarge,
                    ),
                    Text(
                      'Instant skin analysis',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Image Preview or Placeholder
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Image.file(
                File(_image!.path),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Take or upload a photo',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickAndCropImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickAndCropImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (_image != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startDiagnosis,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textWhite,
                          ),
                        ),
                      )
                    : const Icon(Icons.analytics, size: 18),
                label: Text(_isProcessing ? 'Processing...' : 'Analyze Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
          ),
          child: Text(
            'Quick Actions',
            style: AppTheme.headingMedium,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
          ),
          child: Column(
            children: [
              _buildQuickActionCard(
                icon: Icons.calendar_today,
                title: 'My Appointments',
                subtitle: 'View and manage appointments',
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientAppointments(),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              _buildQuickActionCard(
                icon: Icons.history,
                title: 'Medical History',
                subtitle: 'View past diagnoses and records',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                onTap: () {
                  // Navigate to medical history
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowSoft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: AppTheme.textWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
