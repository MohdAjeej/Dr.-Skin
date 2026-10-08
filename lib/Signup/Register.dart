import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';

import 'package:O2ISkinSense/Signup/DoctorRegistrationComplete.dart';
import 'package:O2ISkinSense/Signup/LoginPage.dart';

class Register extends StatefulWidget {
  final String? selectedPlan;
  final String? selectedPlanId;
  final double? planPrice;
  final String? billingPeriod;
  final bool showPlansAfterLogin;

  const Register({
    Key? key,
    this.selectedPlan,
    this.selectedPlanId,
    this.planPrice,
    this.billingPeriod,
    this.showPlansAfterLogin = false,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

// Keep backward compatibility
class RegisterPage extends Register {
  RegisterPage({Key? key, bool showPlansAfterLogin = false})
      : super(key: key, showPlansAfterLogin: showPlansAfterLogin);
}

class _RegisterPageState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _email = '';
  String _password = '';
  String _mobileNo = '';
  bool _registrationTermCondition = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService(); // Instance of ApiService

  // Function to handle registration
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form values
      setState(() {
        _isLoading = true;
      });
      try {
        await _apiService.registerUser(
          userName: _userName.trim(),
          email: _email.trim(),
          password: _password.trim(),
          mobileNo: _mobileNo.trim(),
          isDoctor: false,
          registrationTermCondition: _registrationTermCondition,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text("Registration Successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              subscriptionPlanId: widget.selectedPlanId,
              subscriptionBillingPeriod: widget.billingPeriod,
              showPlansAfterLogin: widget.showPlansAfterLogin,
            ),
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Show selected plan if available
                if (widget.selectedPlan != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6B73FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.selectedPlan} Plan Selected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹${widget.planPrice?.toStringAsFixed(0)} / ${widget.billingPeriod}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Center(
                  child: Lottie.asset(
                    'assets/anima.json', // Path to your Lottie file
                    height: 200,
                    width: 200,
                  ),
                ),
                // Username Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter your username",
                    prefixIcon: Icon(Icons.person), // Adds a user icon
                    filled: true,
                    fillColor: Colors.grey.shade100, // Light grey background
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // Removes the border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username cannot be empty";
                    } else if (value.length < 3) {
                      return "Username must be at least 3 characters long";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userName = value!;
                  },
                ),
                SizedBox(height: 16),

                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email address",
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                SizedBox(height: 16),

                // Password Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 16),

                // Mobile Number Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    hintText: "Enter your mobile number",
                    prefixIcon: Icon(Icons.phone),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your mobile number";
                    } else if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
                      return "Please enter a valid 10-digit mobile number";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _mobileNo = value!;
                  },
                ),
                SizedBox(height: 16),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _registrationTermCondition,
                      onChanged: (value) {
                        setState(() {
                          _registrationTermCondition = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "I agree to the terms and conditions",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Register Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Responsive width
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _registerUser, // Disable button while loading
                      child: Padding(
                        padding: const EdgeInsets.all(
                            15.0), // Adjust padding for a better tap area
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Register",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 122, 196, 125), // Green color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        elevation: 5, // Subtle shadow for a raised effect
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            showPlansAfterLogin: widget.showPlansAfterLogin,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorRegistrationComplete(), // New comprehensive registration
                        ),
                      );
                    },
                    child: Text(
                      "Register as Doctor",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
