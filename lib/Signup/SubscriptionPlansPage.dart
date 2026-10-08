import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Signup/Register.dart';
import 'package:O2ISkinSense/Signup/LoginPage.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/BottomPages/BottomNav.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPlansPage extends StatefulWidget {
  final String? initialPlanId;
  final String? initialBillingPeriod;
  final bool checkoutAfterLogin;

  const SubscriptionPlansPage({
    Key? key,
    this.initialPlanId,
    this.initialBillingPeriod,
    this.checkoutAfterLogin = false,
  }) : super(key: key);

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  int? _selectedPlanIndex;
  bool _isYearly = false;
  bool _isLoadingPlans = true;
  bool _isProcessingPayment = false;
  String? _plansError;
  List<Map<String, dynamic>> _plans = [];
  late final Razorpay _razorpay;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _isYearly = widget.initialBillingPeriod?.toLowerCase() == 'yearly';
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoadingPlans = true;
      _plansError = null;
    });
    try {
      final plans = await _apiService.getSubscriptionPlans();
      if (!mounted) return;
      final selectedIndex = plans.indexWhere(
        (plan) => plan['id'] == widget.initialPlanId,
      );
      setState(() {
        _plans = plans;
        _selectedPlanIndex = selectedIndex >= 0 ? selectedIndex : null;
        _isLoadingPlans = false;
      });

      if (widget.checkoutAfterLogin && selectedIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startSubscriptionCheckout();
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _plansError = error.toString();
        _isLoadingPlans = false;
      });
    }
  }

  Future<void> _continueWithSelectedPlan() async {
    final plan = _plans[_selectedPlanIndex!];
    final planId = plan['id']?.toString() ?? '';
    if (planId.isEmpty) {
      _showMessage('This plan is missing its identifier. Please try again.');
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    final token = preferences.getString('jwtToken');
    if (token != null && token.trim().isNotEmpty) {
      if (planId == 'free') {
        _goToHome();
      } else {
        await _startSubscriptionCheckout();
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Register(
          selectedPlan: plan['name']?.toString(),
          selectedPlanId: planId == 'free' ? null : planId,
          planPrice: _getPlanPrice(_selectedPlanIndex!).toDouble(),
          billingPeriod: _isYearly ? 'yearly' : 'monthly',
        ),
      ),
    );
  }

  Future<void> _startSubscriptionCheckout() async {
    if (_isProcessingPayment || _selectedPlanIndex == null) return;
    final plan = _plans[_selectedPlanIndex!];
    final planId = plan['id']?.toString();
    if (planId == null || planId == 'free') {
      _showMessage('The Free plan does not require a payment.');
      return;
    }

    setState(() => _isProcessingPayment = true);
    try {
      final order = await _apiService.createSubscriptionOrder(
        planId: planId,
        billingPeriod: _isYearly ? 'yearly' : 'monthly',
      );
      final keyId = order['keyId']?.toString();
      final orderId = order['orderId']?.toString();
      final amount = order['amount'];
      final currency = order['currency']?.toString();
      if (keyId == null ||
          orderId == null ||
          amount is! num ||
          currency == null) {
        throw Exception('The server returned incomplete payment details.');
      }

      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      _razorpay.open({
        'key': keyId,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'name': 'Dr. Skin',
        'description':
            '${plan['name']} ${_isYearly ? 'yearly' : 'monthly'} plan',
        'prefill': {
          'name': preferences.getString('username') ?? '',
          'email': preferences.getString('email') ?? '',
        },
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showMessage('Unable to start payment: $error');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId;
    final orderId = response.orderId;
    final signature = response.signature;
    if (paymentId == null || orderId == null || signature == null) {
      if (mounted) setState(() => _isProcessingPayment = false);
      _showMessage('Payment details were incomplete. Please contact support.');
      return;
    }

    setState(() => _isProcessingPayment = true);
    try {
      final status = await _apiService.verifySubscriptionPayment(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showMessage(
        '${status['planName'] ?? 'Subscription'} activated successfully.',
      );
      _goToHome();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showMessage(
        'Payment was received, but subscription verification failed. '
        'Please contact support with payment ID $paymentId. ($error)',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _isProcessingPayment = false);
    _showMessage(response.message ?? 'Payment was not completed.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage(
        'External wallet selected: ${response.walletName ?? 'wallet'}');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MyHomePage()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double _getPlanPrice(int index) {
    return _isYearly
        ? _plans[index]['yearlyPrice'].toDouble()
        : _plans[index]['monthlyPrice'].toDouble();
  }

  String _getSavingsText(int index) {
    if (!_isYearly || _plans[index]['monthlyPrice'] == 0) return '';
    final monthlyTotal = _plans[index]['monthlyPrice'] * 12;
    final yearlyPrice = _plans[index]['yearlyPrice'];
    final savings = monthlyTotal - yearlyPrice;
    final percentage = ((savings / monthlyTotal) * 100).round();
    return 'Save ₹$savings ($percentage%)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scrollable content
            Expanded(
              child: _isLoadingPlans
                  ? const Center(child: CircularProgressIndicator())
                  : _plansError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Unable to load subscription plans.\n$_plansError',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadPlans,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Billing toggle
                              _buildBillingToggle(),

                              const SizedBox(height: 32),

                              // Plans
                              _buildPlansSection(),

                              const SizedBox(height: 32),

                              // Trust badges
                              _buildTrustBadges(),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
            ),

            // Bottom CTA
            if (!_isLoadingPlans &&
                _plansError == null &&
                _selectedPlanIndex != null)
              _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              // Skip to Login
              TextButton(
                onPressed: () {
                  final hasPaidPlan = _selectedPlanIndex != null &&
                      _plans[_selectedPlanIndex!]['id'] != 'free';
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        subscriptionPlanId: hasPaidPlan
                            ? _plans[_selectedPlanIndex!]['id']?.toString()
                            : null,
                        subscriptionBillingPeriod: hasPaidPlan
                            ? (_isYearly ? 'yearly' : 'monthly')
                            : null,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Already have account? Login',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the perfect plan for your skin health journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption('Monthly', !_isYearly, () {
              setState(() => _isYearly = false);
            }),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildToggleOption('Yearly', _isYearly, () {
                  setState(() => _isYearly = true);
                }),
                Positioned(
                  top: -8,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Save 16%',
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.shade300,
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
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? primaryColor : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlansSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_plans.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(index),
          );
        }),
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;
    final isPopular = plan['isPopular'] == true || plan['popular'] == true;
    final price = _getPlanPrice(index);
    final savingsText = _getSavingsText(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : isPopular
                    ? primaryColor.withOpacity(0.3)
                    : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name and popular badge
                  Row(
                    children: [
                      Text(
                        plan['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    plan['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        price == 0 ? '0' : price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _isYearly ? '/year' : '/month',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (savingsText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        savingsText,
                        style: TextStyle(
                          color: successColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Features
                  ...List.generate(
                    plan['features'].length,
                    (featureIndex) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: successColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: successColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              plan['features'][featureIndex],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? primaryColor : Colors.transparent,
                        foregroundColor:
                            isSelected ? Colors.white : primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: primaryColor,
                            width: isSelected ? 0 : 2,
                          ),
                        ),
                        elevation: isSelected ? 4 : 0,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: Text(
                        isSelected ? 'Selected' : 'Choose Plan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustBadge(
                Icons.lock_outline,
                'Secure\nPayment',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              _buildTrustBadge(
                Icons.cancel_outlined,
                'No Auto-\nRenewal',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              _buildTrustBadge(
                Icons.star_outline,
                '100%\nTransparent',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'One-time payment • No automatic renewal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_plans[_selectedPlanIndex!]['name']} Plan Selected',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '₹${_getPlanPrice(_selectedPlanIndex!).toStringAsFixed(0)} ${_isYearly ? '/year' : '/month'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isProcessingPayment ? null : _continueWithSelectedPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isProcessingPayment
                          ? 'Preparing payment...'
                          : _plans[_selectedPlanIndex!]['id'] == 'free'
                              ? 'Continue with Free Plan'
                              : 'Continue to Secure Payment',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
