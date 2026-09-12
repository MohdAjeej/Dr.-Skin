import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';

/// Editable Profile Page for both Patient and Doctor
/// Role-aware editing based on user role
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  String _userRole = 'ROLE_NORMAL';
  Map<String, dynamic>? _profileData;

  // Patient fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  String _gender = 'Male';
  DateTime? _dateOfBirth;

  // Doctor fields
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _doctorNameController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('roles') ?? 'ROLE_NORMAL';

      if (_userRole == 'ROLE_DOCTOR') {
        await _loadDoctorProfile();
      } else {
        await _loadPatientProfile();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPatientProfile() async {
    final data = await ApiService().getPatientProfile();
    setState(() {
      _profileData = data;
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _gender = data['gender'] ?? 'Male';
      _dobController.text = data['dateOfBirth'] ?? '';
      _weightController.text = data['weight']?.toString() ?? '';
      _heightFtController.text = data['heightFt']?.toString() ?? '';
      _heightInController.text = data['heightIn']?.toString() ?? '';
    });
  }

  Future<void> _loadDoctorProfile() async {
    final data = await ApiService().getDoctorProfileData();
    setState(() {
      _profileData = data;
      _doctorNameController.text = data['name'] ?? '';
      _specializationController.text = data['specialization'] ?? '';
      _qualificationController.text = data['qualification'] ?? '';
      _experienceController.text = data['experienceInYears']?.toString() ?? '';
      _bioController.text = data['bio'] ?? '';
      _consultationFeeController.text = data['consultationFee']?.toString() ?? '';
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');

      if (_userRole == 'ROLE_DOCTOR') {
        await _saveDoctorProfile(token!);
      } else {
        await _savePatientProfile(token!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.healthGreen,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate profile was updated
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _savePatientProfile(String token) async {
    final requestBody = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'gender': _gender,
      'dateOfBirth': _dobController.text.trim(),
      'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
      'heightFt': int.tryParse(_heightFtController.text.trim()) ?? 0,
      'heightIn': int.tryParse(_heightInController.text.trim()) ?? 0,
    };

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/api/profile/updateProfile'),
      headers: {
        'Auth': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<void> _saveDoctorProfile(String token) async {
    final requestBody = {
      'name': _doctorNameController.text.trim(),
      'specialization': _specializationController.text.trim(),
      'qualification': _qualificationController.text.trim(),
      'experienceInYears': int.tryParse(_experienceController.text.trim()) ?? 0,
      'bio': _bioController.text.trim(),
      'consultationFee': double.tryParse(_consultationFeeController.text.trim()) ?? 0.0,
    };

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/api/doctors/update-profile'),
      headers: {
        'Auth': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacing20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userRole == 'ROLE_DOCTOR')
                      _buildDoctorForm()
                    else
                      _buildPatientForm(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPatientForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'First name is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last name is required';
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
        SizedBox(height: AppTheme.spacing16),
        _buildTextField(
          controller: _dobController,
          label: 'Date of Birth',
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
        _buildTextField(
          controller: _weightController,
          label: 'Weight (kg)',
          icon: Icons.monitor_weight,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Weight is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightFtController,
                label: 'Height (ft)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildTextField(
                controller: _heightInController,
                label: 'Height (in)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _doctorNameController,
          label: 'Full Name',
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
          controller: _specializationController,
          label: 'Specialization',
          icon: Icons.medical_services,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Specialization is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildTextField(
          controller: _qualificationController,
          label: 'Qualification',
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
          controller: _experienceController,
          label: 'Experience (Years)',
          icon: Icons.work,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Experience is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildTextField(
          controller: _consultationFeeController,
          label: 'Consultation Fee (₹)',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Fee is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildTextField(
          controller: _bioController,
          label: 'Professional Bio',
          icon: Icons.description,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bio is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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
                    child: Text(item),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
