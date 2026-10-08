import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';
import 'package:O2ISkinSense/Signup/Register.dart';
import 'package:O2ISkinSense/Signup/DoctorRegistrationComplete.dart';

/// Premium Subscription Plan Selection Page
/// Modern SaaS-style UI for selecting plans before registration
class SubscriptionPlansPage extends StatefulWidget {
  final bool isDoctor; // true for doctor registration, false for patient

  const SubscriptionPlansPage({
    Key? key,
    this.isDoctor = false,
  }) : super(key: key);

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage>
    with SingleTickerProviderStateMixin {
  bool _isYearly = false;
  String? _selectedPlanId;
  late AnimationController _animationController;

  // Plan Data Models
  final List<Map<String, dynamic>> _patientPlans = [
    {
      'id': 'patient_basic',
      'name': 'Basic',
      'monthlyPrice': 0,
      'yearlyPrice': 0,
      'subtitle': 'Perfect for getting started',
      'description': 'Essential features for personal skin care',
      'isPopular': false,
      'features': [
        {'text': 'AI Skin Analysis (5 per month)', 'included': true},
        {'text': 'Find Dermatologists', 'included': true},
        {'text': 'Book Appointments', 'included': true},
        {'text': 'Chat with Doctors', 'included': true},
        {'text': 'Basic Diagnosis History', 'included': true},
        {'text': 'Video Consultations', 'included': false},
        {'text': 'Priority Support', 'included': false},
        {'text': 'Advanced Analytics', 'included': false},
      ],
    },
    {
      'id': 'patient_premium',
      'name': 'Premium',
      'monthlyPrice': 499,
      'yearlyPrice': 4990,
      'subtitle': 'Most popular choice',
      'description': 'Everything you need for complete skin health',
      'isPopular': true,
      'features': [
        {'text': 'Unlimited AI Skin Analysis', 'included': true},
        {'text': 'Find Dermatologists', 'included': true},
        {'text': 'Priority Appointment Booking', 'included': true},
        {'text': 'Unlimited Doctor Chat', 'included': true},
        {'text': 'Complete Diagnosis History', 'included': true},
        {'text': '4 Video Consultations/month', 'included': true},
        {'text': 'Priority Support', 'included': true},
        {'text': 'Advanced Skin Analytics', 'included': true},
      ],
    },
    {
      'id': 'patient_pro',
      'name': 'Pro',
      'monthlyPrice': 999,
      'yearlyPrice': 9990,
      'subtitle': 'For comprehensive care',
      'description': 'Ultimate skin health monitoring package',
      'isPopular': false,
      'features': [
        {'text': 'Unlimited AI Skin Analysis', 'included': true},
        {'text': 'Featured Doctor Access', 'included': true},
        {'text': 'Instant Booking (24/7)', 'included': true},
        {'text': 'Unlimited Doctor Chat', 'included': true},
        {'text': 'Lifetime Diagnosis History', 'included': true},
        {'text': 'Unlimited Video Consultations', 'included': true},
        {'text': 'Premium Support (24/7)', 'included': true},
        {'text': 'AI Skin Tracking & Trends', 'included': true},
      ],
    },
  ];

  final List<Map<String, dynamic>> _doctorPlans = [
    {
      'id': 'doctor_starter',
      'name': 'Starter',
      'monthlyPrice': 1999,
      'yearlyPrice': 19990,
      'subtitle': 'Perfect for new practitioners',
      'description': 'Essential tools to start your practice',
      'isPopular': false,
      'features': [
        {'text': 'Professional Profile Listing', 'included': true},
        {'text': 'Accept up to 50 patients/month', 'included': true},
        {'text': 'Appointment Management', 'included': true},
        {'text': 'Patient Chat', 'included': true},
        {'text': 'Video Consultation (50hrs/mo)', 'included': true},
        {'text': 'Digital Prescriptions', 'included': true},
        {'text': 'Basic Analytics', 'included': true},
        {'text': 'Priority Support', 'included': false},
      ],
    },
    {
      'id': 'doctor_professional',
      'name': 'Professional',
      'monthlyPrice': 3999,
      'yearlyPrice': 39990,
      'subtitle': 'Most popular choice',
      'description': 'Advanced features for growing practices',
      'isPopular': true,
      'features': [
        {'text': 'Featured Profile Listing', 'included': true},
        {'text': 'Unlimited Patients', 'included': true},
        {'text': 'Advanced Scheduling', 'included': true},
        {'text': 'Unlimited Patient Chat', 'included': true},
        {'text': 'Unlimited Video Consultations', 'included': true},
        {'text': 'Digital Prescriptions', 'included': true},
        {'text': 'Advanced Analytics Dashboard', 'included': true},
        {'text': 'Priority Support', 'included': true},
      ],
    },
    {
      'id': 'doctor_enterprise',
      'name': 'Enterprise',
      'monthlyPrice': 7999,
      'yearlyPrice': 79990,
      'subtitle': 'For established clinics',
      'description': 'Complete clinic management solution',
      'isPopular': false,
      'features': [
        {'text': 'Premium Featured Profile', 'included': true},
        {'text': 'Unlimited Everything', 'included': true},
        {'text': 'Multi-doctor Support', 'included': true},
        {'text': 'Patient Management CRM', 'included': true},
        {'text': 'White-label Solutions', 'included': true},
        {'text': 'API Access', 'included': true},
        {'text': 'Custom Reports & Analytics', 'included': true},
        {'text': 'Dedicated Account Manager', 'included': true},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentPlans =>
      widget.isDoctor ? _doctorPlans : _patientPlans;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Billing Toggle
            SliverToBoxAdapter(
              child: _buildBillingToggle(),
            ),

            // Plans Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
                vertical: AppTheme.spacing24,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = _currentPlans[index];
                    return _buildPlanCard(plan);
                  },
                  childCount: _currentPlans.length,
                ),
              ),
            ),

            // Trust Badges
            SliverToBoxAdapter(
              child: _buildTrustBadges(),
            ),

            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacing32),
            ),
          ],
        ),
      ),

      // Continue Button (when plan selected)
      floatingActionButton: _selectedPlanId != null
          ? _buildFloatingContinueButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Title
          Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppTheme.spacing12),

          // Subtitle
          Text(
            widget.isDoctor
                ? 'Select the perfect plan for your practice and start connecting with patients'
                : 'Select the perfect plan for your skin health journey',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppTheme.spacing8),

          // Subtext
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'No commitment • Cancel anytime • Secure payment',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing20,
        vertical: AppTheme.spacing24,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Monthly',
              !_isYearly,
              () => setState(() => _isYearly = false),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildToggleOption(
                  'Yearly',
                  _isYearly,
                  () => setState(() => _isYearly = true),
                ),
                Positioned(
                  top: -8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.healthGreen,
                          AppTheme.healthGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.healthGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Save 17%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final bool isSelected = _selectedPlanId == plan['id'];
    final bool isPopular = plan['isPopular'] ?? false;
    final int price =
        _isYearly ? plan['yearlyPrice'] : plan['monthlyPrice'];
    final List<Map<String, dynamic>> features = plan['features'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanId = plan['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppTheme.spacing20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : isPopular
                    ? AppTheme.primaryLight.withOpacity(0.5)
                    : AppTheme.borderLight,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Popular Badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor,
                        AppTheme.secondaryLight,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Most Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Selected Checkmark
            if (isSelected)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryLight,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

            // Card Content
            Padding(
              padding: EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Name
                  Text(
                    plan['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing8),

                  // Subtitle
                  Text(
                    plan['subtitle'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing20),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        price == 0 ? 'Free' : price.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          height: 1.2,
                        ),
                      ),
                      if (price > 0) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _isYearly ? '/year' : '/month',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (_isYearly && price > 0) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      '₹${(price / 12).toStringAsFixed(0)}/month when billed yearly',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.healthGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacing16),

                  // Description
                  Text(
                    plan['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Divider
                  Container(
                    height: 1,
                    color: AppTheme.borderLight,
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Features List
                  ...features.map((feature) => _buildFeatureItem(
                        feature['text'],
                        feature['included'],
                      )),

                  const SizedBox(height: AppTheme.spacing24),

                  // Choose Plan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlanId = plan['id'];
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        isSelected ? 'Selected' : 'Choose Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: included
                  ? AppTheme.healthGreen.withOpacity(0.1)
                  : AppTheme.borderLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: included ? AppTheme.healthGreen : AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: included
                    ? AppTheme.textPrimary
                    : AppTheme.textTertiary,
                height: 1.5,
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing20,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Why Choose Dr. Skin?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Row(
            children: [
              Expanded(
                child: _buildTrustItem(
                  Icons.security_rounded,
                  'Secure & Private',
                  'End-to-end encryption',
                ),
              ),
              Expanded(
                child: _buildTrustItem(
                  Icons.verified_user_rounded,
                  'Verified Doctors',
                  'Licensed professionals',
                ),
              ),
              Expanded(
                child: _buildTrustItem(
                  Icons.cancel_rounded,
                  'Cancel Anytime',
                  'No commitment',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingContinueButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
      child: ElevatedButton(
        onPressed: _continueToRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing18,
          ),
          elevation: 8,
          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Continue to Registration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppTheme.spacing8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _continueToRegistration() {
    if (_selectedPlanId == null) return;

    // Show selected plan confirmation
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConfirmationSheet(),
    );
  }

  Widget _buildConfirmationSheet() {
    final selectedPlan = _currentPlans.firstWhere(
      (plan) => plan['id'] == _selectedPlanId,
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXLarge),
          topRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Check Icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.healthGreen,
                  AppTheme.healthGreen.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Title
          const Text(
            'You\'ve Selected',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: AppTheme.spacing8),

          // Plan Name
          Text(
            '${selectedPlan['name']} Plan',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: AppTheme.spacing8),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${_isYearly ? selectedPlan['yearlyPrice'] : selectedPlan['monthlyPrice']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                _isYearly ? '/year' : '/month',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Info Text
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    'Complete your registration to activate this plan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close sheet
                // Navigate to registration
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.isDoctor
                        ? const DoctorRegistrationComplete()
                        : const Register(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: const Text(
                'Continue to Registration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing12),

          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Change Plan',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
