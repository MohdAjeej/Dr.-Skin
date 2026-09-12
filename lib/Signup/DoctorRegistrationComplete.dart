import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';
import 'package:O2ISkinSense/Signup/LoginPage.dart';

/// Comprehensive Multi-Step Doctor Registration
/// For Dermatology-Only Healthcare Application
/// Steps: Basic Info → Professional Info → Practice Info → Account Creation
class DoctorRegistrationComplete extends StatefulWidget {
  @override
  _DoctorRegistrationCompleteState createState() => _DoctorRegistrationCompleteState();
}

class _DoctorRegistrationCompleteState extends State<DoctorRegistrationComplete> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Step 1: Basic Information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  DateTime? _dateOfBirth;
  
  // Step 2: Professional Information
  String _specialization = 'General Dermatology';
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  
  // Step 3: Practice Information
  final TextEditingController _consultationFeeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  
  // Step 4: Account Creation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _qualificationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    _clinicController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1980),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to terms and conditions'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Register doctor account with backend
      await _apiService.registerUser(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobileNo: _mobileController.text.trim(),
        isDoctor: true,
        registrationTermCondition: _agreedToTerms,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doctor account created successfully!'),
          backgroundColor: AppTheme.healthGreen,
        ),
      );
      
      // Navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submitRegistration();
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
  
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateBasicInfo();
      case 1:
        return _validateProfessionalInfo();
      case 2:
        return _validatePracticeInfo();
      case 3:
        return _validateAccountInfo();
      default:
        return false;
    }
  }
  
  bool _validateBasicInfo() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_dateOfBirth == null) {
      _showError('Please select your date of birth');
      return false;
    }
    return true;
  }
  
  bool _validateProfessionalInfo() {
    if (_qualificationController.text.trim().isEmpty) {
      _showError('Please enter your medical qualification');
      return false;
    }
    if (_licenseController.text.trim().isEmpty) {
      _showError('Please enter your medical license number');
      return false;
    }
    if (_experienceController.text.trim().isEmpty) {
      _showError('Please enter years of experience');
      return false;
    }
    final exp = int.tryParse(_experienceController.text);
    if (exp == null || exp < 0) {
      _showError('Please enter a valid experience (years)');
      return false;
    }
    return true;
  }
  
  bool _validatePracticeInfo() {
    if (_consultationFeeController.text.trim().isEmpty) {
      _showError('Please enter consultation fee');
      return false;
    }
    final fee = double.tryParse(_consultationFeeController.text);
    if (fee == null || fee <= 0) {
      _showError('Please enter a valid consultation fee');
      return false;
    }
    if (_bioController.text.trim().isEmpty) {
      _showError('Please enter a professional bio');
      return false;
    }
    return true;
  }
  
  bool _validateAccountInfo() {
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (_mobileController.text.trim().isEmpty) {
      _showError('Please enter your mobile number');
      return false;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(_mobileController.text.trim())) {
      _showError('Please enter a valid 10-digit mobile number');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    return true;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _previousStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Doctor Registration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppTheme.spacing20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepTitle(),
                        SizedBox(height: AppTheme.spacing24),
                        _buildCurrentStepContent(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? AppTheme.primaryColor
                          : AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildStepTitle() {
    final titles = [
      'Basic Information',
      'Professional Credentials',
      'Practice Details',
      'Create Account',
    ];
    
    final subtitles = [
      'Tell us about yourself',
      'Your medical qualifications',
      'Consultation and practice info',
      'Set up your login credentials',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of 4',
          style: AppTheme.captionLarge.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          titles[_currentStep],
          style: AppTheme.headingLarge,
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          subtitles[_currentStep],
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildProfessionalInfoStep();
      case 2:
        return _buildPracticeInfoStep();
      case 3:
        return _buildAccountCreationStep();
      default:
        return Container();
    }
  }
  
  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Dr. John Smith',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _dobController,
          label: 'Date of Birth',
          hint: 'Select your date of birth',
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: _selectDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Date of birth is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildDropdownField(
          label: 'Gender',
          value: _gender,
          icon: Icons.wc,
          items: ['Male', 'Female', 'Other', 'Prefer not to say'],
          onChanged: (value) => setState(() => _gender = value!),
        ),
      ],
    );
  }
  
  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        _buildDropdownField(
          label: 'Dermatology Specialization',
          value: _specialization,
          icon: Icons.medical_services,
          items: AppTheme.dermatologySpecializationNames,
          onChanged: (value) => setState(() => _specialization = value!),
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _qualificationController,
          label: 'Medical Qualification',
          hint: 'MD, MBBS, DNB, etc.',
          icon: Icons.school,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Qualification is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _licenseController,
          label: 'Medical License Number',
          hint: 'Enter your license/registration number',
          icon: Icons.badge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'License number is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _experienceController,
          label: 'Years of Experience',
          hint: 'Enter number of years',
          icon: Icons.work,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Experience is required';
            }
            final exp = int.tryParse(value);
            if (exp == null || exp < 0) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildPracticeInfoStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _consultationFeeController,
          label: 'Consultation Fee (₹)',
          hint: 'Enter consultation charges',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Consultation fee is required';
            }
            final fee = double.tryParse(value);
            if (fee == null || fee <= 0) {
              return 'Enter a valid amount';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _clinicController,
          label: 'Clinic/Hospital Name (Optional)',
          hint: 'Enter your practice location',
          icon: Icons.local_hospital,
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _bioController,
          label: 'Professional Bio',
          hint: 'Tell patients about your expertise and approach',
          icon: Icons.description,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bio is required';
            }
            if (value.trim().length < 50) {
              return 'Bio should be at least 50 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildAccountCreationStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'doctor@example.com',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value.trim())) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number',
          hint: '10-digit mobile number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Mobile number is required';
            }
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
              return 'Enter a valid 10-digit number';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Minimum 6 characters',
          icon: Icons.lock,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing20),
        
        Row(
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
              activeColor: AppTheme.primaryColor,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: Text(
                  'I agree to the Terms and Conditions and Privacy Policy',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppTheme.spacing16,
          horizontal: AppTheme.spacing20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.errorRed),
        ),
      ),
      validator: validator,
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Text(
                  'Back',
                  style: AppTheme.buttonLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
          ],
          Expanded(
            flex: _currentStep > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep < 3 ? 'Next' : 'Create Doctor Account',
                      style: AppTheme.buttonLarge,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
