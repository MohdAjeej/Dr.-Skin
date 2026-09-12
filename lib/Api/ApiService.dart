import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://147.93.108.99:7078';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }
  
  /// Get current user role from SharedPreferences
  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('roles');
  }
  
  /// Check if current user is a doctor
  Future<bool> isDoctor() async {
    final role = await _getUserRole();
    return role == 'ROLE_DOCTOR';
  }
  
  /// Check if current user is a patient
  Future<bool> isPatient() async {
    final role = await _getUserRole();
    return role == 'ROLE_NORMAL' || role == null;
  }

  Map<String, String> _authHeaders(String token) {
    return {
      'Auth': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> diagnoseSkin(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data is Map<String, dynamic>) {
          return data;
        }

        return {
          'error': 'Invalid response format',
        };
      }

      return {
        'error': 'Error: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'error': 'Failed to connect to the server: $e',
      };
    }
  }

  Future<dynamic> registerUser({
    required String userName,
    required String email,
    required String password,
    required String mobileNo,
    required bool isDoctor,
    required bool registrationTermCondition,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = {
      'userName': userName,
      'email': email,
      'password': password,
      'mobileNo': mobileNo,
      'isDoctor': isDoctor,
      'registrationTermCondition':
          registrationTermCondition,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return response.body;
      }

      throw Exception(
        'Failed to register user: ${response.body}',
      );
    } catch (e) {
      throw Exception(
        'Error during registration: $e',
      );
    }
  }

  Future<bool> getDoctorProfile(String authToken) async {
    final url = Uri.parse(
      '$baseUrl/api/doctors/get-doctor-profile',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Auth': 'Bearer $authToken',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> getUserProfile(String authToken) async {
    final url = Uri.parse(
      '$baseUrl/api/profile/get-userProfile',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Auth': 'Bearer $authToken',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Login failed: ${response.body}',
      );
    }

    final responseData = jsonDecode(response.body);

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid login response');
    }

    final prefs = await SharedPreferences.getInstance();

    if (responseData['jwtToken'] != null) {
      await prefs.setString(
        'jwtToken',
        responseData['jwtToken'].toString(),
      );
    }

    if (responseData['refreshToken'] != null) {
      await prefs.setString(
        'refreshToken',
        responseData['refreshToken'].toString(),
      );
    }

    if (responseData['username'] != null) {
      await prefs.setString(
        'username',
        responseData['username'].toString(),
      );
    }

    if (responseData['userId'] != null) {
      await prefs.setString(
        'userId',
        responseData['userId'].toString(),
      );
    }

    if (responseData['roles'] != null) {
      await prefs.setString(
        'roles',
        responseData['roles'].toString(),
      );
    }

    return responseData;
  }

  Future<Map<String, dynamic>> fetchDiseaseDetails(
    int diseaseId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/diseases/$diseaseId',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch disease details: ${response.body}',
    );
  }

  /// Get patient profile data
  /// Should ONLY be called for users with ROLE_NORMAL
  Future<Map<String, dynamic>> getPatientProfile() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final url = Uri.parse(
      '$baseUrl/api/profile/get-userProfile',
    );

    final response = await http.get(
      url,
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to load patient profile: ${response.body}',
    );
  }

  /// Deprecated: Use getPatientProfile() or getDoctorProfileData() instead
  @Deprecated('Use role-specific profile methods')
  Future<Map<String, dynamic>> getUserProfilenew() async {
    return getPatientProfile();
  }

  Future<void> uploadDiseaseHistory(
    File file,
    String disease,
  ) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/api/disease/history/upload',
      ),
    );

    request.headers['Auth'] = 'Bearer $token';
    request.fields['disease'] = disease;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final body =
          await response.stream.bytesToString();

      throw Exception(
        'Failed to upload file: $body',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDiseaseHistory() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/disease/history/get-all-history',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    throw Exception(
      'Failed to load disease history: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getDoctorProfileData() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/doctors/get-doctor-profile',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch doctor profile: ${response.body}',
    );
  }

  Future<List<dynamic>> getDoctorAppointments(
    int doctorId,
  ) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/appointments/doctor/$doctorId',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch doctor appointments: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getAppointmentDetails(
    int appointmentId,
  ) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/appointments/$appointmentId',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch appointment details: ${response.body}',
    );
  }

  Future<void> updateAppointmentStatus(
    int appointmentId,
    String status, {
    String? reason,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final body = <String, dynamic>{
      'status': status,
    };

    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/appointments/$appointmentId/status',
      ),
      headers: {
        'Auth': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to update appointment status: ${response.body}',
      );
    }
  }

  Future<void> saveDoctorAvailability(
    Map<String, dynamic> availabilityData,
  ) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/doctors/availability',
      ),
      headers: {
        'Auth': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(availabilityData),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to save availability: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getDoctorAvailability(
    int doctorId,
  ) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/doctors/$doctorId/availability',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    if (response.statusCode == 404) {
      return {};
    }

    throw Exception(
      'Failed to fetch doctor availability: ${response.body}',
    );
  }

  /// Get all dermatologists with optional filtering
  Future<List<dynamic>> getAllDermatologists({
    String? searchQuery,
    String? specialization,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    var url = '$baseUrl/api/doctors/all';
    final queryParams = <String, String>{};

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    if (specialization != null && specialization.isNotEmpty) {
      queryParams['specialization'] = specialization;
    }

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$query';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        // Filter to only include dermatology specialists
        return data.where((doctor) {
          if (doctor is! Map<String, dynamic>) return false;
          
          final spec = (doctor['specialization'] ?? '').toString().toLowerCase();
          
          // Only include dermatology-related specializations
          return spec.contains('dermat') || 
                 spec.contains('skin') || 
                 spec.contains('cosmetic') ||
                 spec.contains('aesthetic') ||
                 spec.contains('hair');
        }).toList();
      }
    }

    throw Exception(
      'Failed to fetch dermatologists: ${response.body}',
    );
  }

  /// Get dermatologist by ID
  Future<Map<String, dynamic>> getDermatologistById(int doctorId) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/doctors/$doctorId'),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch dermatologist details: ${response.body}',
    );
  }

  /// Get available time slots for a doctor on a specific date
  Future<List<String>> getAvailableSlots({
    required int doctorId,
    required String date,
    required String appointmentType,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/appointments/available-slots?'
        'doctorId=$doctorId&date=$date&type=$appointmentType',
      ),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((slot) => slot.toString()).toList();
      }
    }

    throw Exception(
      'Failed to fetch available slots: ${response.body}',
    );
  }

  /// Create a new appointment
  Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required String appointmentDate,
    required String slotTime,
    required String appointmentType,
    String? concern,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final body = {
      'doctorId': doctorId,
      'appointmentDate': appointmentDate,
      'slotTime': slotTime,
      'appointmentType': appointmentType,
      if (concern != null && concern.isNotEmpty) 'concern': concern,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/appointments/create'),
      headers: {
        'Auth': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    throw Exception(
      'Failed to create appointment: ${response.body}',
    );
  }

  /// Get patient appointments
  Future<List<dynamic>> getPatientAppointments() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is not available');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/appointments/patient/my-appointments'),
      headers: {
        'Auth': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }
    }

    throw Exception(
      'Failed to fetch patient appointments: ${response.body}',
    );
  }

  /// Cancel appointment
  Future<void> cancelAppointment(
    int appointmentId, {
    String? reason,
  }) async {
    await updateAppointmentStatus(
      appointmentId,
      'CANCELLED',
      reason: reason,
    );
  }

  /// Confirm appointment
  Future<void> confirmAppointment(int appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'CONFIRMED');
  }

  /// Complete appointment
  Future<void> completeAppointment(int appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'COMPLETED');
  }
}