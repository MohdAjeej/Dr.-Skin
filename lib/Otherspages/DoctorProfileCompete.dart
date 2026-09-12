import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:O2ISkinSense/BottomPages/BottomNav.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _image;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _specialController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _hospitalStreetController =
      TextEditingController();
  final TextEditingController _hospitalCityController = TextEditingController();
  final TextEditingController _hospitalStateController =
      TextEditingController();
  final TextEditingController _hospitalZipController = TextEditingController();
  final TextEditingController _hospitalPhoneController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _onlineChargesController =
      TextEditingController();
  final TextEditingController _ratingsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // Time and day selection state
  TimeOfDay? _availabilityStartTime;
  TimeOfDay? _availabilityEndTime;
  TimeOfDay? _onlineConsultationStartTime;
  TimeOfDay? _onlineConsultationEndTime;
  final List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> _selectedAvailabilityDays = [];
  List<String> _selectedOnlineConsultationDays = [];

  // Predefined specializations
  final List<String> _specializations = [
    'Acne and Rosacea',
    'Actinic Keratosis Basal Cell Carcinoma and other Malignant Lesions',
    'Atopic Dermatitis',
    'Bullous Disease',
    'Eczema',
    'Exanthems and Drug Eruptions',
    'Hair Loss Photos Alopecia and other Hair Diseases',
    'Light Diseases and Disorders of Pigmentation',
    'Lupus and other Connective Tissue diseases',
    'Melanoma Skin Cancer Nevi and Moles',
    'Nail Fungus and other Nail Disease',
    'Psoriasis pictures Lichen Planus and related diseases',
    'Scabies Lyme Disease and other Infestations and Bites',
    'Seborrheic Keratoses and other Benign Tumors',
    'Systemic Disease',
    'Tinea Ringworm Candidiasis and other Fungal Infections',
    'Urticaria Hives',
    'Vascular Tumors',
    'Vasculitis',
    'Warts Molluscum and other Viral Infections',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _specialController.dispose();
    _hospitalNameController.dispose();
    _hospitalStreetController.dispose();
    _hospitalCityController.dispose();
    _hospitalStateController.dispose();
    _hospitalZipController.dispose();
    _hospitalPhoneController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _onlineChargesController.dispose();
    _ratingsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _selectTime(
      BuildContext context, bool isStartTime, bool isAvailability) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isAvailability) {
          if (isStartTime)
            _availabilityStartTime = picked;
          else
            _availabilityEndTime = picked;
        } else {
          if (isStartTime)
            _onlineConsultationStartTime = picked;
          else
            _onlineConsultationEndTime = picked;
        }
      });
    }
  }

  Widget _buildDayCheckboxes(List<String> selectedDays, Function onChanged) {
    return Wrap(
      spacing: 8,
      children: _allDays
          .map((day) => FilterChip(
                selected: selectedDays.contains(day),
                label: Text(day),
                onSelected: (selected) => setState(() {
                  selected ? selectedDays.add(day) : selectedDays.remove(day);
                  onChanged(selectedDays);
                }),
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue.shade900,
              ))
          .toList(),
    );
  }

  Widget _buildTimeSelector(TimeOfDay? time, String label, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: Colors.blue.shade900),
            SizedBox(width: 8),
            Text(
              time != null
                  ? DateFormat.jm()
                      .format(DateTime(2023, 1, 1, time.hour, time.minute))
                  : label,
              style:
                  TextStyle(color: time != null ? Colors.black : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("jwtToken");

        // Prepare the request body for the profile data
        final Map<String, dynamic> requestBody = {
          "name": _nameController.text,
          "specialization": _specializationController.text,
          "special":
              _specialController.text.split(',').map((e) => e.trim()).toList(),
          "hospital": {
            "name": _hospitalNameController.text,
            "address": {
              "street": _hospitalStreetController.text,
              "city": _hospitalCityController.text,
              "state": _hospitalStateController.text,
              "zip": _hospitalZipController.text,
            },
            "phone": _hospitalPhoneController.text,
          },
          "email":
              _usernameController.text, // Changed from "username" to "email"
          "phone": _phoneController.text,
          "availability": {
            "days": _selectedAvailabilityDays,
            "time":
                "${_formatTime(_availabilityStartTime)} - ${_formatTime(_availabilityEndTime)}",
          },
          "onlineConsultation": {
            "charges": double.parse(_onlineChargesController.text),
            "startTime": _formatTime(_onlineConsultationStartTime),
            "endTime": _formatTime(_onlineConsultationEndTime),
            "days": _selectedOnlineConsultationDays,
          },
          "ratings": double.parse(_ratingsController.text),
          "experience": int.parse(_experienceController.text),
        };

        // Print the request body for debugging
        print("Request Body: ${json.encode(requestBody)}");

        // Submit the profile data
        final profileResponse = await http.post(
          Uri.parse('${ApiService.baseUrl}/api/doctors/save-doctor-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Auth': 'Bearer $token',
          },
          body: json.encode(requestBody),
        );

        // Check the profile submission response
        if (profileResponse.statusCode == 200 ||
            profileResponse.statusCode == 201) {
          print("dfdhfdhfjhgfj 1 ${profileResponse.body} ---- ");
          final responseData = json.decode(profileResponse.body);
          final doctorId =
              responseData['id']; // Assuming the API returns the doctor ID

          // Upload the image if selected
          if (_image != null) {
            final imageUploadResponse = await _uploadImage(doctorId, token!);
            if (imageUploadResponse.statusCode == 200 ||
                imageUploadResponse.statusCode == 201) {
              print("dfdhfdhfjhgfj 5 $doctorId ---- $token");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Profile and image uploaded successfully!"),
                ),
              );
            } else {
              print("dfdhfdhfjhgfj 6 $doctorId ---- $token");
              throw Exception("Failed to upload image: ${imageUploadResponse}");
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("Profile created successfully!"),
              ),
            );
          }

          // Navigate to the home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MyHomePage()),
          );
        } else {
          print("dfdhfdhfjhgfj 2 ${profileResponse.body} ---- ");

          throw Exception("Failed to create profile: ${profileResponse.body}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<http.StreamedResponse> _uploadImage(int doctorId, String token) async {
    print("dfdhfdhfjhgfj 3 $doctorId ---- $token");
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${ApiService.baseUrl}/api/doctors/upload-doctor-image/$doctorId'),
    )
      ..headers['Auth'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'image', // Field name for the image
        _image!.path, // Path to the image file
      ));

    // Print the request for debugging
    print("Image Upload Request: ${request.files}");

    // Send the request
    final response = await request.send();
    return response;
  }

  String _formatTime(TimeOfDay? time) => time != null
      ? DateFormat('HH:mm').format(DateTime(2023, 1, 1, time.hour, time.minute))
      : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Doctor Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(fromCamera: false),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _pickImage(fromCamera: true),
                      child: Text("Take a photo"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Name", Icons.person),
              _buildTextField(_specializationController, "Specialization",
                  Icons.medical_services),
              _buildSpecializationField(),
              _buildTextField(_hospitalNameController, "Hospital Name",
                  Icons.local_hospital),
              _buildTextField(_hospitalStreetController, "Hospital Street",
                  Icons.location_on),
              _buildTextField(_hospitalCityController, "Hospital City",
                  Icons.location_city),
              _buildTextField(
                  _hospitalStateController, "Hospital State", Icons.map),
              _buildTextField(
                  _hospitalZipController, "Hospital Zip", Icons.pin_drop),
              _buildTextField(
                  _hospitalPhoneController, "Hospital Phone", Icons.phone),
              _buildTextField(
                  _usernameController, "Email (Username)", Icons.email),
              _buildTextField(_phoneController, "Phone Number", Icons.phone),

              // Availability Section
              _buildSectionTitle("Availability Days"),
              _buildDayCheckboxes(_selectedAvailabilityDays, (days) {}),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTimeSelection(
                          "Start Time",
                          _availabilityStartTime,
                          () => _selectTime(context, true, true))),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTimeSelection(
                          "End Time",
                          _availabilityEndTime,
                          () => _selectTime(context, false, true))),
                ],
              ),
              SizedBox(height: 24),

              // Online Consultation Section
              _buildSectionTitle("Online Consultation Days"),
              _buildDayCheckboxes(_selectedOnlineConsultationDays, (days) {}),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTimeSelection(
                          "Start Time",
                          _onlineConsultationStartTime,
                          () => _selectTime(context, true, false))),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTimeSelection(
                          "End Time",
                          _onlineConsultationEndTime,
                          () => _selectTime(context, false, false))),
                ],
              ),
              _buildTextField(_onlineChargesController, "Consultation Charges",
                  Icons.attach_money,
                  keyboardType: TextInputType.number),
              _buildTextField(_ratingsController, "Ratings", Icons.star,
                  keyboardType: TextInputType.number),
              _buildTextField(
                  _experienceController, "Experience (Years)", Icons.work,
                  keyboardType: TextInputType.number),

              // Submit Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Submit Profile",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        validator: (value) => value!.isEmpty ? "This field is required" : null,
      ),
    );
  }

  Widget _buildSpecializationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return _specializations.where((String option) {
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _addSpecialization(selection);
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "Specializations",
                  prefixIcon: Icon(Icons.list),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  // suffixIcon: IconButton(
                  //   icon: Icon(Icons.add),
                  //   onPressed: () {
                  //     _addSpecialization(textEditingController.text);
                  //     textEditingController.clear(); // Clear the text field
                  //   },
                  // ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "This field is required" : null,
              );
            },
          ),
          SizedBox(height: 8),
          // Display added specializations as chips
          Wrap(
            spacing: 8,
            children: _specialController.text
                .split(',')
                .where((specialization) => specialization.trim().isNotEmpty)
                .map((specialization) {
              return Chip(
                label: Text(specialization.trim()),
                deleteIcon: Icon(Icons.delete, size: 18),
                onDeleted: () {
                  setState(() {
                    _specialController.text = _specialController.text
                        .split(',')
                        .where((item) => item.trim() != specialization.trim())
                        .join(',');
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addSpecialization(String specialization) {
    if (_specializations.contains(specialization) &&
        !_specialController.text.split(',').contains(specialization)) {
      setState(() {
        if (_specialController.text.isEmpty) {
          _specialController.text = specialization;
        } else {
          _specialController.text =
              '${_specialController.text}, $specialization';
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid or duplicate specialization")),
      );
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeSelection(String label, TimeOfDay? time, Function onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        _buildTimeSelector(time, "Select $label", onTap),
      ],
    );
  }
}
