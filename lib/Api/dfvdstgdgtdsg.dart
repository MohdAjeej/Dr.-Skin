// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class ApiService1 {


//   final String _baseUrl2 = 'http://142.93.221.34:8000';

//   Future<Map<String, dynamic>> diagnoseSkin(File imageFile) async {
//     try {
//       var request =
//           http.MultipartRequest('POST', Uri.parse('$_baseUrl2/predict'));
//       request.files
//           .add(await http.MultipartFile.fromPath('file', imageFile.path));

//       var response = await request.send();
//       if (response.statusCode == 200) {
//         final respStr = await response.stream.bytesToString();

//         print("fghfjghjghkghkgkhdata $respStr");
//         return jsonDecode(respStr);
//       } else {
//         return {'error': 'Error: ${response.statusCode}'};
//       }
//     } catch (e) {
//       return {'error': 'Failed to connect to the server: $e'};
//     }
//   }
// }
